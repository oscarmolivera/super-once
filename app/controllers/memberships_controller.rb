class MembershipsController < ApplicationController
  before_action :set_membership, only: %i[destroy]

  def index
    @memberships = policy_scope(Membership)
      .includes(:user)
      .order(role: :desc, created_at: :asc)
    authorize Membership
  end

  def new
    @membership = Membership.new
    authorize @membership
  end

  def create
    @user = User.find_by(email_address: membership_params[:email_address]&.downcase)

    if @user.nil?
      redirect_to memberships_path, alert: "No user found with that email address."
      return
    end

    @membership = Membership.new(
      academy: current_academy,
      user:    @user,
      role:    membership_params[:role]
    )
    authorize @membership

    if @membership.save
      redirect_to memberships_path, notice: "#{@user.email_address} has been added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @membership
    @membership.destroy
    redirect_to memberships_path, notice: "Member removed."
  end

  private

  def set_membership
    @membership = policy_scope(Membership).find(params[:id])
  end

  def membership_params
    params.require(:membership).permit(:email_address, :role)
  end
end
