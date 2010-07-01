class JobsController < ApplicationController

  before_filter :find_job, :except => :index

  def index
    @title = "Oozie UI: Jobs Index"
    
    @jobs = paginate(Job.find(:all, :order => :created_at).reverse)
    
    
    # TODO: should probably be format json or responding to xhr
    if params[:username]
      @jobs = @jobs.select {|j| j.user == params[:username]}
    end
    
    if params[:no_layout]
      render :partial => "jobs_list_table"
    end
  end
  
  def show
    @title = "Oozie UI: Job Info"
  end
  
  def conf
    @title = "Oozie UI: Job Properties"
    @properties = OozieApi.conf_xml_to_properties_hash(@job.conf)
  end
  
  def actions
    @title = "Oozie UI: Job Actions"
    @info = @job.info
    @actions = @info.actions
  end
  
  def definition
    @title = "Oozie UI: Job Definition"
  end
  
  def log
    @title = "Oozie UI: Job Log"
    @log = @job.log
    # TODO: should probably be format json or responding to xhr
    if params[:no_layout]
      render :partial => "logfile"
    end
  end
  
  def flowchart
    @title = "Oozie UI: Job Flowchart"
    xml = @job.definition
    @nodes_data = FlowchartGenerator.create_node_hash_from_xml(xml)  
    @nodes = FlowchartGenerator.create_nodes(@nodes_data).to_json          
  end
  
  # Job Actions: restart, start, suspend, resume, kill
  def restart
    if @job.user == current_user.username
      conf = @job.conf
      new_job = Job.create(:conf_xml => conf, :start_now => true)
      flash[:notice] = "Created new job: #{new_job.id}"
      redirect_back_or_default(root_url)
      # redirect_to :action => :show, :id => new_job.id
    else
      flash[:error] = "You may only perform actions on your own jobs."
      redirect_to :action => :index
    end
  end
  
  def start
    if @job.user == current_user.username
      @response = @job.start
      flash[:notice] = "Started job: #{@job.id}"
      redirect_back_or_default(root_url)
      # redirect_to root_url
    else
      flash[:error] = "You may only perform actions on your own jobs."
      redirect_to :action => :index
    end
  end
  
  def suspend
    if @job.user == current_user.username
      @response = @job.suspend
      flash[:notice] = "Suspended job: #{@job.id}"
      redirect_back_or_default(root_url)
      # redirect_to root_url
    else
      flash[:error] = "You may only perform actions on your own jobs."
      redirect_to :action => :index
    end
  end
  
  def resume
    if @job.user == current_user.username
      @response = @job.resume
      flash[:notice] = "Resumed job: #{@job.id}"
      redirect_back_or_default(root_url)
      # redirect_to root_url
    else
      flash[:error] = "You may only perform actions on your own jobs."
      redirect_to :action => :index
    end
  end
  
  def kill
    if @job.user == current_user.username
      @response = @job.kill
      flash[:notice] = "Killed job: #{@job.id}"
      redirect_back_or_default(root_url)
      # redirect_to root_url
    else
      flash[:error] = "You may only perform actions on your own jobs."
      redirect_to :action => :index
    end
  end

private

  def find_job
    @job = Job.find(params[:id])
    unless @job
      flash[:error] = "Error Finding Job: #{params[:id]}"
      redirect_to :action => :index
      return
    end
  end
  
end
