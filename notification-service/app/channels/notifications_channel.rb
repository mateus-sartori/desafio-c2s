class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for "notification_room"
  end
end
