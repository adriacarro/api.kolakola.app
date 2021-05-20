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

ActiveRecord::Schema.define(version: 2021_05_20_205652) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "addresses", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "street_1"
    t.string "street_2"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "country_code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "categories", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.json "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "lines", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "service_id"
    t.uuid "customer_id"
    t.uuid "worker_id"
    t.string "code"
    t.integer "status", default: 0
    t.integer "position"
    t.integer "queueing_time", default: 0
    t.integer "serving_time", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "pending_time", default: 0
    t.index ["customer_id"], name: "index_lines_on_customer_id"
    t.index ["service_id"], name: "index_lines_on_service_id"
    t.index ["worker_id"], name: "index_lines_on_worker_id"
  end

  create_table "logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "loggable_type", null: false
    t.uuid "loggable_id", null: false
    t.uuid "user_id", null: false
    t.integer "action", default: 0
    t.jsonb "log_changes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["loggable_type", "loggable_id"], name: "index_logs_on_loggable"
    t.index ["user_id"], name: "index_logs_on_user_id"
  end

  create_table "places", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "category_id", null: false
    t.uuid "billing_address_id", null: false
    t.uuid "address_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["address_id"], name: "index_places_on_address_id"
    t.index ["billing_address_id"], name: "index_places_on_billing_address_id"
    t.index ["category_id"], name: "index_places_on_category_id"
  end

  create_table "promotions", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "place_id", null: false
    t.json "title"
    t.json "message"
    t.integer "position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["place_id"], name: "index_promotions_on_place_id"
  end

  create_table "ratings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.string "rateable_type"
    t.uuid "rateable_id"
    t.integer "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["rateable_type", "rateable_id"], name: "index_ratings_on_rateable"
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "services", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "place_id", null: false
    t.json "name"
    t.integer "avg_serving_time", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["place_id"], name: "index_services_on_place_id"
  end

  create_table "user_services", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "service_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["service_id"], name: "index_user_services_on_service_id"
    t.index ["user_id"], name: "index_user_services_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.integer "role", default: 0
    t.string "cookie"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.integer "notification_type", default: 0
    t.string "phone"
    t.boolean "active", default: true
    t.uuid "place_id"
    t.string "password_digest"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "locked_at"
    t.integer "failed_attempts", default: 0
    t.integer "sign_in_count", default: 0
    t.datetime "sign_in_at"
    t.datetime "invited_at"
    t.string "invite_token"
    t.boolean "invite_accepted", default: false
    t.datetime "invite_accepted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "log_out_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["place_id"], name: "index_users_on_place_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "lines", "services"
  add_foreign_key "lines", "users", column: "customer_id"
  add_foreign_key "lines", "users", column: "worker_id"
  add_foreign_key "logs", "users"
  add_foreign_key "places", "addresses"
  add_foreign_key "places", "addresses", column: "billing_address_id"
  add_foreign_key "places", "categories"
  add_foreign_key "promotions", "places"
  add_foreign_key "ratings", "users"
  add_foreign_key "services", "places"
  add_foreign_key "user_services", "services"
  add_foreign_key "user_services", "users"
  add_foreign_key "users", "places"
end
