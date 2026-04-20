require "administrate/base_dashboard"

class AcademyDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id:         Field::String,
    name:       Field::String,
    slug:       Field::String,
    plan:       Field::Select.with_options(
                  searchable: false,
                  collection: ->(field) { field.resource.class.plans.keys }
                ),
    status:     Field::Select.with_options(
                  searchable: false,
                  collection: ->(field) { field.resource.class.statuses.keys }
                ),
    sport_type: Field::String,
    memberships: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[name slug plan status created_at].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id name slug plan status sport_type
    memberships created_at updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[name slug plan status sport_type].freeze

  COLLECTION_FILTERS = {}.freeze
end
