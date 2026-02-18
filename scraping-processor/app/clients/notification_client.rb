class NotificationClient < BaseClient
  def call
    super(base_url: ENV.fetch("NOTIFICATION_SERVICE_URL"))
  end

  def notify(event:, payload:)
    @conn.post("/api/v1/notifications", { event: event, payload: payload })
  end
end
