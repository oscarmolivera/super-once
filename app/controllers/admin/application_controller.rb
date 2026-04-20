# All Administrate controllers inherit from this
# `Administrate::ApplicationController`, making it the ideal place to put
# authentication logic or other before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  class ApplicationController < Administrate::ApplicationController
    include Authentication
    before_action :authenticate_admin
    before_action :require_superadmin

    def authenticate_admin
      # TODO Add authentication logic here.
    end

    private

    def require_superadmin
      unless current_user&.superadmin?
        flash[:alert] = "Superadmin access required."
        redirect_to "https://www.nubbe.net"
      end
    end

    # Opt out of Pundit for the superadmin namespace.
    # Superadmins can see and do everything by definition.
    def pundit_user
      current_user
    end
  end
end
