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

ActiveRecord::Schema[8.1].define(version: 2026_04_20_215821) do
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

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
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

  add_foreign_key "invitations", "academies"
  add_foreign_key "invitations", "users", column: "invited_by_id"
  add_foreign_key "memberships", "academies"
  add_foreign_key "memberships", "users"
  add_foreign_key "sessions", "users"
end
