class Api::V1::UsersController < ApplicationController
  before_action :set_user, only: [ :show ]

  def index
    if params[:ids]
      users = User.where(id: params[:ids])
    else
      users = User.all
    end

    render json: users
  end


  def show
    render json: @user, status: :ok
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
