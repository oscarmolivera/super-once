class InvitationsController < ApplicationController
  # Accept and confirm are PUBLIC — the token is the credential.
  # allow_unauthenticated_access is the Rails 8 way to skip require_authentication.
  allow_unauthenticated_access only: %i[accept confirm]
  skip_before_action :set_current_academy,      only: %i[accept confirm]
  skip_before_action :verify_tenant_membership, only: %i[accept confirm]
  after_action :skip_authorization,             only: %i[accept confirm]

  # ── Authenticated actions ─────────────────────────────────────

  def new
    @invitation = Invitation.new
    authorize @invitation
  end

  def create
    @invitation = Invitation.new(invitation_params.merge(
      academy:    current_academy,
      invited_by: Current.user
    ))
    authorize @invitation

    if @invitation.save
      InvitationMailer.invite(@invitation).deliver_later
      redirect_to memberships_path, notice: "Invitation sent to #{@invitation.email}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # ── Public token actions ──────────────────────────────────────

  def accept
    @invitation = find_invitation
    @academy    = @invitation&.academy
  end

  def confirm
    @invitation = find_invitation
    @academy    = @invitation&.academy

    unless @invitation
      redirect_to "https://www.nubbe.net", alert: "This invitation is invalid or has expired."
      return
    end

    unless Current.user
      redirect_to new_session_path(invite: params[:token])
      return
    end

    if @invitation.accept!(Current.user)
      redirect_to "http://#{@academy.full_domain}",
        notice: "Welcome to #{@academy.name}!"
    else
      flash.now[:alert] = "Could not accept invitation. You may already be a member."
      render :accept, status: :unprocessable_entity
    end
  end

  private

  def find_invitation
    inv = Invitation.find_by(token: params[:token])
    inv&.pending? ? inv : nil
  end

  def invitation_params
    params.require(:invitation).permit(:email, :role)
  end
end
