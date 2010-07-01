class Log < ActiveRecord::Base
  
  def self.find(job_id)
    OozieApi.log(job_id)
  end
  
end
