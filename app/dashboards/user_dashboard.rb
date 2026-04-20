require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id:            Field::String,
    email_address: Field::String,
    superadmin:    Field::Boolean,
    memberships:   Field::HasMany,
    created_at:    Field::DateTime,
    updated_at:    Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[email_address superadmin created_at].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id email_address superadmin memberships created_at updated_at
  ].freeze

  # Never expose password_digest in the form — omit it entirely.
  FORM_ATTRIBUTES = %i[email_address superadmin].freeze

  COLLECTION_FILTERS = {}.freeze
end
