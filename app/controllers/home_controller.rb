class HomeController < ApplicationController
  protect_from_forgery

  def index
    @beta = Beta.new

    render :layout => "static"
  end

  def terms
    render :layout => "static"
  end

  def faq
    render :layout => "static"
  end

  def about
    render :layout => "static"
  end

  def create_beta
    beta = Beta.new(params[:beta])

    if beta.save!
      @message = "Thank you for your interest in our beta.  We will contact you as soon as possible with information about your beta account."
      @route = root_url
      render "success"
    end
  end
end
