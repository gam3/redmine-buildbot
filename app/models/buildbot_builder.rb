#
# @package Redmine buildbot plugin
#
# @file Builder model
# @author Christoph Kappel <unexist@dorfelite.net>
# @version $Id$
#
# This program can be distributed under the terms of the GNU GPLv2.
# See the file COPYING for details
#

class BuildbotBuilder < ActiveRecord::Base
  unloadable

  has_many(:builds, :class_name => "BuildbotBuild", :foreign_key => "builder_id")
end

# vim:ts=2:bs=2:sw=2:et:fdm=marker
