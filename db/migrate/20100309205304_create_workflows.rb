class CreateWorkflows < ActiveRecord::Migration
  def self.up
    create_table :workflows do |t|
      t.integer :user_id
      t.string :name
      t.string :archive_file_name
      t.string :archive_content_type
      t.integer :archive_file_size
      t.datetime :archive_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :workflows
  end
end
