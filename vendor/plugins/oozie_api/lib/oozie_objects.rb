require 'ostruct'
OpenStruct.__send__(:define_method, :id) { @table[:id] || self.object_id }

class OozieObject < OpenStruct
  attr_reader :table
end
  
class OozieJob < OozieObject
  
  def log
    OozieApi.log(self.id)
  end
  
  def info
    OozieJobInfo.new(OozieApi.info(self.id))
  end
  
  def definition
    OozieApi.definition(self.id)
  end
  
  def start
    OozieApi.start_job(self.id)
  end
  
  def suspend
    OozieApi.suspend_job(self.id)
  end
  
  def resume
    OozieApi.resume_job(self.id)
  end
  
  def kill
    OozieApi.kill_job(self.id)
  end
  
  def name; appName; end
  def path; appPath; end
  def console_url; consoleUrl; end
  def created_at; Time.parse(createdTime) if createdTime; end
  def started_at; Time.parse(startTime) if startTime; end
  def ended_at; Time.parse(endTime) if endTime; end
  def external_id; externalId; end

end

class OozieJobInfo < OozieObject
  
  def actions
    @table[:actions].map {|a| OozieAction.new(a)}
  end
  
  def created_at; Time.parse(createdTime) if createdTime; end
  def started_at; Time.parse(startTime) if startTime; end
  def ended_at; Time.parse(endTime) if endTime; end
  
end

class OozieAction < OozieObject
  def started_at; Time.parse(startTime) if startTime; end
  def ended_at; Time.parse(endTime) if endTime; end
end
