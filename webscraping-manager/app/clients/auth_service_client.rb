class AuthServiceClient < BaseClient
  def call
    super(base_url: ENV.fetch("AUTH_SERVICE_URL"))
  end

  def sign_up(name, email, password, password_confirmation)
   @conn.post("api/v1/sign_up", { auth: { name: name, email: email, password: password, password_confirmation: password_confirmation } })
  end

  def sign_in(email, password)
    @conn.post("api/v1/sign_in", { auth: { email: email, password: password } })
  end

  def find_user(user_id)
    @conn.get("api/v1/users/#{user_id}")
  end

  def find_users(ids)
    @conn.get("api/v1/users", { ids: ids })
  end
end
