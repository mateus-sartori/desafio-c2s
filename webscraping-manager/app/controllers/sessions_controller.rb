class SessionsController < ApplicationController
  def index
    render inertia: "Auth/Login"
  end

  def sign_in
    response = AuthServiceClient.call.sign_in(params[:email], params[:password])

    if response.success?
      cookies.encrypted[:token] = {
        value: response.body.fetch("token"),
        httponly: true,
        secure: Rails.env.production?,
        same_site: :lax,
        expires: 2.weeks.from_now
      }

      redirect_to home_path
    else
      render inertia: "Auth/Login", props: { flash: { error: response.body["error"] } }
    end
  end

  def destroy
    cookies.delete(:token)
    redirect_to login_path
  end
end
