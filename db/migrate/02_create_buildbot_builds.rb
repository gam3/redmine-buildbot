# $Id$
class CreateBuildbotBuilds < ActiveRecord::Migration
  def self.up
    create_table :buildbot_builds do |t|
      t.integer   :builder_id
      t.integer   :project_id
      t.integer   :changeset_id
      t.integer   :number
      t.timestamp :end_time
      t.string    :branch
      t.string    :revision
      t.string    :result
      t.text      :text
      t.timestamps
    end
  end

  def self.down
    drop_table :buildbot_builds
  end
end
