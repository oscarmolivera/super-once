module Onboarding
  class Step1Form
    include ActiveModel::Model

    attr_accessor :academy_name, :slug, :sport

    validates :academy_name, presence: true, length: { minimum: 2, maximum: 100 }
    validates :slug, presence: true,
              format: { with: /\A[a-z0-9\-]+\z/, message: "only lowercase letters, numbers and hyphens" },
              length: { minimum: 3, maximum: 63 },
              uniqueness: { class_name: 'Academy', message: 'is already taken' }

    def attributes
      { academy_name: academy_name, slug: slug, sport: sport }
    end
  end

  class Step2Form
    include ActiveModel::Model

    attr_accessor :sport

    validates :sport, presence: true, inclusion: { in: %w[soccer basketball volleyball rugby] }

    def attributes
      { sport: sport }
    end
  end

  class Step3Form
    include ActiveModel::Model

    attr_accessor :plan_id

    validates :plan_id, presence: true

    def plan
      @plan ||= Plan.find(plan_id)
    end

    def attributes
      { plan_id: plan_id }
    end
  end

  class Step4Form
    include ActiveModel::Model

    attr_accessor :first_name, :last_name, :email, :password, :password_confirmation

    validates :first_name, presence: true, length: { minimum: 2 }
    validates :last_name, presence: true, length: { minimum: 2 }
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :password, presence: true, length: { minimum: 8 }
    validates :password_confirmation, presence: true
    validate :passwords_match

    def attributes
      {
        first_name: first_name,
        last_name: last_name,
        email: email,
        password: password
      }
    end

    private

    def passwords_match
      if password != password_confirmation
        errors.add(:password_confirmation, "doesn't match password")
      end
    end
  end
end
