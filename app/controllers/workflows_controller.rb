class WorkflowsController < ApplicationController
  
  before_filter :find_workflow, :except => [:index, :new, :create]
  
  def index
    @workflows = Workflow.all.reverse
  end
  
  def new
    @workflow = Workflow.new
  end
  
  def show
  end
  
  def create
    attributes = params[:workflow].merge({:user_id => current_user.id})
    @workflow = Workflow.new(attributes)
    if @workflow.save
      redirect_to :action => :index
    else
      render :action => :new
    end
  end
  
  def jobs
    @jobs = @workflow.jobs
  end
  
  def delete
    if @workflow.user == current_user
      if @workflow.destroy
        flash[:notice] = "Workflow #{@workflow.name} deleted"
        redirect_to :action => :index
      else
        flash[:error] = "Could not delete workflow #{@workflow.name}"
        redirect_to :action => :index
      end
    else
      flash[:error] = "You may only delete your own workflows."
    end
  end
  
  def show_xml
    if params[:version]
      version = params[:version].to_i
      @workflow.revert_to(version)
    end
    @xml = @workflow.workflow_xml

  end
  
  def update_xml
    if @workflow.user == current_user
      @xml = params[:xml]
      @workflow.workflow_xml = @xml
      @workflow.updated_by = current_user
      @workflow.save
      filename = RAILS_ROOT + "/tmp/workflow.xml"
      tmp_xml_file = File.new(filename, "w")
      tmp_xml_file << @workflow.workflow_xml
      tmp_xml_file.close
      @workflow.remove_remote_workflow_xml
      @workflow.hadoop_put(filename, "workflow.xml")
      flash[:notice] = "Workflow.xml updated"
    else
      flash[:error] = "You may only modify your own workflows."
    end
    
    redirect_to :action => :show_xml, :id => @workflow.id
  end

  def flowchart
    @xml = @workflow.workflow_xml
    @nodes_data = FlowchartGenerator.create_node_hash_from_xml(@xml)  
    @nodes = FlowchartGenerator.create_nodes(@nodes_data).to_json          
  end

  def start
    new_job = Job.create(:properties_hash => @workflow.properties_hash, :start_now => true)
    @wf_job = WorkflowJob.create(:job_id => new_job.id, :workflow_id => @workflow.id)
    redirect_to :controller => :jobs, :action => :show, :id => new_job.id
  end

  def edit_properties
    @properties = @workflow.properties_hash
    
    if request.method == :put
      property_hash = params[:properties]
      @workflow.properties_xml = OozieApi.properties_hash_to_conf_xml(property_hash)
      if @workflow.save
        flash[:notice] = "Properties successfully updated for Workflow: #{@workflow.name}"
        redirect_to :action => :index
      else
        flash[:notice] = "Error updating properties."
      end
    end
  end

private

  def find_workflow
    @workflow = Workflow.find(params[:id])
  end
  
end
