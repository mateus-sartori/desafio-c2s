class JwtService
  SECRET    = ENV.fetch("JWT_SECRET_KEY") { raise "JWT_SECRET_KEY não configurada!" }
  ALGORITHM = "HS256"

  def self.decode(token)
    return nil if token.blank?

    clean_token = token.sub(/^Bearer\s+/, "")

    JWT.decode(clean_token, SECRET, true, { algorithm: ALGORITHM })[0]
  rescue JWT::ExpiredSignature
    nil
  rescue JWT::DecodeError => e
    Rails.logger.error "JWT decode error in auth-service: #{e.message}"
    nil
  end
end
