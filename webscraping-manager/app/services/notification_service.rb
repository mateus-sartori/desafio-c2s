class NotificationService
  def self.send_notification(event, task)
    NotificationServiceClient.call.notify(
      event: event.to_s,
      payload: {
        task_id: task.id,
        title: task.title,
        url: task.url,
        status: task.status,
        user: {
          id: current_user.id,
          name: current_user.name,
          email: current_user.email
        },
        result: task.result,
        error_message: task.error_message,
        created_at: task.created_at,
        updated_at: task.updated_at
      }
    )
  rescue StandardError => e
    Rails.logger.error "[TasksController] Notification failed: #{e.message}"
  end
end
