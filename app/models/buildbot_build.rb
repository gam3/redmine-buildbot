#
# @package Redmine buildbot plugin
#
# @file Build model
# @author Christoph Kappel <unexist@dorfelite.net>
# @version $Id$
#
# This program can be distributed under the terms of the GNU GPLv2.
# See the file COPYING for details
#

class BuildbotBuild < ActiveRecord::Base
  unloadable

  # Relations
  belongs_to(:builder, :class_name => "BuildbotBuilder", :foreign_key => "builder_id")
  belongs_to(:project, :foreign_key => "project_id")
  belongs_to(:changeset, :foreign_key => "changeset_id")

  # Event integration
  acts_as_event(
    :datetime    => :end_time,
    :title       => Proc.new { |o|
      "Build #%d on %s: %s" % [
        o.number,
        o.builder.name,
        o.result
      ]
    },
    :description => Proc.new { |o|
      "Revision %s" % [ o.changeset.nil? ? o.revision : o.changeset.revision ]
    },
    :author      => "Buildbot",
    :url         => Proc.new { |o|
      {
        :controller   => "buildbot",
        :action       => "builder",
        :project_id   => o.project,
        :builder_name => o.builder.name
      }
    }
  )

  # Activity integration
  acts_as_activity_provider(
    :timestamp    => "end_time",
    :find_options => { :include => [ :project, :builder, :changeset ] },
    :permission   => :view_buildbot
  )
end

# vim:ts=2:bs=2:sw=2:et:fdm=marker
