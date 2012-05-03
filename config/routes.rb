# $Id$
ActionController::Routing::Routes.draw do |map|
  map.resources :projects do |project|
    project.buildbot_start    "buildbot",               :controller => "buildbot", :action => "index",    :conditions => {:method => :get}
    project.buildbot_index    "buildbot/index",         :controller => "buildbot", :action => "index",    :conditions => {:method => :get}
    project.buildbot_update   "buildbot/update",        :controller => "buildbot", :action => "update",   :conditions => {:method => :get}
    project.buildbot_clear    "buildbot/clear",         :controller => "buildbot", :action => "clear",    :conditions => {:method => :get}
    project.buildbot_settings "buildbot/settings",      :controller => "buildbot", :action => "settings", :conditions => {:method => [ :get, :post ]}
    project.buildbot_builder  "buildbot/:builder_name", :controller => "buildbot", :action => "builder",  :conditions => {:method => :get}
  end
end
