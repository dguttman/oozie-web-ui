# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def flash_message(*types, &proc)
    types.each do |t|
      yield(flash[t], t) if flash[t]
    end
  end

  def format_time(time)
    return nil unless time
    time.strftime("%I:%M:%S %p (%m/%d/%y)")
  end

end
