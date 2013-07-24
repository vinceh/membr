class Users::RegistrationsController  < Devise::RegistrationsController

  protected

  def sign_up(resource_name, resource)
    sign_in(resource_name, resource)
    resource.add_stripe(params[:stripeToken])
  end
end