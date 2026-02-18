class ScrapingJob
  include Sidekiq::Job

  sidekiq_options queue: :default, retry: 3

  def perform(scrape_task_id)
    scrape_task = ScrapeTask.find(scrape_task_id)

    return if scrape_task.finished?

    scrape_task.update!(
      status: :processing,
      started_at: Time.current,
      retry_count: sidekiq_retry_in_block
    )

    result = ScrapingService.call(scrape_task.url)

    scrape_task.update!(
      status: :finished,
      result: result,
      error_message: nil,
      finished_at: Time.current
    )

    publish_status(scrape_task, :finished, result: result)

  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "[ScrapingJob] Task not found: #{scrape_task_id}"
    raise e

  rescue StandardError => e
    Rails.logger.error "[ScrapingJob] Error for task #{scrape_task_id}: #{e.class} - #{e.message}"

    handle_failure(scrape_task, e)

    raise e
  end

  private

  def handle_failure(scrape_task, error)
    return unless scrape_task

    scrape_task.update!(
      status: :failed,
      error_message: error.message,
      finished_at: Time.current,
      retry_count: sidekiq_retry_in_block
    )

    publish_status(scrape_task, :failed, error_message: error.message)

  rescue => redis_error
    Rails.logger.error "[ScrapingJob] Failure handler error: #{redis_error.message}"
  end

  def publish_status(scrape_task, status, result: nil, error_message: nil)
    return unless scrape_task.task_id.present?

    redis.publish(
      "task_update_status",
      {
        task_id: scrape_task.task_id,
        status: status,
        result: result,
        error_message: error_message
      }.to_json
    )

    NotificationClient.call.notify(
      event: "task_finished",
      payload: {
        task_id: scrape_task.task_id,
        status: scrape_task.status
      }
    )

  rescue => e
    Rails.logger.error "[ScrapingJob] Redis publish failed: #{e.message}"
  end

  def redis
    @redis ||= Redis.new(url: ENV.fetch("REDIS_URL"))
  end
end
