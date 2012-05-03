# $Id$
class CreateBuildbotBuilders < ActiveRecord::Migration
  def self.up
    create_table :buildbot_builders do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :buildbot_builders
  end
end
