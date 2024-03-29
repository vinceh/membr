class ApplicationController < ActionController::Base
  protect_from_forgery

  def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      user_root_path
    elsif resource.is_a?(Admin)
      admin_root_path
    end
  end

  def after_sign_out_path_for(resource)
    root_url
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def render_error(options)
    @message = options[:message]
    @route = options[:route]
    render 'home/error'
  end

  def render_success(options)
    @message = options[:message]
    @route = options[:route]
    render 'home/success'
  end
end
