# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171107191541) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.integer "resource_id"
    t.string "resource_type"
    t.integer "author_id"
    t.string "author_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admins", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "table_job_types", force: :cascade do |t|
    t.string "job_type"
    t.text "description"
  end

  create_table "tivoli_histories", force: :cascade do |t|
    t.string "workstation"
    t.string "stream"
    t.string "job"
    t.string "server_run"
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.string "log"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tivoli_job_id"
    t.string "elapsed_time"
    t.index ["tivoli_job_id"], name: "index_tivoli_histories_on_tivoli_job_id"
  end

  create_table "tivoli_jobs", force: :cascade do |t|
    t.string "workstation"
    t.string "stream"
    t.string "job"
    t.string "server_run"
    t.string "schedule"
    t.string "script"
    t.string "user_id_run"
    t.string "dependency"
    t.string "stream_related"
  end

  create_table "workstations", force: :cascade do |t|
    t.string "name"
    t.integer "port"
    t.text "description"
    t.string "url"
  end

  add_foreign_key "tivoli_histories", "tivoli_jobs"
end
