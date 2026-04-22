class AttendanceRecordPolicy < ApplicationPolicy
  def upsert?
    PracticeSessionPolicy.new(context, record.practice_session).attendance?
  end

  class Scope < Scope
    def resolve
      return scope.all if admin?

      session_ids = PracticeSessionPolicy::Scope
        .new(PunditContext.new(user: user, academy: academy, role: role), PracticeSession)
        .resolve
        .select(:id)

      scope.where(practice_session_id: session_ids)
    end

    private

    def admin?
      role == "owner" || role == "admin"
    end
  end

  private

  def context
    PunditContext.new(user: user, academy: academy, role: role)
  end
end

