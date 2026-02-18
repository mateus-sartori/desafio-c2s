class Api::V1::AuthController < ApplicationController
  def sign_in
    user = User.find_by(email: login_params[:email]&.downcase)

    if user&.authenticate(login_params[:password])
      payload = { id: user.id, name: user.name, email: user.email }
      token = JwtService.encode(payload)

      render json: { token: token, expires_in: JwtService::EXPIRATION }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def sign_up
    user = User.new(name: register_params[:name], email: register_params[:email]&.downcase, password: register_params[:password], password_confirmation: register_params[:password_confirmation])

    if user.save
      render json: { success: true, user: { id: user.id, email: user.email } }, status: :created
    else
      render json: { success: false, errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def logout
    render json: { success: true, message: "Logged out successfully" }, status: :ok
  end

  private

  def login_params
    params.require(:auth).permit(:email, :password)
  end

  def register_params
    params.require(:auth).permit(:name, :email, :password, :password_confirmation)
  end
end
