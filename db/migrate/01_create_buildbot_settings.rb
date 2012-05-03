# $Id$
# 2012/05/03	Ju-yeong Park	Added builder attribute.

class CreateBuildbotSettings < ActiveRecord::Migration
  def self.up
    create_table :buildbot_settings do |t|
      t.integer   :project_id
      t.string    :host
      t.string    :builder
      t.timestamp :last_update
      t.timestamps
    end
  end

  def self.down
    drop_table :buildbot_settings
  end
end
