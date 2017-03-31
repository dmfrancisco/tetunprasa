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

ActiveRecord::Schema.define(version: 20170331203119) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.string   "author_type"
    t.integer  "author_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree
  end

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "entries", force: :cascade do |t|
    t.integer "parent_id"
    t.text    "glossary_en"
    t.text    "info_en"
    t.string  "male_counterpart"
    t.string  "female_counterpart"
    t.string  "part_of_speech"
    t.string  "origin",                                       array: true
    t.string  "antonyms",                                     array: true
    t.string  "synonyms",                                     array: true
    t.string  "similar",                                      array: true
    t.string  "categories",                                   array: true
    t.string  "counterpart",                                  array: true
    t.string  "cross_references",                             array: true
    t.string  "variants",                                     array: true
    t.integer "pid",                             null: false
    t.integer "term_id",                         null: false
    t.text    "glossary_pt"
    t.text    "info_pt"
    t.string  "usage",              default: [], null: false, array: true
    t.index ["parent_id"], name: "index_entries_on_parent_id", using: :btree
    t.index ["pid"], name: "index_entries_on_pid", unique: true, using: :btree
    t.index ["term_id"], name: "index_entries_on_term_id", using: :btree
  end

  create_table "entries_examples", id: false, force: :cascade do |t|
    t.integer "entry_id",   null: false
    t.integer "example_id", null: false
    t.index ["entry_id", "example_id"], name: "index_entries_examples_on_entry_id_and_example_id", unique: true, using: :btree
    t.index ["entry_id"], name: "index_entries_examples_on_entry_id", using: :btree
    t.index ["example_id"], name: "index_entries_examples_on_example_id", using: :btree
  end

  create_table "examples", force: :cascade do |t|
    t.string   "tetun",      null: false
    t.string   "english",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "portuguese"
  end

  create_table "terms", force: :cascade do |t|
    t.string   "slug",       null: false
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_terms_on_name", unique: true, using: :btree
    t.index ["slug"], name: "index_terms_on_slug", unique: true, using: :btree
  end

end
