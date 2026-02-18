class Api::V1::ScrapingTaskController < ApplicationController
  def scrap_task
    @scrape_task = ScrapeTask.new(scrape_task_params.merge({ status: :pending }))
    if @scrape_task.save
      ScrapingJob.perform_async(@scrape_task.id)
      render json: { message: "Scrape task created successfully" }, status: :created
    else
      render json: { errors: @scrape_task.errors }, status: :unprocessable_entity
    end
  end

  private

  def scrape_task_params
    params.require(:scraping_task).permit(:task_id, :url)
  end
end
