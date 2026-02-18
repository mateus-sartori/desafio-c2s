class RegistrationsController < ApplicationController
  def sign_up
    response = AuthServiceClient.call.sign_up(params[:name], params[:email], params[:password], params[:password_confirmation])

    if response.body["success"]
      redirect_to login_path
    else
      render inertia: "Auth/SignUp", props: { errors: response.body["errors"] }
    end
  end

  def index
    render inertia: "Auth/SignUp"
  end
end
