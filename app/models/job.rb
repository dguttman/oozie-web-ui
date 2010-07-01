class Job

  cattr_reader :per_page
  @@per_page = 10

  def self.find(job_id=nil, opts={})
    # TODO: clean this up a bit
    if job_id && job_id != :all
      job = all.select {|j| j.id == job_id}.first
    else
      jobs = all
      
      if jobs
        if opts[:conditions]
          opts[:conditions].each do |param, val|
            jobs = jobs.select {|j| j.send(param) == val}
          end
        end
        
        if opts[:order]
          jobs.sort! {|a,b| a.send(opts[:order]) <=> b.send(opts[:order])}
        end
      end
      
      return jobs
    end
  end
  
  def self.all
    workflows = OozieApi.workflows
    
    if workflows
      workflows.map {|wf| OozieJob.new(wf)} 
    else
      []
    end
  end
  
  def self.first
    all.first
  end
  
  def self.last
    all.last
  end

  def self.create(params)
    response = OozieApi.submit_job(params)
    return self.find(response["id"])
  end

end

class OozieJob
  def workflow
    wj = WorkflowJob.find(:first, :conditions => {:job_id => self.id})
    return wj.workflow if wj
  end
end