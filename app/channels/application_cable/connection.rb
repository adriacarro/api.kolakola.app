module ApplicationCable
  class Connection < ActionCable::Connection::Base
    # identified_by :current_user

    # def connect
    #   self.current_user = find_verified_user
    # end

    # protected

    #   def find_verified_user
    #     puts "Connection cookies.signed[:user_id] > #{cookies.signed[:user_id]}"
    #     if verified_user = User.find_by(id: cookies.signed[:user_id]) # Session cannot be accessed from here
    #       verified_user
    #     else
    #       reject_unauthorized_connection
    #     end
    #   end
  end
end
