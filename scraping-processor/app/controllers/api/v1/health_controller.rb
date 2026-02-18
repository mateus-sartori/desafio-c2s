class Api::V1::HealthController < ApplicationController
  def index
    stats = Sidekiq::Stats.new
    queue = Sidekiq::Queue.new("default")

    render json: {
      status: :ok,

      # visão geral
      processed_size: stats.processed,
      failed_size: stats.failed,
      retry_size: stats.retry_size,
      dead_size: stats.dead_size,
      enqueued_size: stats.enqueued,
      scheduled_size: stats.scheduled_size,

      # fila específica
      queue_size: queue.size,
      queue_latency: queue.latency.round(2),

      # workers
      busy_workers: Sidekiq::Workers.new.size,
      total_processes: Sidekiq::ProcessSet.new.size
    }
  rescue StandardError => e
    render json: {
      status: :error,
      message: e.message
    }, status: :service_unavailable
  end
end
