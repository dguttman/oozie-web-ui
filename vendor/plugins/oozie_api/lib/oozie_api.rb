require File.join(File.dirname(__FILE__), 'oozie_objects')
require 'httparty'

class OozieApi
  extend OozieJobs
  
  include HTTParty
  
  PREFIX = OOZIE_TOMCAT + "/oozie/v0"
  
  # def self.extended(other)
  #   other.send :include, HTTParty
  # end
  
  def self.oozie_get(resource)
    begin
      response = get(PREFIX + resource)
    rescue
      {}
    end
  end
  
  def self.oozie_post(resource, params={})
    begin
      response = post(PREFIX + resource, params)
    rescue
      {}
    end
  end
  
  def self.oozie_put(resource, opts={})
    begin
      response = put(PREFIX + resource)
    rescue
      {}
    end
  end
  
end

# GET
# /oozie/versions
# /oozie/v0/admin/status
# /oozie/v0/admin/os-env
# /oozie/v0/admin/java-sys-properties
# /oozie/v0/admin/configuration
# /oozie/v0/admin/instrumentation
# /oozie/v0/job/job-3?show=info
# /oozie/v0/job/job-3?show=definition
# /oozie/v0/job/job-3?show=log
# /oozie/v0/jobs?filter=user%3Dtucu&offset=1&len=50
# * name: the workflow application name from the workflow definition
# * user: the user that submitted the job
# * group: the group for the job
# * status: the status of the job


# PUT
# /oozie/v0/job/job-3?action=start #=> 'start', 'suspend', 'resume' and 'kill'.
# /oozie/v0/admin/status?safemode=true

# POST
# /oozie/v0/jobs
# Content-Type: application/xml;charset=UTF-8
# .
# <?xml version="1.0" encoding="UTF-8"?>
# <configuration>
#     <property>
#         <name>user.name</name>
#         <value>tucu</value>
#     </property>
#     <property>
#         <name>oozie.wf.application.path</name>
#         <value>hdfs://foo:9000/user/tucu/myapp/</value>
#     </property>
#     ...
# </configuration>

