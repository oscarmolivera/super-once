class ProfileController < ApplicationController
  def show
    authorize :profile, :show?
    @user = current.user
  end

  def edit
    authorize :profile, :edit?
    @user = current.user
  end

  def update
    authorize :profile, :update?
    @user = current.user

    if profile_params[:password].present?
      unless @user.authenticate(profile_params[:current_password])
        @user.errors.add(:current_password, "is incorrect")
        render :edit, status: :unprocessable_entity and return
      end
    end

    if @user.update(allowed_params)
      redirect_to profile_path, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(
      :full_name, :email_address,
      :current_password, :password, :password_confirmation
    )
  end

  # Only pass password attributes if the user is actually changing their password
  def allowed_params
    attrs = profile_params.slice(:full_name, :email_address)
    if profile_params[:password].present?
      attrs.merge!(
        password:              profile_params[:password],
        password_confirmation: profile_params[:password_confirmation]
      )
    end
    attrs
  end
end
