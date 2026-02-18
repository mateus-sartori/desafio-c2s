class UserRepository
  def self.find(user_id)
    response = AuthServiceClient.call.find_user(user_id)

    return nil unless response.status == 200

    response.body
  end

  def self.find_by_ids(ids)
    response = AuthServiceClient.call.find_users(ids)
    users = response.body

    users.index_by { |u| u["id"] }
  end
end
