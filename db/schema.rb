# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160216013030) do

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "bom_items", force: :cascade do |t|
    t.integer  "quantity",    limit: 4
    t.string   "description", limit: 255
    t.text     "part_code",   limit: 65535
    t.integer  "bom_id",      limit: 4
    t.integer  "product_id",  limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.boolean  "warn",        limit: 1
    t.integer  "user_id",     limit: 4
    t.boolean  "danger",      limit: 1
    t.boolean  "manual",      limit: 1
    t.boolean  "mark",        limit: 1
    t.string   "mpn",         limit: 255
    t.integer  "mpn_id",      limit: 4
  end

  create_table "boms", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.string   "excel_file",  limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "user_id",     limit: 4
  end

  add_index "boms", ["name"], name: "name", using: :btree
  add_index "boms", ["user_id"], name: "uid", using: :btree

  create_table "keywords", force: :cascade do |t|
    t.string   "keywords",   limit: 255
    t.string   "ip",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mpn_items", force: :cascade do |t|
    t.string   "mpn",                    limit: 255
    t.string   "manufacturer",           limit: 255
    t.string   "authorized_distributor", limit: 255
    t.string   "description",            limit: 255
    t.string   "datasheets",             limit: 255
    t.string   "price",                  limit: 255
    t.string   "last_update",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mpn_items", ["mpn"], name: "mpn", using: :btree

  create_table "parts", force: :cascade do |t|
    t.string   "part_code",  limit: 255
    t.string   "part_name",  limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "products", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.string   "description",       limit: 255
    t.float    "price",             limit: 24,  default: 0.0
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "part_name",         limit: 255
    t.string   "part_name_en",      limit: 255
    t.integer  "product_able_id",   limit: 4
    t.string   "product_able_type", limit: 255
    t.integer  "prefer",            limit: 4,   default: 0
    t.boolean  "delta",             limit: 1,   default: true,      null: false
    t.string   "ptype",             limit: 255, default: "default"
    t.string   "package1",          limit: 255, default: "default"
    t.string   "package2",          limit: 255, default: "default"
    t.string   "value1",            limit: 255
    t.string   "value2",            limit: 255
    t.string   "value3",            limit: 255
    t.string   "value4",            limit: 255
    t.string   "value5",            limit: 255
    t.string   "value6",            limit: 255
    t.string   "value7",            limit: 255
    t.string   "value8",            limit: 255
  end

  add_index "products", ["name"], name: "name", using: :btree
  add_index "products", ["package2"], name: "package2", using: :btree
  add_index "products", ["product_able_id", "product_able_type"], name: "index_products_on_product_able_id_and_product_able_type", using: :btree

  create_table "products_price", force: :cascade do |t|
    t.string "name",  limit: 255
    t.float  "price", limit: 24
  end

  add_index "products_price", ["name"], name: "name", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "resource_id",   limit: 4
    t.string   "resource_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "translate", force: :cascade do |t|
    t.string "translate_cn", limit: 255
    t.string "translate_en", limit: 255
  end

  create_table "units", force: :cascade do |t|
    t.string   "unit",       limit: 255
    t.string   "targetunit", limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id", limit: 4
    t.integer "role_id", limit: 4
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

end
