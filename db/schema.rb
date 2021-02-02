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

ActiveRecord::Schema.define(version: 2021_02_02_135606) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "auto_tweets", force: :cascade do |t|
    t.text "body"
    t.datetime "last_tweeted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "callcategories", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
    t.integer "sort_order"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "callers", force: :cascade do |t|
    t.string "from_phone"
    t.string "city"
    t.string "from_city"
    t.string "zip"
    t.string "state"
    t.string "from_state"
    t.string "phone"
    t.string "from_zip"
    t.string "country"
    t.string "from_country"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "blocked", default: false, null: false
  end

  create_table "calls", force: :cascade do |t|
    t.string "twilio_id"
    t.integer "length"
    t.integer "caller_id"
    t.integer "operator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "answered_at"
    t.string "twilio_recording_url"
    t.integer "recording_duration"
    t.string "forwarded_to"
    t.string "token"
    t.datetime "sms_caller_for_review_at"
    t.text "notes"
    t.bigint "callcategory_id"
    t.index ["callcategory_id"], name: "index_calls_on_callcategory_id"
    t.index ["operator_id"], name: "index_calls_on_operator_id"
    t.index ["token"], name: "index_calls_on_token"
  end

  create_table "calls_sponsors", id: false, force: :cascade do |t|
    t.integer "call_id"
    t.integer "sponsor_id"
    t.index ["call_id"], name: "index_calls_sponsors_on_call_id"
    t.index ["sponsor_id"], name: "index_calls_sponsors_on_sponsor_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "user_id"
    t.integer "call_id"
    t.text "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["call_id"], name: "index_comments_on_call_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.text "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oncall_schedules", force: :cascade do |t|
    t.integer "user_id"
    t.integer "wday"
    t.string "start_time"
    t.string "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outgoing_calls", force: :cascade do |t|
    t.integer "call_id"
    t.integer "operator_id"
    t.string "twilio_id"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["call_id"], name: "index_outgoing_calls_on_call_id"
    t.index ["operator_id"], name: "index_outgoing_calls_on_operator_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "call_id"
    t.string "name"
    t.string "email"
    t.string "twitter"
    t.text "question"
    t.text "answer"
    t.string "happiness"
    t.datetime "tweeted_at"
    t.datetime "sms_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "public", default: true, null: false
    t.index ["call_id"], name: "index_review_on_call_id"
  end

  create_table "sponsors", force: :cascade do |t|
    t.integer "user_id"
    t.string "email"
    t.boolean "newsletter_emails", default: true, null: false
    t.boolean "need_help_emails", default: false, null: false
    t.boolean "default", default: false, null: false
    t.text "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "image_file_name"
    t.string "image_content_type"
    t.string "image_file_size"
    t.datetime "image_updated_at"
    t.decimal "amount", precision: 8, scale: 2, default: "20.0"
    t.string "stripe_token"
    t.string "stripe_customer_id"
    t.boolean "successful", default: false, null: false
    t.text "stripe_response"
    t.decimal "fee", precision: 8, scale: 2
    t.integer "minutes_purchased"
    t.integer "minutes_remaining"
    t.text "url"
    t.string "token"
    t.string "auth_token"
    t.string "card_type"
    t.string "last_numbers"
    t.string "stripe_charge_id"
    t.text "name"
    t.index ["user_id"], name: "index_sponsors_on_user_id"
  end

  create_table "status_updates", force: :cascade do |t|
    t.integer "user_id"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_status_updates_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "phone"
    t.boolean "on_call", default: false
    t.boolean "admin", default: false
    t.text "bio"
    t.boolean "schedule_emails", default: true
    t.boolean "approved", default: false
    t.boolean "volunteers_first_availability_emails", default: true
    t.datetime "admins_notified_of_first_availability_at"
    t.string "name"
    t.string "twitter"
    t.datetime "deleted_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

end
