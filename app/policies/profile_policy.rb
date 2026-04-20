# Symbol-backed policy: authorize :profile, :show?
class ProfilePolicy < ApplicationPolicy
  def show?   = member?
  def edit?   = member?
  def update? = member?
end
