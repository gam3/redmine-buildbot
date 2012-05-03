#
# @package Redmine buildbot plugin
#
# @file Rake tasks
# @author Christoph Kappel <unexist@dorfelite.net>
# @version $Id$
#
# This program can be distributed under the terms of the GNU GPLv2.
# See the file COPYING for details
#

require File.dirname(__FILE__) + "/../buildbot/buildbot"

namespace :redmine_buildbot do
  desc "Fetch builds from Buildbot"
  task :fetch, :project, :needs => :environment do |t, args|
    unless args.empty?
      begin
        Buildbot.fetch(args.project, true)
      rescue Buildbot::ConnectionRefused
        puts "ERROR: Connection_refused"
      rescue Buildbot::RPCError
        puts "ERROR: Invalid update_time"
      rescue Buildbot::InvalidProject
        puts "ERROR: Invalid or missing project"
      rescue => err
        puts "ERROR: #{err}"
      end

      puts "Update complete"
    end
  end

  desc "Clear builds"
  task :clear, :project, :needs => :environment do |t, args|
    unless args.empty?
      Buildbot.clear(args.project)
    end
  end
end

# vim:ts=2:bs=2:sw=2:et:fdm=marker:ft=ruby
