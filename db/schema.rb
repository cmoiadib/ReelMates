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

ActiveRecord::Schema[7.1].define(version: 2024_12_03_102024) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "movies", force: :cascade do |t|
    t.string "title"
    t.text "overview"
    t.string "poster_url"
    t.float "rating"
    t.integer "genres"
    t.integer "mvdb_id"
    t.bigint "party_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["party_id"], name: "index_movies_on_party_id"
  end

  create_table "parties", force: :cascade do |t|
    t.string "party_code"
    t.string "platform_setting", default: [], array: true
    t.integer "start_year"
    t.integer "end_year"
    t.string "category_setting", default: [], array: true
    t.boolean "start"
    t.string "tags", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "movies", default: [], array: true
    t.jsonb "final_movies", default: [], null: false
    t.index ["user_id"], name: "index_parties_on_user_id"
  end

  create_table "party_players", force: :cascade do |t|
    t.bigint "party_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "movies", default: [], array: true
    t.index ["party_id"], name: "index_party_players_on_party_id"
    t.index ["user_id"], name: "index_party_players_on_user_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.text "channel"
    t.text "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "swipes", force: :cascade do |t|
    t.integer "movie_id"
    t.boolean "is_liked"
    t.string "tags", default: [], array: true
    t.bigint "party_player_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["party_player_id"], name: "index_swipes_on_party_player_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "saved_settings", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "guest", default: false
    t.string "avatar", default: "default_avatar.png"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "movies", "parties"
  add_foreign_key "parties", "users"
  add_foreign_key "party_players", "parties"
  add_foreign_key "party_players", "users"
  add_foreign_key "swipes", "party_players"
end
