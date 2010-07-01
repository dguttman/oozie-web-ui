class AddPropertiesToWorkflow < ActiveRecord::Migration
  def self.up
    add_column :workflows, :properties_xml, :text
  end

  def self.down
    remove_column :workflows, :properties_xml
  end
end
