class AddWorkflowXmlToWorkflow < ActiveRecord::Migration
  def self.up
    add_column :workflows, :workflow_xml, :text
  end

  def self.down
    remove_column :workflows, :workflow_xml
  end
end
