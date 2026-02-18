module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user_id

    def connect
      self.current_user_id = request.params[:user_id]

      reject_unauthorized_connection unless current_user_id.present?
    end
  end
end
