#
# @package Redmine buildbot plugin
#
# @file Plugin init
# @author Christoph Kappel <unexist@dorfelite.net>
# @version $Id$
#
# This program can be distributed under the terms of the GNU GPLv2.
# See the file COPYING for details
#

require "redmine"

require_dependency "buildbot/hooks"

Redmine::Plugin.register :redmine_buildbot do
  name "Redmine Buildbot plugin"
  author "Christoph Kappel"
  description "This plugin integrates buildbot into redmine"
  version "0.0.1"
  url "http://subforge.org/projects/redmine_buildbot"
  author_url "http://subforge.org"

  # Add menus
  menu(:project_menu, :buildbot,
    {
      :controller => "buildbot",
      :action     => "index",
    },
    :caption => "Buildbot",
    :after   => :repository,
    :param   => :project_id
  )

  # Module
  project_module :buildbot do
    permission :view_buildbot,   { :buildbot => [ :index, :builder ] }
    permission :update_buildbot, { :buildbot => :update }, :require => :member
    permission :clear_buildbot,  { :buildbot => :clear  }, :require => :member
  end

  # Activity
  activity_provider :buildbot_builds
end

# vim:ts=2:bs=2:sw=2:et:fdm=marker
