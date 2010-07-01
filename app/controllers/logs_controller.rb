class LogsController < ApplicationController
  def show 
    @log = Log.find(params[:job_id])
  end
end
