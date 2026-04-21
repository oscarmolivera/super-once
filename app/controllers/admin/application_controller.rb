module Admin
  class ApplicationController < Administrate::ApplicationController
    include Authentication   # Rails 8 generated concern

    before_action :require_authentication
    before_action :require_superadmin

    private

    def require_superadmin
      unless Current.user&.superadmin?
        flash[:alert] = "Superadmin access required."
        redirect_to root_path, status: :see_other
      end
    end

    # Administrate calls current_user internally — provide it via Current.
    def current_user
      Current.user
    end

    def pundit_user
      Current.user
    end
  end
end
