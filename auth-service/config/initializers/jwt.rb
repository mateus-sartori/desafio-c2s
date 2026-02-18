module JwtConfig
  SECRET = ENV.fetch("JWT_SECRET_KEY")
  ALGORITHM = "HS256"
  ACCESS_EXP = 15.minutes.to_i
  REFRESH_EXP = 7.days.to_i
end
