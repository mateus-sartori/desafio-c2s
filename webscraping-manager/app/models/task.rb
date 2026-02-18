class Task < ApplicationRecord
  enum :status, { pending: 0, processing: 1, finished: 2, failed: 3 }

  validates :title, presence: true
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp, message: "deve ser uma URL válida" }

  cattr_accessor :preloaded_users_cache
  self.preloaded_users_cache = {}

  def self.preload_users(tasks)
    return if tasks.empty?

    user_ids = tasks.map(&:user_id).uniq.compact
    return if user_ids.empty?

    users = UserRepository.find_by_ids(user_ids)

    users_array = users.is_a?(Array) ? users : [ users ]

    users_array.each do |user|
      next unless user.is_a?(Hash)

      # Pegar o ID independente se é symbol ou string
      uid = user["id"] || user[:id]
      self.preloaded_users_cache[uid.to_i] = user.transform_keys(&:to_s)
    end
  end

  def user
    user_id_value = self.user_id.to_i

    if self.class.preloaded_users_cache[user_id_value]
      return self.class.preloaded_users_cache[user_id_value]
    end

    user_data = UserRepository.find(user_id_value)
    self.class.preloaded_users_cache[user_id_value] = user_data if user_data
    user_data
  end

  def self.clear_users_cache
    self.preloaded_users_cache = {}
  end
end
