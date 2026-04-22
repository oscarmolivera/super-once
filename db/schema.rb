# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_22_162613) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "academies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "city"
    t.string "country", default: "ES"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "logo_url"
    t.string "name", null: false
    t.string "phone"
    t.integer "plan", default: 0, null: false
    t.string "primary_color", default: "#4f46e5"
    t.string "slug", null: false
    t.string "sport_type", default: "soccer", null: false
    t.integer "status", default: 0, null: false
    t.date "trial_ends_on"
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["plan"], name: "index_academies_on_plan"
    t.index ["slug"], name: "index_academies_on_slug", unique: true
    t.index ["status"], name: "index_academies_on_status"
  end

  create_table "announcements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academy_id", null: false
    t.text "body"
    t.uuid "category_id"
    t.datetime "created_at", null: false
    t.datetime "published_at"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["academy_id", "category_id", "published_at"], name: "idx_on_academy_id_category_id_published_at_2444051ef8"
    t.index ["academy_id"], name: "index_announcements_on_academy_id"
    t.index ["category_id"], name: "index_announcements_on_category_id"
  end

  create_table "attendance_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academy_id", null: false
    t.datetime "created_at", null: false
    t.text "notes"
    t.uuid "player_id", null: false
    t.uuid "practice_session_id", null: false
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["academy_id", "practice_session_id", "player_id"], name: "idx_attendance_records_unique", unique: true
    t.index ["academy_id"], name: "index_attendance_records_on_academy_id"
    t.index ["player_id"], name: "index_attendance_records_on_player_id"
    t.index ["practice_session_id"], name: "index_attendance_records_on_practice_session_id"
  end

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academy_id", null: false
    t.datetime "created_at", null: false
    t.integer "max_age"
    t.integer "min_age"
    t.string "name"
    t.uuid "sport_school_id", null: false
    t.datetime "updated_at", null: false
    t.index ["academy_id", "sport_school_id", "name"], name: "index_categories_on_academy_id_and_sport_school_id_and_name"
    t.index ["academy_id"], name: "index_categories_on_academy_id"
    t.index ["sport_school_id"], name: "index_categories_on_sport_school_id"
  end

  create_table "category_enrollments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academy_id", null: false
    t.uuid "category_id", null: false
    t.datetime "created_at", null: false
    t.date "ends_on"
    t.uuid "player_id", null: false
    t.date "starts_on"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["academy_id", "category_id", "player_id"], name: "idx_category_enrollments_unique", unique: true
    t.index ["academy_id"], name: "index_category_enrollments_on_academy_id"
    t.index ["category_id"], name: "index_category_enrollments_on_category_id"
    t.index ["player_id"], name: "index_category_enrollments_on_player_id"
  end

  create_table "coach_assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academy_id", null: false
    t.uuid "category_id", null: false
    t.datetime "created_at", null: false
    t.uuid "employee_id", null: false
    t.integer "role"
    t.datetime "updated_at", null: false
    t.index ["academy_id", "category_id", "employee_id"], name: "idx_coach_assignments_unique", unique: true
    t.index ["academy_id"], name: "index_coach_assignments_on_academy_id"
    t.index ["category_id"], name: "index_coach_assignments_on_category_id"
    t.index ["employee_id"], name: "index_coach_assignments_on_employee_id"
  end

  create_table "cup_teams", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academy_id", null: false
    t.uuid "category_id", null: false
    t.datetime "created_at", null: false
    t.string "name"
    t.uuid "tournament_id", null: false
    t.datetime "updated_at", null: false
    t.index ["academy_id", "tournament_id", "category_id"], name: "idx_on_academy_id_tournament_id_category_id_cf8e40a584", unique: true
    t.index ["academy_id"], name: "index_cup_teams_on_academy_id"
    t.index ["category_id"], name: "index_cup_teams_on_category_id"
    t.index ["tournament_id"], name: "index_cup_teams_on_tournament_id"
  end

  create_table "cups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academy_id", null: false
    t.datetime "created_at", null: false
    t.string "name"
    t.string "organizer"
    t.boolean "recurring", default: true, null: false
    t.string "sport_type"
    t.datetime "updated_at", null: false
    t.index ["academy_id", "sport_type", "name"], name: "index_cups_on_academy_id_and_sport_type_and_name", unique: true
    t.index ["academy_id"], name: "index_cups_on_academy_id"
  end

  create_table "employees", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academy_id", null: false
    t.decimal "base_salary", precision: 10, scale: 2, default: "0.0"
    t.date "birth_date"
    t.datetime "created_at", null: false
    t.string "document_number"
    t.string "email"
    t.integer "employee_type", default: 0, null: false
    t.string "full_name", null: false
    t.date "hire_date"
    t.string "notes"
    t.string "phone"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["academy_id", "employee_type"], name: "index_employees_on_academy_id_and_employee_type"
    t.index ["academy_id", "status"], name: "index_employees_on_academy_id_and_status"
    t.index ["academy_id", "user_id"], name: "index_employees_on_academy_id_and_user_id", unique: true, where: "(user_id IS NOT NULL)"
    t.index ["academy_id"], name: "index_employees_on_academy_id"
    t.index ["user_id"], name: "index_employees_on_user_id"
  end

  create_table "income_expenses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academy_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.integer "category", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.integer "kind", default: 0, null: false
    t.date "recorded_on", null: false
    t.string "reference"
    t.datetime "updated_at", null: false
    t.index ["academy_id", "category"], name: "index_income_expenses_on_academy_id_and_category"
    t.index ["academy_id", "kind"], name: "index_income_expenses_on_academy_id_and_kind"
    t.index ["academy_id", "recorded_on"], name: "index_income_expenses_on_academy_id_and_recorded_on"
    t.index ["academy_id"], name: "index_income_expenses_on_academy_id"
  end

  create_table "inventory_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academy_id", null: false
    t.date "acquired_on"
    t.integer "category", default: 0, null: false
    t.integer "condition", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.string "location"
    t.string "name", null: false
    t.integer "quantity", default: 0, null: false
    t.decimal "unit_value", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["academy_id", "category"], name: "index_inventory_items_on_academy_id_and_category"
    t.index ["academy_id", "condition"], name: "index_inventory_items_on_academy_id_and_condition"
    t.index ["academy_id"], name: "index_inventory_items_on_academy_id"
  end

  create_table "invitations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academy_id", null: false
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "expires_at", null: false
    t.bigint "invited_by_id", null: false
    t.integer "role", default: 0, null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["academy_id", "email"], name: "index_invitations_on_academy_id_and_email", unique: true
    t.index ["academy_id"], name: "index_invitations_on_academy_id"
    t.index ["expires_at"], name: "index_invitations_on_expires_at"
    t.index ["invited_by_id"], name: "index_invitations_on_invited_by_id"
    t.index ["token"], name: "index_invitations_on_token", unique: true
  end

  create_table "matches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academy_id", null: false
    t.integer "away_score"
    t.datetime "created_at", null: false
    t.uuid "cup_team_id", null: false
    t.boolean "home", default: true, null: false
    t.integer "home_score"
    t.text "notes"
    t.string "opponent_name"
    t.datetime "starts_at"
    t.integer "status", default: 0, null: false
    t.uuid "tournament_id", null: false
    t.datetime "updated_at", null: false
    t.string "venue"
    t.index ["academy_id", "tournament_id", "starts_at"], name: "index_matches_on_academy_id_and_tournament_id_and_starts_at"
    t.index ["academy_id"], name: "index_matches_on_academy_id"
    t.index ["cup_team_id"], name: "index_matches_on_cup_team_id"
    t.index ["tournament_id"], name: "index_matches_on_tournament_id"
  end

  create_table "memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academy_id", null: false
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.datetime "invited_at"
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["academy_id", "user_id"], name: "index_memberships_on_academy_id_and_user_id", unique: true
    t.index ["academy_id"], name: "index_memberships_on_academy_id"
    t.index ["role"], name: "index_memberships_on_role"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "player_payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academy_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.date "due_on", null: false
    t.integer "month", null: false
    t.string "notes"
    t.date "paid_on"
    t.string "player_name", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "year", null: false
    t.index ["academy_id", "due_on"], name: "index_player_payments_on_academy_id_and_due_on"
    t.index ["academy_id", "status"], name: "index_player_payments_on_academy_id_and_status"
    t.index ["academy_id", "year", "month"], name: "index_player_payments_on_academy_id_and_year_and_month"
    t.index ["academy_id"], name: "index_player_payments_on_academy_id"
  end

  create_table "players", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academy_id", null: false
    t.date "birth_date"
    t.datetime "created_at", null: false
    t.string "first_name"
    t.string "guardian_email"
    t.string "guardian_name"
    t.string "guardian_phone"
    t.string "last_name"
    t.string "photo_url"
    t.datetime "updated_at", null: false
    t.index ["academy_id"], name: "index_players_on_academy_id"
  end

  create_table "practice_sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academy_id", null: false
    t.uuid "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "ends_at"
    t.string "location"
    t.text "notes"
    t.datetime "starts_at"
    t.datetime "updated_at", null: false
    t.index ["academy_id", "category_id", "starts_at"], name: "idx_on_academy_id_category_id_starts_at_ec5d43bb0a"
    t.index ["academy_id"], name: "index_practice_sessions_on_academy_id"
    t.index ["category_id"], name: "index_practice_sessions_on_category_id"
  end

  create_table "salaries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academy_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.uuid "employee_id", null: false
    t.integer "month", null: false
    t.string "notes"
    t.date "paid_on"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "year", null: false
    t.index ["academy_id", "employee_id", "month", "year"], name: "idx_salaries_employee_period", unique: true
    t.index ["academy_id", "status"], name: "index_salaries_on_academy_id_and_status"
    t.index ["academy_id", "year", "month"], name: "index_salaries_on_academy_id_and_year_and_month"
    t.index ["academy_id"], name: "index_salaries_on_academy_id"
    t.index ["employee_id"], name: "index_salaries_on_employee_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "sport_schools", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academy_id", null: false
    t.datetime "created_at", null: false
    t.string "name"
    t.string "sport_type"
    t.datetime "updated_at", null: false
    t.index ["academy_id"], name: "index_sport_schools_on_academy_id"
  end

  create_table "tax_permits", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academy_id", null: false
    t.datetime "created_at", null: false
    t.integer "document_type", default: 0, null: false
    t.date "expires_on"
    t.date "issued_on"
    t.string "issuing_authority"
    t.string "name", null: false
    t.string "notes"
    t.string "reference_number"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["academy_id", "document_type"], name: "index_tax_permits_on_academy_id_and_document_type"
    t.index ["academy_id", "expires_on"], name: "index_tax_permits_on_academy_id_and_expires_on"
    t.index ["academy_id", "status"], name: "index_tax_permits_on_academy_id_and_status"
    t.index ["academy_id"], name: "index_tax_permits_on_academy_id"
  end

  create_table "team_players", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academy_id", null: false
    t.datetime "created_at", null: false
    t.uuid "cup_team_id", null: false
    t.integer "jersey_number"
    t.uuid "player_id", null: false
    t.string "position"
    t.datetime "updated_at", null: false
    t.index ["academy_id", "cup_team_id", "jersey_number"], name: "idx_on_academy_id_cup_team_id_jersey_number_7f2ca91a33", unique: true, where: "(jersey_number IS NOT NULL)"
    t.index ["academy_id", "cup_team_id", "player_id"], name: "index_team_players_on_academy_id_and_cup_team_id_and_player_id", unique: true
    t.index ["academy_id"], name: "index_team_players_on_academy_id"
    t.index ["cup_team_id"], name: "index_team_players_on_cup_team_id"
    t.index ["player_id"], name: "index_team_players_on_player_id"
  end

  create_table "tournaments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academy_id", null: false
    t.datetime "created_at", null: false
    t.uuid "cup_id", null: false
    t.date "ends_on"
    t.string "location"
    t.date "starts_on"
    t.datetime "updated_at", null: false
    t.integer "year"
    t.index ["academy_id", "cup_id", "year"], name: "index_tournaments_on_academy_id_and_cup_id_and_year", unique: true
    t.index ["academy_id"], name: "index_tournaments_on_academy_id"
    t.index ["cup_id"], name: "index_tournaments_on_cup_id"
  end

  create_table "training_plans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academy_id", null: false
    t.text "body"
    t.uuid "category_id", null: false
    t.datetime "created_at", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["academy_id"], name: "index_training_plans_on_academy_id"
    t.index ["category_id"], name: "index_training_plans_on_category_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "full_name"
    t.string "password_digest", null: false
    t.boolean "superadmin", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["superadmin"], name: "index_users_on_superadmin", where: "(superadmin = true)"
  end

  add_foreign_key "announcements", "academies"
  add_foreign_key "announcements", "categories"
  add_foreign_key "attendance_records", "academies"
  add_foreign_key "attendance_records", "players"
  add_foreign_key "attendance_records", "practice_sessions"
  add_foreign_key "categories", "academies"
  add_foreign_key "categories", "sport_schools"
  add_foreign_key "category_enrollments", "academies"
  add_foreign_key "category_enrollments", "categories"
  add_foreign_key "category_enrollments", "players"
  add_foreign_key "coach_assignments", "academies"
  add_foreign_key "coach_assignments", "categories"
  add_foreign_key "coach_assignments", "employees"
  add_foreign_key "cup_teams", "academies"
  add_foreign_key "cup_teams", "categories"
  add_foreign_key "cup_teams", "tournaments"
  add_foreign_key "cups", "academies"
  add_foreign_key "employees", "academies"
  add_foreign_key "employees", "users"
  add_foreign_key "income_expenses", "academies"
  add_foreign_key "inventory_items", "academies"
  add_foreign_key "invitations", "academies"
  add_foreign_key "invitations", "users", column: "invited_by_id"
  add_foreign_key "matches", "academies"
  add_foreign_key "matches", "cup_teams"
  add_foreign_key "matches", "tournaments"
  add_foreign_key "memberships", "academies"
  add_foreign_key "memberships", "users"
  add_foreign_key "player_payments", "academies"
  add_foreign_key "players", "academies"
  add_foreign_key "practice_sessions", "academies"
  add_foreign_key "practice_sessions", "categories"
  add_foreign_key "salaries", "academies"
  add_foreign_key "salaries", "employees"
  add_foreign_key "sessions", "users"
  add_foreign_key "sport_schools", "academies"
  add_foreign_key "tax_permits", "academies"
  add_foreign_key "team_players", "academies"
  add_foreign_key "team_players", "cup_teams"
  add_foreign_key "team_players", "players"
  add_foreign_key "tournaments", "academies"
  add_foreign_key "tournaments", "cups"
  add_foreign_key "training_plans", "academies"
  add_foreign_key "training_plans", "categories"
end
