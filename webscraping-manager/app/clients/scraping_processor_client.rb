class ScrapingProcessorClient < BaseClient
  def call
    super(base_url: ENV.fetch("SCRAPING_PROCESSOR_URL"))
  end

  def health
    response = @conn.get("api/v1/health")
    response.body
  rescue StandardError
    nil
  end

  def scrap_task(task)
   @conn.post("api/v1/scrap_task", { scraping_task: { task_id: task.id, url: task.url } })
  end
end
