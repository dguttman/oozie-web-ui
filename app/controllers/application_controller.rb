# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  include AuthenticatedSystem

  # plugable login system.  Att uses it's own single signon web ui so this was a way to add that 
  self.send(:include, OozieUiConfig[:authenticated_system].constantize) if OozieUiConfig[:authenticated_system]

  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :login_required

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
  def paginate(results, page=params[:page], per_page=10)
    
    page ||= 1
    page = page.to_i
    
    page_results = WillPaginate::Collection.create(page, per_page, 0) do |pager|
    end
    
    page_results = WillPaginate::Collection.create(page, per_page, results.length) do |pager|
      start = (page-1)*per_page # assuming current_page is 1 based.
      pager.replace(results[start, per_page])
    end
    
    return page_results
  end
end
