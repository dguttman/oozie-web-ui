class AddStatusToWorkflow < ActiveRecord::Migration
  def self.up
    add_column :workflows, :status_code, :integer, :default => 0
  end

  def self.down
    remove_column :workflows, :status
  end
end
