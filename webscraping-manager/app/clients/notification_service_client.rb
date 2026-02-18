class NotificationServiceClient < BaseClient
  def call
    super(base_url: ENV.fetch("NOTIFICATION_SERVICE_URL"))
  end

  def notify(event:, payload:)
    @conn.post("/api/v1/notifications", { event: event, payload: payload })
  rescue StandardError => e
    Rails.logger.error "[NotificationServiceClient] Failed to send notification: #{e.message}"
    nil
  end
end
