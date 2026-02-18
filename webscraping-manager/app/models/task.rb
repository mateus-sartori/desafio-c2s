class Task < ApplicationRecord
  attribute :user

  validates :title, :url, :user_id, presence: true
  validates :url, format: { with: URI.regexp }

  enum :status, { pending: 0, processing: 1, finished: 2, failed: 3 }

  def self.preload_users(tasks)
    return [] if tasks.blank?
    ids = tasks.map(&:user_id).uniq
    users = UserRepository.find_many(ids)

    tasks.each do |task|
      task.instance_variable_set(:@user, users[task.user_id])
    end
  end

  def user
    return @user if defined?(@user) && @user.present?

    @user = UserRepository.find(user_id)
  end
end
