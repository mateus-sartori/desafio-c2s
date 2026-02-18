class JwtService
  SECRET    = JwtConfig::SECRET
  ALGORITHM = JwtConfig::ALGORITHM
  EXPIRATION = JwtConfig::ACCESS_EXP

  def self.encode(payload)
    JWT.encode(
      {
        data: payload,
        exp:  Time.now.to_i + EXPIRATION,
        jti:  SecureRandom.uuid,
        iat:  Time.now.to_i
      },
      SECRET,
      ALGORITHM
    )
  end
end
