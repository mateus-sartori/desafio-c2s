class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: %i[ show edit update destroy ]

  def index
    @tasks = Task.where(user_id: current_user.id)

    Task.preload_users(@tasks)

    render inertia: {
      tasks: @tasks.order(:id)
    }
  end

  def show
  end

  def new
    @task = Task.new
  end

  def edit
  end

  def create
    @task = Task.new(task_params.merge({ status: :pending, user_id: current_user.id  }))

    begin
      @task.save!
      ScrapingProcessorClient.call.scrap_task(@task)
      redirect_to tasks_path
    rescue StandardError => e
      @task.update(status: :failed, error_message: e.message)
      render inertia: "tasks/index", props: { errors: @task.errors }, status: :unprocessable_entity
    end
  end

  def update
    @task.update!(task_params)
    render inertia: "tasks/index", props: { task: @task }
  rescue StandardError => e
    @task.update(status: :failed, error_message: e.message)
    render inertia: "tasks/index", props: { errors: @task.errors }, status: :unprocessable_entity
  end

  def destroy
    @task.destroy!

    respond_to do |format|
      format.html { redirect_to tasks_path, notice: "Task was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    def set_task
      @task = Task.where(user_id: current_user.id).find(params[:id])
    end

    def task_params
      params.require(:task).permit(:title, :url, :status, :result, :error_message)
    end
end
