class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @tasks = Task.where(user_id: current_user.id)

    Task.preload_users(@tasks)

    render inertia: "Home", props: {
      kpis: build_kpis(@tasks),
      recent_runs: build_recent(@tasks),
      health: build_health,
      top_sources: build_top_sources(@tasks)
    }
  end

  private

  def build_kpis(tasks)
    {
      runs7d: tasks.where("created_at >= ?", 7.days.ago).count,
      listings: tasks.where(status: :finished).count,
      errors: tasks.where(status: :failed).count,
      avgTime: average_processing_time(tasks)
    }
  end

  def average_processing_time(tasks)
    finished = tasks.where(status: :finished)

    return "—" if finished.empty?

    avg_seconds =
      finished.average("EXTRACT(EPOCH FROM (updated_at - created_at))")

    Time.at(avg_seconds).utc.strftime("%Mm %Ss")
  end

  def build_recent(tasks)
    tasks.order(created_at: :desc).limit(5).map do |t|
      {
        id: t.id,
        name: t.title,
        status: t.status.upcase,
        duration: duration_label(t),
        items: t.status == "finished" ? 1 : 0,
        ago: helpers.time_ago_in_words(t.created_at)
      }
    end
  end

  def duration_label(task)
    return "—" unless task.finished_at

    seconds = task.finished_at - task.created_at
    Time.at(seconds).utc.strftime("%Mm %Ss")
  end

  def build_health
    data = ScrapingProcessorClient.call.health

    return down_health unless data.present? && data["status"] == "ok"

    retry_size   = data["retry_size"]
    dead_size    = data["dead_size"]
    queue_size   = data["queue_size"]
    latency      = data["queue_latency"]
    failed_size  = data["failed_size"]

    {
      retrySize: retry_size,
      retryStatus: retry_status(retry_size),
      retryColor: retry_color(retry_size),

      deadSize: dead_size,
      deadStatus: dead_status(dead_size),
      deadColor: dead_color(dead_size),

      queueSize: queue_size,
      queueLatency: "#{latency}s",
      queueStatus: queue_status(queue_size, latency),
      queueColor: queue_color(queue_size, latency),

      busyWorkers: data["busy_workers"],
      totalProcesses: data["total_processes"],

      failedSize: failed_size
    }
  end



  def build_top_sources(tasks)
    [ {
      name: "WebMotors",
      category: "Marketplace",
      items: tasks.where(status: :finished).count,
      ok: tasks.where(status: :finished).count,
      err: tasks.where(status: :failed).count,
      okColor: "success",
      errColor: "error"
    } ]
  end

  def retry_status(value)
    return "OK" if value == 0
    return "WARNING" if value < 10
    "CRITICAL"
  end

  def retry_color(value)
    return "success" if value == 0
    return "warning" if value < 10
    "error"
  end

  def dead_status(value)
    value.zero? ? "OK" : "CRITICAL"
  end

  def dead_color(value)
    value.zero? ? "success" : "error"
  end

  def queue_status(size, latency)
    return "CRITICAL" if latency > 60
    return "WARNING" if size > 20 || latency > 20
    "OK"
  end

  def queue_color(size, latency)
    return "error" if latency > 60
    return "warning" if size > 20 || latency > 20
    "success"
  end

  def down_health
    {
      retrySize: "—",
      retryStatus: "DOWN",
      retryColor: "error",

      deadSize: "—",
      deadStatus: "DOWN",
      deadColor: "error",

      queueSize: "—",
      queueLatency: "—",
      queueStatus: "DOWN",
      queueColor: "error",

      busyWorkers: "—",
      totalProcesses: "—",

      failedSize: "—"
    }
  end
end
