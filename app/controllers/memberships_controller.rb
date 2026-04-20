class MembershipsController < ApplicationController
  before_action :set_membership, only: %i[destroy promote]

  def index
    @memberships = policy_scope(Membership).includes(:user).order(role: :desc, created_at: :asc)
    @invitations = policy_scope(Invitation).includes(:invited_by).order(created_at: :desc) if policy(Invitation).index?
    authorize Membership
  end

  def new
    @membership = Membership.new
    authorize @membership
  end

  def create
    @user = User.find_by(email_address: membership_params[:email_address]&.downcase)

    unless @user
      redirect_to memberships_path, alert: "No account found for that email. Use 'Invite' to send them a link."
      return
    end

    @membership = Membership.new(academy: current_academy, user: @user, role: membership_params[:role])
    authorize @membership

    if @membership.save
      redirect_to memberships_path, notice: "#{@user.email_address} added as #{@membership.role}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @membership
    @membership.destroy
    redirect_to memberships_path, notice: "Member removed."
  end

  def promote
    authorize @membership, :update?
    new_role = params[:role]

    unless Membership.roles.key?(new_role)
      redirect_to memberships_path, alert: "Invalid role."
      return
    end

    @membership.update!(role: new_role)
    redirect_to memberships_path, notice: "#{@membership.user.email_address} is now #{new_role}."
  end

  private

  def set_membership
    @membership = policy_scope(Membership).find(params[:id])
  end

  def membership_params
    params.require(:membership).permit(:email_address, :role)
  end
end