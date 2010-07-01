class CreateWorkflowJobs < ActiveRecord::Migration
  def self.up
    create_table :workflow_jobs do |t|
      t.string :job_id
      t.integer :workflow_id

      t.timestamps
    end
  end

  def self.down
    drop_table :workflow_jobs
  end
end
