class InvitationMailer < ApplicationMailer
  # Send a token-based invitation email.
  # The recipient clicks the link to accept — no password required at this stage.
  def invite(invitation)
    @invitation  = invitation
    @academy     = invitation.academy
    @inviter     = invitation.invited_by
    @accept_url  = accept_invitation_url(
      invitation.token,
      host:     "#{@academy.slug}.nubbe.net",
      protocol: Rails.env.production? ? "https" : "http"
    )

    mail(
      to:      invitation.email,
      subject: "You've been invited to join #{@academy.name} on SuperOnce"
    )
  end
end
