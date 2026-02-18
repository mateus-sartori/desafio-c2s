class Api::V1::NotificationsController < ApplicationController
  def create
    NotificationsChannel.broadcast_to(
      "notification_room",
      {
        message: "Scraping #{params[:payload][:task_id]} finalizado!",
        event: params[:event],
        payload: params[:payload]
      }
    )

    head :ok
  end
end
