module Admin
  class ApplicationController < ApplicationController
    include Authentication   # Rails 8 generated concern
    layout "admin"

    before_action :require_authentication, except: %i[new create]
    before_action :require_superadmin, except: %i[new create]

    private

    def require_superadmin
      unless current_user&.superadmin?
        flash[:alert] = "Superadmin access required."
        redirect_to www_root_path
      end
    end

    # Administrate calls current_user internally — provide it via Current.
    def current_user
      Current.user
    end

    # Opt out of Pundit for the superadmin namespace.
    # Superadmins can see and do everything by definition.
    def pundit_user
      current_user
    end
  end
end
