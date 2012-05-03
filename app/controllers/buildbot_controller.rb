#
# @package Redmine buildbot plugin
#
# @file Buildbot controller
# @author Christoph Kappel <unexist@dorfelite.net>
# @version $Id$
#
# This program can be distributed under the terms of the GNU GPLv2.
# See the file COPYING for details
#

require "buildbot/buildbot"
require "uri"

include RepositoriesHelper

class BuildbotController < ApplicationController
  unloadable

  before_filter :find_project, :find_or_create_settings
  layout "base"

  ## index {{{
  # Display list of builds
  ##

  def index
    @builds_count = BuildbotBuild.count(:conditions => [ "project_id = ?", @project.id ])
    @builds_pages = Paginator.new(self, @builds_count,
      per_page_option, params["page"]
    )
    @builds = BuildbotBuild.find(:all,
      :conditions => [ "project_id = ?", @project.id ],
      :limit      => @builds_pages.items_per_page,
      :offset     => @builds_pages.current.offset,
      :order      => "end_time DESC",
      :include    => [ :builder ]
    )

    respond_to do |format|
      format.html { render :template => "buildbot/show_builds", :layout => !request.xhr? }
    end
  end # }}}

  ## settings {{{
  # Save settings
  ##

  def settings
    if request.post?
      @buildbot_settings.attributes = params[:buildbot_settings]

      # Try to parse and validate URI
      begin
        u = URI.parse(@buildbot_settings["host"])
      rescue Uri::InvalidURIError
        flash[:error] = l(:error_buildbot_invalid_uri)

        redirect_to(:controller => "buildbot", :action => "settings", :project_id => @project)
      end

      if @buildbot_settings.save
        redirect_to(:controller => "buildbot", :action => "index", :project_id => @project)
      end
    end
  end # }}}

  ## update {{{
  # Update builds
  ##

  def update
    # Fetch data
    Buildbot.fetch(@project.name)

    flash[:notice] = l(:mesg_buildbot_builds_updated)

    redirect_to(:controller => "buildbot", :action => "index", :project_id => @project)
  rescue Buildbot::ConnectionRefused
    flash[:error] = l(:error_buildbot_connection_refused)

    redirect_to(:controller => "buildbot", :action => "settings", :project_id => @project)
  rescue Buildbot::RPCError
    flash[:error] = l(:error_buildbot_update_time)

    redirect_to(:controller => "buildbot", :action => "settings", :project_id => @project)
  rescue Buildbot::InvalidProject
    flash[:error] = l(:error_buildbot_invalid_project)

    redirect_to(:controller => "buildbot", :action => "settings", :project_id => @project)
  end # }}}

  ## clear {{{
  # Clear builds
  ##

  def clear
    #FIXED: parameter required.
    Buildbot.clear(@project.name)

    flash[:notice] = l(:mesg_buildbot_builds_deleted)

    redirect_to(:controller => "buildbot", :action => "index", :project_id => @project)
  end # }}}

  ## builder {{{
  # Show builds of given builder
  ##

  def builder
    @builder = BuildbotBuilder.find(:first,
      :conditions => [ "name = ?", params[:builder_name] ]
    )

    @builds_count = BuildbotBuild.count(
      :conditions => [
        "project_id = ? and builder_id = ?",
          @project.id, @builder.id
      ]
    )
    @builds_pages = Paginator.new(self, @builds_count,
      per_page_option, params["page"]
    )

    @builds = BuildbotBuild.find(:all,
      :conditions => [
        "project_id = ? and builder_id = ?",
          @project.id, @builder.id
      ],
      :limit      => @builds_pages.items_per_page,
      :offset     => @builds_pages.current.offset,
      :order      => "end_time DESC",
      :include    => [ :builder ]
    )

    respond_to do |format|
      format.html { render :template => "buildbot/show_builder", :layout => !request.xhr? }
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end # }}}

  private

  ## find_or_create_settings {{{
  # Find or create initial settings
  ##

  def find_or_create_settings
    @buildbot_settings = BuildbotSetting.find(:first,
      :conditions => [ "project_id = ?", @project.id ]
    )

    # Create default settings on demand
    if @buildbot_settings.nil?
      @buildbot_settings = BuildbotSetting.new(
        :project_id  => @project.id,
        :host        => "localhost",
	:builder     => "runtests",
        :last_update => Time.now
      )
      @buildbot_settings.save
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end # }}}

  ## find_project {{{
  # Find project by id
  ##

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end # }}}
end

# vim:ts=2:bs=2:sw=2:et:fdm=marker
