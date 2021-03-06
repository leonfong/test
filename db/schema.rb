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

ActiveRecord::Schema.define(version: 20160608071516) do

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

  create_table "all_dns", force: :cascade do |t|
    t.datetime "date",                                           null: false
    t.string   "dn",        limit: 255
    t.string   "dn_long",   limit: 255
    t.string   "part_code", limit: 255
    t.string   "des",       limit: 255
    t.integer  "qty",       limit: 4
    t.decimal  "price",                 precision: 20, scale: 6
  end

  add_index "all_dns", ["des"], name: "des", using: :btree
  add_index "all_dns", ["dn"], name: "dn", using: :btree
  add_index "all_dns", ["part_code"], name: "part_code", using: :btree
  add_index "all_dns", ["price"], name: "price", using: :btree

  create_table "all_parts", force: :cascade do |t|
    t.string   "mpn",        limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "billing_infos", force: :cascade do |t|
    t.integer "user_id",      limit: 4
    t.string  "first_name",   limit: 255
    t.string  "last_name",    limit: 255
    t.string  "address_line", limit: 255
    t.string  "postal_code",  limit: 255
    t.string  "email",        limit: 255
    t.string  "phone",        limit: 255
    t.string  "city",         limit: 255
    t.string  "country",      limit: 255
    t.string  "country_name", limit: 255
    t.string  "company",      limit: 255
  end

  add_index "billing_infos", ["user_id"], name: "user_id", using: :btree

  create_table "bom_items", force: :cascade do |t|
    t.integer  "quantity",    limit: 4
    t.string   "description", limit: 255
    t.text     "part_code",   limit: 65535
    t.integer  "bom_id",      limit: 4
    t.integer  "product_id",  limit: 4
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.boolean  "warn",        limit: 1
    t.integer  "user_id",     limit: 4
    t.boolean  "danger",      limit: 1
    t.boolean  "manual",      limit: 1
    t.boolean  "mark",        limit: 1
    t.string   "mpn",         limit: 255
    t.integer  "mpn_id",      limit: 4
    t.decimal  "price",                          precision: 10, scale: 4
    t.string   "mf",          limit: 255
    t.string   "dn",          limit: 255
    t.text     "other",       limit: 4294967295
  end

  create_table "boms", force: :cascade do |t|
    t.string   "no",           limit: 255
    t.string   "name",         limit: 255
    t.string   "p_name",       limit: 255
    t.integer  "qty",          limit: 4
    t.decimal  "t_p",                      precision: 10
    t.string   "d_day",        limit: 255
    t.string   "description",  limit: 255
    t.string   "excel_file",   limit: 255
    t.decimal  "pcb_p",                    precision: 10
    t.string   "pcb_file",     limit: 255
    t.string   "pcb_layer",    limit: 255
    t.integer  "pcb_qty",      limit: 4
    t.integer  "pcb_size_c",   limit: 4
    t.integer  "pcb_size_k",   limit: 4
    t.string   "pcb_sc",       limit: 255
    t.string   "pcb_material", limit: 255
    t.string   "pcb_cc",       limit: 255
    t.string   "pcb_ct",       limit: 255
    t.string   "pcb_sf",       limit: 255
    t.string   "pcb_t",        limit: 255
    t.integer  "t_c",          limit: 4
    t.decimal  "c_p",                      precision: 10
    t.integer  "user_id",      limit: 4
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "boms", ["name"], name: "name", using: :btree
  add_index "boms", ["user_id"], name: "uid", using: :btree

  create_table "e_boms", force: :cascade do |t|
    t.string   "check",        limit: 255
    t.string   "no",           limit: 255
    t.string   "name",         limit: 255
    t.string   "p_name",       limit: 255
    t.integer  "qty",          limit: 4
    t.decimal  "t_p",                             precision: 20
    t.integer  "profit",       limit: 4
    t.decimal  "t_pp",                            precision: 20
    t.string   "d_day",        limit: 255
    t.string   "description",  limit: 255
    t.string   "excel_file",   limit: 255
    t.decimal  "pcb_p",                           precision: 10
    t.string   "pcb_file",     limit: 255
    t.string   "pcb_layer",    limit: 255
    t.integer  "pcb_qty",      limit: 4
    t.integer  "pcb_size_c",   limit: 4
    t.integer  "pcb_size_k",   limit: 4
    t.string   "pcb_sc",       limit: 255
    t.string   "pcb_material", limit: 255
    t.string   "pcb_cc",       limit: 255
    t.string   "pcb_ct",       limit: 255
    t.string   "pcb_sf",       limit: 255
    t.string   "pcb_t",        limit: 255
    t.integer  "t_c",          limit: 4
    t.decimal  "c_p",                             precision: 20
    t.integer  "user_id",      limit: 4
    t.text     "all_title",    limit: 4294967295
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  create_table "e_dns", force: :cascade do |t|
    t.integer  "item_id",   limit: 4
    t.string   "part_code", limit: 255
    t.datetime "date",                                                  null: false
    t.string   "dn",        limit: 255
    t.string   "dn_long",   limit: 255
    t.decimal  "cost",                         precision: 20, scale: 6
    t.integer  "qty",       limit: 4
    t.string   "info",      limit: 255
    t.text     "remark",    limit: 4294967295
    t.string   "tag",       limit: 255
    t.string   "color",     limit: 255
  end

  create_table "e_items", force: :cascade do |t|
    t.integer  "user_do",        limit: 4
    t.string   "user_do_change", limit: 255
    t.string   "check",          limit: 255
    t.integer  "e_bom_id",       limit: 4
    t.integer  "quantity",       limit: 4
    t.string   "description",    limit: 255
    t.text     "part_code",      limit: 65535
    t.string   "fengzhuang",     limit: 255
    t.text     "link",           limit: 4294967295
    t.decimal  "cost",                              precision: 20, scale: 6
    t.string   "info",           limit: 255
    t.integer  "product_id",     limit: 4
    t.boolean  "warn",           limit: 1
    t.integer  "user_id",        limit: 4
    t.boolean  "danger",         limit: 1
    t.boolean  "manual",         limit: 1
    t.boolean  "mark",           limit: 1
    t.string   "mpn",            limit: 255
    t.integer  "mpn_id",         limit: 4
    t.decimal  "price",                             precision: 20, scale: 6
    t.string   "mf",             limit: 255
    t.string   "dn",             limit: 255
    t.integer  "dn_id",          limit: 4
    t.text     "other",          limit: 4294967295
    t.text     "all_info",       limit: 4294967295
    t.text     "remark",         limit: 4294967295
    t.string   "color",          limit: 255
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
  end

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "topic_id",              limit: 4
    t.string   "order_no",              limit: 255,        default: ""
    t.integer  "order_id",              limit: 4
    t.string   "product_code",          limit: 255,        default: ""
    t.integer  "feedback_id",           limit: 4,          default: 0
    t.string   "feedback_title",        limit: 255,        default: ""
    t.text     "feedback",              limit: 4294967295
    t.string   "user_name",             limit: 255,        default: ""
    t.string   "feedback_type",         limit: 255,        default: ""
    t.string   "feedback_receive",      limit: 255,        default: ""
    t.string   "feedback_receive_user", limit: 255
    t.integer  "feedback_level",        limit: 4,          default: 0
    t.string   "send_to",               limit: 255
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  create_table "info_parts", force: :cascade do |t|
    t.string   "mpn",        limit: 255
    t.text     "info",       limit: 4294967295
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "info_parts", ["mpn"], name: "mpn", using: :btree

  create_table "keywords", force: :cascade do |t|
    t.string   "keywords",   limit: 255
    t.string   "ip",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kindeditor_assets", force: :cascade do |t|
    t.string   "asset",      limit: 255
    t.integer  "file_size",  limit: 4
    t.string   "file_type",  limit: 255
    t.integer  "owner_id",   limit: 4
    t.string   "asset_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "min_dns", id: false, force: :cascade do |t|
    t.integer  "id",        limit: 4,                            default: 0, null: false
    t.datetime "date",                                                       null: false
    t.string   "dn",        limit: 255
    t.string   "part_code", limit: 255
    t.string   "des",       limit: 255
    t.integer  "qty",       limit: 4
    t.decimal  "min_price",             precision: 20, scale: 6
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

  create_table "oauths", force: :cascade do |t|
    t.string   "company_id",    limit: 255
    t.string   "company_token", limit: 255
    t.integer  "expires_in",    limit: 4
    t.string   "refresh_token", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "order_items", force: :cascade do |t|
    t.integer  "quantity",    limit: 4
    t.string   "description", limit: 255
    t.text     "part_code",   limit: 65535
    t.integer  "order_id",    limit: 4
    t.integer  "product_id",  limit: 4
    t.boolean  "warn",        limit: 1
    t.integer  "user_id",     limit: 4
    t.boolean  "danger",      limit: 1
    t.boolean  "manual",      limit: 1
    t.boolean  "mark",        limit: 1
    t.string   "mpn",         limit: 255
    t.integer  "mpn_id",      limit: 4
    t.decimal  "price",                          precision: 10, scale: 2
    t.string   "mf",          limit: 255
    t.string   "dn",          limit: 255
    t.text     "other",       limit: 4294967295
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
  end

  create_table "orders", force: :cascade do |t|
    t.string   "order_no",           limit: 255
    t.integer  "bom_id",             limit: 4
    t.string   "no",                 limit: 255
    t.text     "shipping_info",      limit: 4294967295
    t.string   "name",               limit: 255
    t.string   "p_name",             limit: 255
    t.integer  "qty",                limit: 4
    t.decimal  "t_p",                                   precision: 10
    t.string   "d_day",              limit: 255
    t.string   "description",        limit: 255
    t.string   "excel_file",         limit: 255
    t.decimal  "pcb_p",                                 precision: 10
    t.decimal  "pcb_r_p",                               precision: 10
    t.decimal  "pcb_dc_p",                              precision: 10
    t.string   "pcb_file",           limit: 255
    t.string   "pcb_layer",          limit: 255
    t.integer  "pcb_qty",            limit: 4
    t.integer  "pcb_size_c",         limit: 4
    t.integer  "pcb_size_k",         limit: 4
    t.string   "pcb_sc",             limit: 255
    t.string   "pcb_material",       limit: 255
    t.string   "pcb_cc",             limit: 255
    t.string   "pcb_ct",             limit: 255
    t.string   "pcb_sf",             limit: 255
    t.string   "pcb_t",              limit: 255
    t.integer  "t_c",                limit: 4
    t.decimal  "c_p",                                   precision: 10
    t.integer  "user_id",            limit: 4
    t.string   "state",              limit: 255,                       default: "review"
    t.string   "double_check_state", limit: 255
    t.string   "pcb_r_remark",       limit: 255
    t.string   "pcb_dc_remark",      limit: 255
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
  end

  create_table "p_dns", force: :cascade do |t|
    t.integer  "item_id",   limit: 4
    t.string   "part_code", limit: 255
    t.datetime "date",                                                  null: false
    t.string   "dn",        limit: 255
    t.string   "dn_long",   limit: 255
    t.decimal  "cost",                         precision: 20, scale: 6
    t.integer  "qty",       limit: 4
    t.string   "info",      limit: 255
    t.text     "remark",    limit: 4294967295
    t.string   "tag",       limit: 255
    t.string   "color",     limit: 255
    t.string   "info_id",   limit: 255
  end

  create_table "p_items", force: :cascade do |t|
    t.integer  "user_do",            limit: 4
    t.string   "user_do_change",     limit: 255
    t.string   "check",              limit: 255
    t.integer  "procurement_bom_id", limit: 4
    t.integer  "quantity",           limit: 4
    t.string   "description",        limit: 5000
    t.text     "part_code",          limit: 65535
    t.string   "fengzhuang",         limit: 255
    t.text     "link",               limit: 4294967295
    t.decimal  "cost",                                  precision: 20, scale: 6
    t.string   "info",               limit: 255
    t.integer  "product_id",         limit: 4
    t.boolean  "warn",               limit: 1
    t.integer  "user_id",            limit: 4
    t.boolean  "danger",             limit: 1
    t.boolean  "manual",             limit: 1
    t.boolean  "mark",               limit: 1
    t.string   "mpn",                limit: 255
    t.integer  "mpn_id",             limit: 4
    t.decimal  "price",                                 precision: 20, scale: 6
    t.string   "mf",                 limit: 255
    t.string   "dn",                 limit: 255
    t.integer  "dn_id",              limit: 4
    t.text     "other",              limit: 4294967295
    t.text     "all_info",           limit: 4294967295
    t.text     "remark",             limit: 4294967295
    t.string   "color",              limit: 255
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
  end

  create_table "parts", force: :cascade do |t|
    t.string   "part_code",  limit: 255
    t.string   "part_name",  limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "procurement_boms", force: :cascade do |t|
    t.string   "check",        limit: 255
    t.string   "no",           limit: 255
    t.string   "name",         limit: 255
    t.string   "p_name",       limit: 255
    t.integer  "qty",          limit: 4
    t.decimal  "t_p",                             precision: 20
    t.integer  "profit",       limit: 4
    t.decimal  "t_pp",                            precision: 20
    t.string   "d_day",        limit: 255
    t.string   "description",  limit: 255
    t.string   "excel_file",   limit: 255
    t.decimal  "pcb_p",                           precision: 10
    t.string   "pcb_file",     limit: 255
    t.string   "pcb_layer",    limit: 255
    t.integer  "pcb_qty",      limit: 4
    t.integer  "pcb_size_c",   limit: 4
    t.integer  "pcb_size_k",   limit: 4
    t.string   "pcb_sc",       limit: 255
    t.string   "pcb_material", limit: 255
    t.string   "pcb_cc",       limit: 255
    t.string   "pcb_ct",       limit: 255
    t.string   "pcb_sf",       limit: 255
    t.string   "pcb_t",        limit: 255
    t.integer  "t_c",          limit: 4
    t.decimal  "c_p",                             precision: 20
    t.integer  "user_id",      limit: 4
    t.text     "all_title",    limit: 4294967295
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  create_table "products", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.text     "mpn",               limit: 4294967295
    t.string   "description",       limit: 255
    t.float    "price",             limit: 24,         default: 0.0
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.string   "part_name",         limit: 255
    t.string   "part_name_en",      limit: 255
    t.integer  "product_able_id",   limit: 4
    t.string   "product_able_type", limit: 255
    t.integer  "prefer",            limit: 4,          default: 0
    t.boolean  "delta",             limit: 1,          default: true,      null: false
    t.string   "ptype",             limit: 255,        default: "default"
    t.string   "package1",          limit: 255,        default: "default"
    t.string   "package2",          limit: 255,        default: "default"
    t.string   "value1",            limit: 255
    t.string   "value2",            limit: 255
    t.string   "value3",            limit: 255
    t.string   "value4",            limit: 255
    t.string   "value5",            limit: 255
    t.string   "value6",            limit: 255
    t.string   "value7",            limit: 255
    t.string   "value8",            limit: 255
  end

  add_index "products", ["description"], name: "des", using: :btree
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

  create_table "shipping_infos", force: :cascade do |t|
    t.integer "user_id",      limit: 4
    t.string  "first_name",   limit: 255
    t.string  "last_name",    limit: 255
    t.string  "address_line", limit: 255
    t.string  "postal_code",  limit: 255
    t.string  "email",        limit: 255
    t.string  "phone",        limit: 255
    t.string  "city",         limit: 255
    t.string  "country",      limit: 255
    t.string  "country_name", limit: 255
    t.string  "company",      limit: 255
  end

  add_index "shipping_infos", ["user_id"], name: "user_id", using: :btree

  create_table "timesheets", force: :cascade do |t|
    t.string   "order_no",   limit: 255, default: ""
    t.integer  "order_id",   limit: 4
    t.integer  "gangwang",   limit: 4
    t.integer  "guolu",      limit: 4
    t.integer  "ceshi",      limit: 4
    t.float    "smt_time",   limit: 24
    t.float    "dip_time",   limit: 24
    t.float    "total_time", limit: 24
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "topics", force: :cascade do |t|
    t.string   "order_no",              limit: 255,        default: ""
    t.integer  "order_id",              limit: 4
    t.string   "product_code",          limit: 255,        default: ""
    t.integer  "feedback_id",           limit: 4,          default: 0
    t.string   "feedback_title",        limit: 255,        default: ""
    t.text     "feedback",              limit: 4294967295
    t.string   "user_name",             limit: 255,        default: ""
    t.string   "feedback_type",         limit: 255,        default: ""
    t.string   "feedback_receive",      limit: 255,        default: ""
    t.string   "feedback_receive_user", limit: 255,        default: ""
    t.integer  "feedback_level",        limit: 4,          default: 0
    t.string   "mark",                  limit: 255,        default: ""
    t.string   "topic_state",           limit: 255,        default: "open"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
  end

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
    t.string   "s_name",                 limit: 255
    t.string   "open_id",                limit: 255
    t.string   "full_name",              limit: 255, default: ""
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "country",                limit: 255
    t.string   "country_name",           limit: 255
    t.string   "skype",                  limit: 255
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

  create_table "users_roles", force: :cascade do |t|
    t.integer "user_id", limit: 4
    t.integer "role_id", limit: 4
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "work_flows", force: :cascade do |t|
    t.date     "order_date"
    t.string   "order_no",            limit: 255,        default: "",  null: false
    t.integer  "order_quantity",      limit: 4
    t.date     "salesman_end_date"
    t.string   "product_code",        limit: 255,        default: ""
    t.integer  "warehouse_quantity",  limit: 4
    t.string   "smd",                 limit: 255,        default: ""
    t.string   "dip",                 limit: 255,        default: ""
    t.date     "smd_start_date"
    t.date     "smd_end_date"
    t.string   "smd_state",           limit: 255,        default: ""
    t.date     "dip_start_date"
    t.date     "dip_end_date"
    t.date     "update_date"
    t.text     "production_feedback", limit: 4294967295
    t.text     "test_feedback",       limit: 4294967295
    t.date     "supplement_date"
    t.string   "feed_state",          limit: 255,        default: ""
    t.date     "clear_date"
    t.string   "salesman_state",      limit: 255,        default: ""
    t.string   "remark",              limit: 255,        default: ""
    t.integer  "order_state",         limit: 4,          default: 0
    t.integer  "feedback_state",      limit: 4,          default: 0
    t.integer  "gangwang",            limit: 4,          default: 0
    t.integer  "guolu",               limit: 4,          default: 0
    t.integer  "ceshi",               limit: 4,          default: 0
    t.float    "smt_time",            limit: 24,         default: 0.0
    t.float    "dip_time",            limit: 24,         default: 0.0
    t.float    "total_time",          limit: 24,         default: 0.0
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
  end

  add_index "work_flows", ["order_no"], name: "order_no", unique: true, using: :btree

  create_table "works", force: :cascade do |t|
    t.date     "order_date"
    t.string   "order_no",            limit: 255, default: ""
    t.integer  "order_quantity",      limit: 4
    t.date     "salesman_end_date"
    t.string   "product_code",        limit: 255, default: ""
    t.integer  "warehouse_quantity",  limit: 4
    t.string   "smd",                 limit: 255, default: ""
    t.string   "dip",                 limit: 255, default: ""
    t.date     "smd_start_date"
    t.string   "smd_end_date",        limit: 255
    t.string   "smd_state",           limit: 255, default: ""
    t.date     "dip_start_date"
    t.date     "dip_end_date"
    t.date     "update_date"
    t.string   "production_feedback", limit: 255, default: ""
    t.string   "test_feedback",       limit: 255, default: ""
    t.date     "supplement_date"
    t.string   "feed_state",          limit: 255, default: ""
    t.date     "clear_date"
    t.string   "salesman_state",      limit: 255, default: ""
    t.string   "remark",              limit: 255, default: ""
    t.integer  "order_state",         limit: 4,   default: 0
    t.string   "user_name",           limit: 255
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

end
