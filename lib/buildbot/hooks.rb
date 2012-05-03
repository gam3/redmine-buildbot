#
# @package Redmine buildbot plugin
#
# @file Buildbot hooks
# @author Christoph Kappel <unexist@dorfelite.net>
# @version $Id$
#
# This program can be distributed under the terms of the GNU GPLv2.
# See the file COPYING for details
#

module Buildbot
  class Hooks < Redmine::Hook::ViewListener

    ## view_layouts_base_html_head {{{
    # Add stylesheet link to base layout
    # @param  [Hash]  context  Context data
    ##

    def view_layouts_base_html_head(context = {})
      stylesheet_link_tag "buildbot.css", :plugin => :redmine_buildbot, :media => "screen"
    end # }}}

    ## view_layouts_base_content {{{
    # Append build info to revision view
    # @param  [Hash]  context  Context data
    ##

    def view_layouts_base_content(context = {})
      params = context[:controller].instance_variable_get("@_params")

      # Append to revision view only
      if "repositories" == params["controller"] and "revision" == params["action"]
        context[:controller].send(:render_to_string, {
          :partial => "buildbot/revision",
          :locals  => { :project => params["id"], :rev => params["rev"] }
        })
      end
    end # }}}
  end
end

# vim:ts=2:bs=2:sw=2:et:fdm=marker
