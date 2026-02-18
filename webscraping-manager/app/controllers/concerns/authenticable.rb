module Authenticable
  extend ActiveSupport::Concern

  included do
    helper_method :current_user
  end

  private

  def authenticate_user!
    token = extract_token_from_request
    return unauthorized("Token not found") if token.blank?

    payload = decode_token(token)
    return unauthorized("Invalid or expired token") if payload.blank?

    @current_user = User.new(payload["data"])
  end

  def current_user
    @current_user
  end

  def extract_token_from_request
    auth_header = request.headers["Authorization"].to_s
    bearer = auth_header[/\ABearer\s+(.+)\z/, 1]
    return bearer if bearer.present?

    cookies.encrypted[:token].presence || cookies.signed[:token].presence
  end

  def decode_token(token)
    JwtService.decode(token)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end

  def unauthorized(_message = "Unauthorized")
    cookies.delete(:token)

    redirect_to login_path
    nil
  end
end
