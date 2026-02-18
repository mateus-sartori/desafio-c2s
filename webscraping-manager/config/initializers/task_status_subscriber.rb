# frozen_string_literal: true

if Rails.env.development? || Rails.env.production?
  Thread.new do
    begin
      redis = Redis.new(url: ENV.fetch("REDIS_URL"))

      Rails.logger.info "TaskStatusSubscriber: Listening for task status updates..."

      redis.subscribe("task_update_status") do |on|
        on.message do |channel, message|
          begin
            data = JSON.parse(message)
            task_id = data["task_id"]
            status = data["status"]
            result = data["result"]
            error_message = data["error_message"]

            Rails.logger.info "TaskStatusSubscriber: Updating task #{task_id} to #{status}"

            ActiveRecord::Base.connection_pool.with_connection do
              task = Task.find(task_id)
              task.update!(
                status: normalize_status(status),
                result: result,
                error_message: error_message,
                finished_at: Time.current
              )
            end
          rescue ActiveRecord::RecordNotFound => e
            Rails.logger.warn "TaskStatusSubscriber: Task #{data['task_id']} not found"
          rescue JSON::ParserError => e
            Rails.logger.error "TaskStatusSubscriber: Invalid JSON: #{e.message}"
          rescue StandardError => e
            Rails.logger.error "TaskStatusSubscriber: Error processing message: #{e.message}"
            Rails.logger.error e.backtrace.join("\n")
          end
        end
      end
    rescue Redis::ConnectionError => e
      Rails.logger.error "TaskStatusSubscriber: Redis connection error: #{e.message}"
      sleep 5
      retry
    rescue StandardError => e
      Rails.logger.error "TaskStatusSubscriber: Fatal error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      sleep 10
      retry
    end
  end
end

def normalize_status(status)
  case status.to_s
  when "pending" then 0
  when "processing" then 1
  when "finished" then 2
  when "failed" then 3
  else status.to_i
  end
end
