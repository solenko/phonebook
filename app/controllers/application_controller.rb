class ApplicationController < ActionController::Base
  protect_from_forgery
  after_filter :xhr_flash

  protected

  def xhr_flash
    return unless request.xhr?
    flash.each do |type, flash|
      response.headers["X-Message-#{type}"] = flash
    end
    flash.discard
  end

end
