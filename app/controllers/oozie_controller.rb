class OozieController < ApplicationController

  def index
    #@jobs = Jobs.get("http://np192.wc1.yellowpages.com:8080/oozie/v0/jobs")
    @jobs = Job.find(:all, :order => :created_at).reverse
    #job = Job.get("http://np192.wc1.yellowpages.com:8080/oozie/v0/job/11-100216212518924-oozie-root?show=info")
  end




end
