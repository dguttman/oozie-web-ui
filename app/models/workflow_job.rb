class WorkflowJob < ActiveRecord::Base
  belongs_to :workflow
  
  def job
    Job.find(self.job_id)
  end
end
