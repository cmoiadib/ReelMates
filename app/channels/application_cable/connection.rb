module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_or_guest_user

    def connect
      self.current_or_guest_user = find_verified_user
      logger.add_tags 'ActionCable', current_or_guest_user.id
    end

    private

    def find_verified_user
      if env['warden'].user
        env['warden'].user
      else
        # Allow guest users or implement your guest user logic here
        User.find_by(id: cookies.signed[:guest_user_id]) || reject_unauthorized_connection
      end
    end
  end
end
