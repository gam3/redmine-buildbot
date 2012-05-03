##
# @package Redmine buildbot plugin
#
# @file Buildbot module
# @author Christoph Kappel <unexist@dorfelite.net>
# @version $Id: lib/buildbot/buildbot.rb,v 11 2012/02/03 22:39:15 unexist $
#
# This program can be distributed under the terms of the GNU GPL2.
# See the file COPYING for details
#
#  History:
#     2012/05/03	Ju-yeong Park	Changed logics using XMLRPC to use JSONRPC.


require "json"
require "net/http"
require "redmine/i18n"
require "uri"

module Buildbot
  # Error classes
  class ConnectionRefused < StandardError; end
  class RPCError < StandardError; end
  class InvalidProject < StandardError; end

  # Reply fields
  FIELD_BUILDER  = 'builderName'
  FIELD_NUMBER   = 'number'
  FIELD_END_TIME = 'times'
  FIELD_BRANCH   = 'branch'
  FIELD_REVISION = 'revision'
  FIELD_RESULT   = 'results'
  FIELD_TEXT     = 'text'

  ## fetch {{{
  # Fetch data from buildbot
  # @param  [String]  project  Identifier or name of the project
  # @param  [Bool]    verbose  Print verbose messages
  ###

  def self.fetch(project, verbose = false)
    now = Time.now
    i   = 0
    self.clear(project)

    # Find project and settings
    project = Project.find(:first,
      :conditions => [ "identifier = ? or name = ?", project, project ]
    )
    settings = BuildbotSetting.find(:first,
      :conditions => [ "project_id = ?", project.id ]
    )

    raise Buildbot::InvalidProject if settings.nil?

    # Cache data
    builders  = BuildbotBuilder.find(:all)

    $stderr.puts "Loaded #{builders.size} builder(s)" if verbose

    # Parse URI
    u = URI.parse('http://' + settings.host + '/json/builders/' + settings.builder + '/builds/_all' )

    # Query buildbot via jsonrpc.
  
    #client = XMLRPC::Client.new(u.host, "/xmlrpc",
    #  (80 == u.port ? nil : u.port),
    #  nil, nil, u.user, u.password, "https" == u.scheme)
    builds = JSON.parse(Net::HTTP.get_response(u).body)

    $stderr.puts "Fetched #{builds.size} build(s)" if verbose
    # Insert builds into database
    for b in builds.values do
      i += 1

      # Find or create builder
      if (builder = builders.select { |s| s.name == b[FIELD_BUILDER] }).empty?
        builder = BuildbotBuilder.new(
          :name => b[FIELD_BUILDER]
        )
        builder.save!

        $stderr.puts "Added builder #{builder.name}" if(verbose)

        builders << builder
      else
        builder = builder.first
      end

      # Find changeset
      changeset = Changeset.find(:first,
        :conditions => [ "scmid = ?", b['sourceStamp'][FIELD_REVISION][0..11] ] #< Revision is longer than scmid
      )
      changeset = changeset.nil? ? nil : changeset["id"]


      # Create build
      build = BuildbotBuild.new(
        :builder_id   => builder.id,
        :project_id   => project.id,
        :changeset_id => changeset,
        :number       => b[FIELD_NUMBER].to_i,
        :end_time     => Time.at(b[FIELD_END_TIME][1]),
        :branch       => b['properties'][0][1],
        :revision     => b['properties'][3][1],
        :result       => b[FIELD_TEXT][1],
        :text         => b[FIELD_TEXT].join(" ").capitalize
      )
      build.save!

      if(verbose)
        $stderr.puts "Added build %4d/%4d %s:%s" % [ 
          i, builds.size, builder.name, build.number
        ]
      end
    end

    # Save settings
    settings["last_update"] = now
    settings.save
  rescue Errno::ECONNREFUSED
    raise Buildbot::ConnectionRefused
  end # }}}

  ## clear {{{
  # Delete all build data
  ##

  def self.clear(project)
    # Find project
    project = Project.find(:first,
      :conditions => [ "name = ?", project ]
    )

    BuildbotBuild.delete_all([ "project_id = ?", project.id ])
  end # }}}
end

# vim:ts=2:bs=2:sw=2:et:fdm=marker
