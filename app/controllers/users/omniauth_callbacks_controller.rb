class Users::OmniauthCallbacksController   < Devise::OmniauthCallbacksController

  def stripe_connect

    token = request.env["omniauth.auth"]["credentials"]["token"]

    Stripe.api_key = token
    u = Stripe::Account.retrieve()

    renderer = {
      :request => request.env["omniauth.auth"],
      :user => u
    }

    user = User.from_omniauth(request.env["omniauth.auth"])
    if user.persisted?
      flash.notice = "Signed in!"
      sign_in_and_redirect user
    else
      flash.error = "There was an error with your sign in"
      redirect_to root_url
    end

    # render :json => JSON.pretty_generate(JSON.parse(renderer.to_json))
  end
end