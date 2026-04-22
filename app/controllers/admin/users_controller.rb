module Admin
  class UsersController < Admin::ApplicationController
    def index
      @users = User.includes(:academies).order(:created_at).page(params[:page]).per(20)
    end
  end
end
