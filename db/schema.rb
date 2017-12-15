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

ActiveRecord::Schema.define(version: 20171215111833) do

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

  create_table "all_parts_bak", force: :cascade do |t|
    t.string   "mpn",        limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "bank_infos", force: :cascade do |t|
    t.string   "des",           limit: 255
    t.string   "bank_name",     limit: 255
    t.string   "bank_account",  limit: 255
    t.string   "user_name",     limit: 255
    t.string   "first_name",    limit: 255
    t.string   "last_name",     limit: 255
    t.string   "bank_address",  limit: 255
    t.string   "swift_code",    limit: 255
    t.string   "bank_code",     limit: 255
    t.string   "remark",        limit: 255
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "pi_info_count", limit: 4,   default: 0
    t.integer  "user_id",       limit: 4
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

  create_table "bom_ecn_infos", force: :cascade do |t|
    t.string   "state",              limit: 255, default: "new"
    t.integer  "no",                 limit: 4
    t.integer  "bom_id",             limit: 4
    t.string   "pi_id",              limit: 255
    t.integer  "pi_item_id",         limit: 4
    t.string   "pi_no",              limit: 50
    t.string   "bom_no",             limit: 50
    t.string   "chan_pin_xing_hao",  limit: 255
    t.integer  "fa_qi_ren_id",       limit: 4
    t.string   "fa_qi_ren_name",     limit: 255
    t.integer  "shen_he_ren_id",     limit: 4
    t.string   "shen_he_ren_name",   limit: 255
    t.integer  "pi_zhun_ren_id",     limit: 4
    t.string   "pi_zhun_ren_name",   limit: 255
    t.datetime "zhi_xing_date_at"
    t.datetime "bom_update_date_at"
    t.string   "change_type",        limit: 255
    t.string   "sheng_xiao_type",    limit: 255
    t.string   "remark",             limit: 255
    t.datetime "send_at"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  create_table "bom_ecn_items", force: :cascade do |t|
    t.string   "state",            limit: 255, default: "new"
    t.integer  "bom_ecn_info_id",  limit: 4
    t.integer  "bom_item_id",      limit: 4
    t.integer  "moko_bom_item_id", limit: 4
    t.string   "old_moko_part",    limit: 255
    t.string   "old_moko_des",     limit: 255
    t.string   "old_part_code",    limit: 255
    t.integer  "old_quantity",     limit: 4
    t.string   "new_moko_part",    limit: 255
    t.string   "new_sell_des",     limit: 255
    t.string   "new_moko_des",     limit: 255
    t.string   "new_part_code",    limit: 255
    t.integer  "new_quantity",     limit: 4
    t.string   "change_type",      limit: 255, default: ""
    t.string   "remark",           limit: 255
    t.string   "eng_moko_part",    limit: 255
    t.string   "eng_moko_des",     limit: 255
    t.string   "eng_part_code",    limit: 255
    t.string   "eng_quantity",     limit: 255
    t.string   "eng_remark",       limit: 255
    t.string   "opt_type",         limit: 255, default: ""
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

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

  create_table "cai_gou_fa_piao_infos", force: :cascade do |t|
    t.string   "fa_piao_state",    limit: 255,                          default: "new"
    t.string   "site",             limit: 255,                          default: ""
    t.string   "pi_wh_id",         limit: 255
    t.string   "pi_wh_no",         limit: 255
    t.string   "wh_user",          limit: 255
    t.string   "state",            limit: 255
    t.integer  "supplier_list_id", limit: 4
    t.string   "dn",               limit: 255
    t.string   "dn_long",          limit: 255
    t.string   "cai_gou_fang_shi", limit: 255
    t.datetime "wh_at"
    t.decimal  "t_p",                          precision: 20, scale: 6
    t.decimal  "tax_t_p",                      precision: 20, scale: 6
    t.datetime "created_at",                                                            null: false
    t.datetime "updated_at",                                                            null: false
  end

  create_table "cai_gou_fa_piao_items", force: :cascade do |t|
    t.integer  "cai_gou_fa_piao_info_id", limit: 4
    t.string   "pmc_flag",                limit: 255,                                 default: ""
    t.integer  "pi_pmc_item_id",          limit: 4
    t.string   "buy_user",                limit: 255
    t.integer  "pi_wh_info_id",           limit: 4
    t.string   "pi_wh_info_no",           limit: 255
    t.integer  "pi_buy_item_id",          limit: 4
    t.string   "moko_part",               limit: 255
    t.string   "moko_des",                limit: 255
    t.integer  "qty_in",                  limit: 4,                                   default: 0
    t.text     "remark",                  limit: 4294967295
    t.integer  "p_item_id",               limit: 4
    t.integer  "erp_id",                  limit: 4
    t.string   "erp_no",                  limit: 50
    t.integer  "pi_buy_info_id",          limit: 4
    t.integer  "procurement_bom_id",      limit: 4
    t.string   "state",                   limit: 255
    t.decimal  "cost",                                       precision: 20, scale: 6
    t.decimal  "tax_cost",                                   precision: 20, scale: 6
    t.decimal  "tax",                                        precision: 10, scale: 4
    t.decimal  "tax_t_p",                                    precision: 20, scale: 6
    t.datetime "created_at",                                                                       null: false
    t.datetime "updated_at",                                                                       null: false
  end

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

  create_table "finance_payment_voucher_infos", force: :cascade do |t|
    t.string   "type",                    limit: 255,                          default: ""
    t.integer  "finance_voucher_info_id", limit: 4
    t.integer  "fu_kuan_dan_info_id",     limit: 4
    t.integer  "no",                      limit: 4
    t.string   "des",                     limit: 255
    t.string   "jie_fang_kemu",           limit: 255
    t.string   "dai_fang_kemu",           limit: 255
    t.decimal  "jie_fang",                            precision: 20, scale: 6
    t.decimal  "dai_fang",                            precision: 20, scale: 6
    t.datetime "finance_at"
    t.datetime "created_at",                                                                null: false
    t.datetime "updated_at",                                                                null: false
  end

  create_table "finance_voucher_infos", force: :cascade do |t|
    t.string   "state",                  limit: 10,                           default: ""
    t.integer  "payment_notice_info_id", limit: 4
    t.string   "payment_notice_info_no", limit: 100
    t.integer  "pi_info_id",             limit: 4
    t.integer  "pi_item_id",             limit: 4
    t.integer  "c_id",                   limit: 4
    t.string   "pi_info_no",             limit: 30
    t.datetime "pi_date"
    t.string   "c_code",                 limit: 11
    t.string   "c_des",                  limit: 255
    t.string   "c_country",              limit: 255
    t.string   "payment_way",            limit: 50
    t.string   "currency_type",          limit: 10
    t.decimal  "exchange_rate",                      precision: 10, scale: 3
    t.decimal  "pi_t_p",                             precision: 20, scale: 6
    t.decimal  "unreceived_p",                       precision: 20, scale: 6
    t.string   "pay_att",                limit: 255
    t.decimal  "pay_p",                              precision: 20, scale: 6
    t.string   "pay_type",               limit: 10
    t.string   "pay_account_name",       limit: 100
    t.string   "pay_account_number",     limit: 50
    t.string   "pay_swift_code",         limit: 100
    t.string   "pay_bank_name",          limit: 255
    t.string   "remark",                 limit: 500
    t.integer  "sell_id",                limit: 4
    t.string   "sell_full_name_new",     limit: 255
    t.string   "sell_full_name_up",      limit: 255
    t.string   "sell_team",              limit: 255
    t.datetime "send_at"
    t.string   "voucher_item",           limit: 255
    t.string   "voucher_way",            limit: 255
    t.string   "collection_type",        limit: 50
    t.string   "xianjin_kemu",           limit: 255
    t.string   "voucher_bank_name",      limit: 255
    t.string   "voucher_bank_account",   limit: 255
    t.decimal  "get_money",                          precision: 20, scale: 6
    t.decimal  "get_money_self",                     precision: 20, scale: 6
    t.decimal  "loss_money",                         precision: 20, scale: 6
    t.decimal  "loss_money_self",                    precision: 20, scale: 6
    t.string   "voucher_remark",         limit: 255
    t.string   "voucher_no",             limit: 50
    t.datetime "voucher_at"
    t.datetime "finance_at"
    t.string   "voucher_currency_type",  limit: 10
    t.decimal  "voucher_exchange_rate",              precision: 10, scale: 3
    t.string   "voucher_full_name_new",  limit: 20
    t.string   "voucher_full_name_up",   limit: 20
    t.datetime "created_at",                                                               null: false
    t.datetime "updated_at",                                                               null: false
  end

  create_table "fu_kuan_dan_infos", force: :cascade do |t|
    t.integer  "fu_kuan_shen_qing_dan_info_id", limit: 4
    t.string   "user_new",                      limit: 255
    t.string   "user_checked",                  limit: 255
    t.string   "user_fu_kuan_shen_qing_dan",    limit: 255
    t.string   "state",                         limit: 10,                           default: ""
    t.decimal  "t_p",                                       precision: 20, scale: 6
    t.decimal  "true_t_p",                                  precision: 20, scale: 6
    t.string   "supplier_code",                 limit: 255
    t.string   "supplier_name",                 limit: 255
    t.string   "supplier_name_long",            limit: 255
    t.integer  "supplier_list_id",              limit: 4
    t.string   "supplier_clearing",             limit: 255
    t.string   "supplier_address",              limit: 255
    t.string   "supplier_contacts",             limit: 255
    t.string   "supplier_phone",                limit: 255
    t.string   "supplier_bank_user",            limit: 255
    t.string   "supplier_bank_account",         limit: 255
    t.string   "supplier_bank_name",            limit: 255
    t.decimal  "shen_qing_jiner",                           precision: 20, scale: 6
    t.decimal  "shen_pi_jiner",                             precision: 20, scale: 6
    t.string   "remark",                        limit: 255
    t.string   "kuai_ji_ke_mu",                 limit: 255
    t.datetime "finance_at"
    t.string   "xianjin_kemu",                  limit: 255
    t.datetime "created_at",                                                                      null: false
    t.datetime "updated_at",                                                                      null: false
  end

  create_table "fu_kuan_dan_items", force: :cascade do |t|
    t.integer  "pi_info_id",            limit: 4
    t.integer  "pi_item_id",            limit: 4
    t.integer  "fu_kuan_dan_info_id",   limit: 4
    t.integer  "pi_buy_info_id",        limit: 4
    t.integer  "pi_buy_item_id",        limit: 4
    t.string   "pi_buy_no",             limit: 255
    t.decimal  "t_p",                               precision: 20, scale: 6
    t.decimal  "ding_dan_zhi_fu_bi_li",             precision: 5,  scale: 2
    t.decimal  "shen_qing_p",                       precision: 20, scale: 6, default: 0.0
    t.decimal  "fu_kuan_p",                         precision: 20, scale: 6
    t.decimal  "zhe_kou_p",                         precision: 20, scale: 6, default: 0.0
    t.decimal  "shen_pi_p",                         precision: 20, scale: 6, default: 0.0
    t.string   "moko_part",             limit: 255
    t.string   "moko_des",              limit: 255
    t.datetime "created_at",                                                               null: false
    t.datetime "updated_at",                                                               null: false
  end

  create_table "fu_kuan_ping_zheng_infos", force: :cascade do |t|
    t.integer  "fu_kuan_dan_info_id", limit: 4
    t.integer  "no",                  limit: 4
    t.string   "des",                 limit: 255
    t.string   "jie_fang_kemu",       limit: 255
    t.string   "dai_fang_kemu",       limit: 255
    t.decimal  "jie_fang",                        precision: 20, scale: 6
    t.decimal  "dai_fang",                        precision: 20, scale: 6
    t.datetime "finance_at"
    t.string   "remark",              limit: 255
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
  end

  create_table "fu_kuan_ping_zheng_yuejie_infos", force: :cascade do |t|
    t.integer  "cai_gou_fa_piao_info_id", limit: 4
    t.integer  "fu_kuan_dan_info_id",     limit: 4
    t.integer  "no",                      limit: 4
    t.string   "des",                     limit: 255
    t.string   "jie_fang_kemu",           limit: 255
    t.string   "dai_fang_kemu",           limit: 255
    t.decimal  "jie_fang",                            precision: 20, scale: 6
    t.decimal  "dai_fang",                            precision: 20, scale: 6
    t.decimal  "yuan_cai_liao",                       precision: 20, scale: 6
    t.decimal  "ying_jiao_shui_fei",                  precision: 20, scale: 6
    t.datetime "finance_at"
    t.string   "remark",                  limit: 255
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
  end

  create_table "fu_kuan_shen_qing_dan_infos", force: :cascade do |t|
    t.string   "user_new",              limit: 255
    t.string   "user_checked",          limit: 255
    t.string   "fu_kuan_dan_state",     limit: 255,                          default: ""
    t.string   "state",                 limit: 10,                           default: ""
    t.decimal  "t_p",                               precision: 20, scale: 6
    t.string   "supplier_code",         limit: 255
    t.string   "supplier_name",         limit: 255
    t.string   "supplier_name_long",    limit: 255
    t.integer  "supplier_list_id",      limit: 4
    t.string   "supplier_clearing",     limit: 255
    t.string   "supplier_address",      limit: 255
    t.string   "supplier_contacts",     limit: 255
    t.string   "supplier_phone",        limit: 255
    t.string   "supplier_bank_user",    limit: 255
    t.string   "supplier_bank_account", limit: 255
    t.string   "supplier_bank_name",    limit: 255
    t.decimal  "shen_qing_jiner",                   precision: 20, scale: 6
    t.decimal  "shen_pi_jiner",                     precision: 20, scale: 6
    t.string   "remark",                limit: 255
    t.string   "info_a",                limit: 255
    t.string   "info_b",                limit: 255
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
  end

  create_table "fu_kuan_shen_qing_dan_items", force: :cascade do |t|
    t.string   "pi_wh_id",                      limit: 255
    t.integer  "pi_info_id",                    limit: 4
    t.integer  "pi_item_id",                    limit: 4
    t.integer  "fu_kuan_shen_qing_dan_info_id", limit: 4
    t.integer  "pi_buy_info_id",                limit: 4
    t.integer  "pi_buy_item_id",                limit: 4
    t.string   "pi_buy_no",                     limit: 255
    t.decimal  "t_p",                                       precision: 20, scale: 6
    t.decimal  "ding_dan_zhi_fu_bi_li",                     precision: 5,  scale: 2
    t.decimal  "shen_qing_p",                               precision: 20, scale: 6, default: 0.0
    t.decimal  "shen_pi_p",                                 precision: 20, scale: 6, default: 0.0
    t.string   "moko_part",                     limit: 255
    t.string   "moko_des",                      limit: 255
    t.datetime "created_at",                                                                       null: false
    t.datetime "updated_at",                                                                       null: false
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

  create_table "kinds", force: :cascade do |t|
    t.string "code_a", limit: 255
    t.string "code_b", limit: 255
    t.string "des",    limit: 255
    t.text   "attr",   limit: 4294967295
  end

  create_table "kuaijikemu_infos", force: :cascade do |t|
    t.string   "code_a",                          limit: 255, default: ""
    t.string   "code_a_name",                     limit: 255, default: ""
    t.string   "code_b",                          limit: 255, default: ""
    t.string   "code_b_name",                     limit: 255, default: ""
    t.string   "code_c",                          limit: 255, default: ""
    t.string   "code_c_name",                     limit: 255, default: ""
    t.string   "zhu_ji_ma",                       limit: 255, default: ""
    t.string   "kemu_type",                       limit: 255, default: ""
    t.string   "yu_er_fang_xiang",                limit: 255, default: ""
    t.string   "wai_bi_he_suan",                  limit: 255, default: ""
    t.string   "quan_ming",                       limit: 255, default: ""
    t.string   "qi_mo_diao_hui",                  limit: 255, default: ""
    t.string   "wang_lai_ye_wu_he_suan",          limit: 255, default: ""
    t.string   "shu_liang_jin_er_fu_zhu_he_suan", limit: 255, default: ""
    t.string   "ji_liang_dan_wei",                limit: 255, default: ""
    t.string   "xian_jin_kemu",                   limit: 255, default: ""
    t.string   "yin_hang_kemu",                   limit: 255, default: ""
    t.string   "chu_ri_ji_zhang",                 limit: 255, default: ""
    t.string   "xian_jin_deng_jia_wu",            limit: 255, default: ""
    t.string   "kemu_ji_xi",                      limit: 255, default: ""
    t.string   "ri_li_lv",                        limit: 255, default: ""
    t.string   "xiang_mu_fu_zhu_he_suan",         limit: 255, default: ""
    t.string   "zhu_biao_xiang_mu",               limit: 255, default: ""
    t.string   "fu_biao_xiang_mu",                limit: 255, default: ""
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
  end

  create_table "ling_liao_dan_infos", force: :cascade do |t|
    t.string   "ling_liao_state",        limit: 255,                          default: "new"
    t.string   "ling_liao_user",         limit: 255
    t.string   "ling_liao_user_name",    limit: 255
    t.string   "checked_user",           limit: 255
    t.string   "checked_name",           limit: 255
    t.string   "pi_lock",                limit: 255,                          default: ""
    t.string   "buy_type",               limit: 255,                          default: ""
    t.integer  "item_pcba_id",           limit: 4
    t.integer  "item_pcb_id",            limit: 4
    t.integer  "c_id",                   limit: 4
    t.integer  "bom_id",                 limit: 4
    t.integer  "pcb_order_id",           limit: 4
    t.integer  "pcb_order_sell_item_id", limit: 4
    t.string   "pcb_order_no",           limit: 255
    t.string   "pcb_order_no_son",       limit: 255
    t.string   "moko_code",              limit: 255
    t.string   "moko_des",               limit: 255
    t.string   "des_en",                 limit: 255,                          default: ""
    t.string   "des_cn",                 limit: 255,                          default: ""
    t.integer  "qty",                    limit: 4
    t.string   "p_type",                 limit: 255,                          default: ""
    t.string   "moko_attribute",         limit: 255
    t.decimal  "t_p",                                precision: 20, scale: 6
    t.decimal  "price",                              precision: 20, scale: 6
    t.string   "att",                    limit: 255
    t.string   "state",                  limit: 255,                          default: ""
    t.string   "remark",                 limit: 500
    t.string   "p_remark",               limit: 500
    t.datetime "checked_at"
    t.datetime "created_at",                                                                  null: false
    t.datetime "updated_at",                                                                  null: false
  end

  create_table "ling_liao_dan_items", force: :cascade do |t|
    t.integer  "ling_liao_dan_info_id",   limit: 4
    t.integer  "pi_bom_qty_info_item_id", limit: 4
    t.integer  "pi_info_id",              limit: 4
    t.integer  "pi_item_id",              limit: 4
    t.string   "pmc_flag",                limit: 255,                                 default: ""
    t.string   "state",                   limit: 255,                                 default: ""
    t.string   "pmc_type",                limit: 255,                                 default: ""
    t.string   "buy_type",                limit: 255,                                 default: ""
    t.string   "erp_no",                  limit: 50
    t.string   "erp_no_son",              limit: 255
    t.string   "moko_part",               limit: 255
    t.string   "moko_des",                limit: 255
    t.text     "part_code",               limit: 65535
    t.integer  "qty",                     limit: 4
    t.integer  "f_qty",                   limit: 4
    t.integer  "pmc_qty",                 limit: 4,                                   default: 0
    t.integer  "qty_in",                  limit: 4
    t.text     "remark",                  limit: 4294967295
    t.string   "buy_user",                limit: 255,                                 default: ""
    t.integer  "buy_qty",                 limit: 4
    t.integer  "p_item_id",               limit: 4
    t.integer  "erp_id",                  limit: 4
    t.integer  "user_do",                 limit: 4
    t.string   "user_do_change",          limit: 255
    t.string   "check",                   limit: 255,                                 default: ""
    t.integer  "pi_buy_info_id",          limit: 4
    t.integer  "procurement_bom_id",      limit: 4
    t.integer  "quantity",                limit: 4
    t.integer  "qty_done",                limit: 4,                                   default: 0
    t.integer  "qty_wait",                limit: 4,                                   default: 0
    t.integer  "wh_qty",                  limit: 4
    t.string   "description",             limit: 5000
    t.string   "fengzhuang",              limit: 255
    t.text     "link",                    limit: 4294967295
    t.decimal  "cost",                                       precision: 20, scale: 6
    t.string   "info",                    limit: 255
    t.integer  "product_id",              limit: 4
    t.boolean  "warn",                    limit: 1
    t.integer  "user_id",                 limit: 4
    t.boolean  "danger",                  limit: 1
    t.boolean  "manual",                  limit: 1
    t.boolean  "mark",                    limit: 1
    t.string   "mpn",                     limit: 255
    t.integer  "mpn_id",                  limit: 4
    t.decimal  "price",                                      precision: 20, scale: 6
    t.string   "mf",                      limit: 255
    t.integer  "dn_id",                   limit: 4
    t.string   "dn",                      limit: 255
    t.string   "dn_long",                 limit: 255
    t.text     "other",                   limit: 4294967295
    t.text     "all_info",                limit: 4294967295
    t.string   "color",                   limit: 255
    t.string   "supplier_tag",            limit: 255
    t.string   "supplier_out_tag",        limit: 255
    t.string   "sell_feed_back_tag",      limit: 255
    t.datetime "pass_at"
    t.datetime "created_at",                                                                       null: false
    t.datetime "updated_at",                                                                       null: false
  end

  create_table "moko_bom_infos", force: :cascade do |t|
    t.integer  "copy_id",              limit: 4
    t.string   "moko_state",           limit: 255,                                 default: ""
    t.string   "state",                limit: 255,                                 default: ""
    t.string   "pi_lock",              limit: 255,                                 default: ""
    t.string   "bom_id",               limit: 11
    t.string   "bom_active",           limit: 20,                                  default: "active"
    t.string   "bom_lock",             limit: 255
    t.string   "change_flag",          limit: 10,                                  default: ""
    t.integer  "bom_version",          limit: 4,                                   default: 1
    t.integer  "erp_id",               limit: 4
    t.integer  "erp_item_id",          limit: 4
    t.string   "erp_no",               limit: 255
    t.string   "erp_no_son",           limit: 255
    t.integer  "erp_qty",              limit: 4
    t.string   "order_do",             limit: 255
    t.string   "order_country",        limit: 255
    t.integer  "star",                 limit: 4
    t.text     "sell_remark",          limit: 4294967295
    t.text     "sell_manager_remark",  limit: 4294967295
    t.string   "check",                limit: 255
    t.string   "no",                   limit: 255
    t.string   "name",                 limit: 255
    t.string   "p_name_mom",           limit: 255
    t.string   "p_name",               limit: 255
    t.integer  "qty",                  limit: 4
    t.text     "remark",               limit: 4294967295
    t.decimal  "t_p",                                     precision: 20, scale: 6
    t.integer  "profit",               limit: 4
    t.decimal  "t_pp",                                    precision: 20, scale: 6
    t.string   "d_day",                limit: 255
    t.string   "description",          limit: 255
    t.string   "excel_file",           limit: 255
    t.string   "att",                  limit: 255
    t.decimal  "pcb_p",                                   precision: 20, scale: 6
    t.string   "pcb_file",             limit: 255
    t.string   "pcb_layer",            limit: 255
    t.integer  "pcb_qty",              limit: 4
    t.integer  "pcb_size_c",           limit: 4
    t.integer  "pcb_size_k",           limit: 4
    t.string   "pcb_sc",               limit: 255
    t.string   "pcb_material",         limit: 255
    t.string   "pcb_cc",               limit: 255
    t.string   "pcb_ct",               limit: 255
    t.string   "pcb_sf",               limit: 255
    t.string   "pcb_t",                limit: 255
    t.integer  "t_c",                  limit: 4
    t.decimal  "c_p",                                     precision: 20, scale: 6
    t.integer  "user_id",              limit: 4
    t.text     "all_title",            limit: 4294967295
    t.integer  "row_use",              limit: 4
    t.string   "bom_eng_up",           limit: 255
    t.string   "bom_eng",              limit: 255
    t.string   "bom_team_ck",          limit: 255
    t.datetime "bom_team_ck_at"
    t.string   "remark_to_sell",       limit: 255
    t.string   "sell_feed_back_tag",   limit: 255
    t.datetime "created_at",                                                                          null: false
    t.datetime "updated_at",                                                                          null: false
    t.integer  "moko_bom_items_count", limit: 4
  end

  add_index "moko_bom_infos", ["p_name"], name: "p_name", using: :btree

  create_table "moko_bom_items", force: :cascade do |t|
    t.string   "bom_version",        limit: 255
    t.string   "p_type",             limit: 255
    t.string   "buy",                limit: 10,                                  default: ""
    t.integer  "erp_id",             limit: 4
    t.string   "erp_no",             limit: 50
    t.integer  "user_do",            limit: 4
    t.string   "user_do_change",     limit: 255
    t.string   "check",              limit: 255
    t.integer  "moko_bom_info_id",   limit: 4
    t.integer  "quantity",           limit: 4
    t.integer  "pi_qty",             limit: 4,                                   default: 0
    t.integer  "pmc_qty",            limit: 4,                                   default: 0
    t.integer  "customer_qty",       limit: 4,                                   default: 0
    t.integer  "have_qty",           limit: 4,                                   default: 0
    t.integer  "buy_qty",            limit: 4,                                   default: 0
    t.string   "description",        limit: 5000
    t.text     "part_code",          limit: 65535
    t.string   "fengzhuang",         limit: 255
    t.text     "link",               limit: 4294967295
    t.decimal  "cost",                                  precision: 20, scale: 6
    t.string   "info",               limit: 255
    t.integer  "product_id",         limit: 4
    t.string   "moko_part",          limit: 255
    t.string   "moko_des",           limit: 255
    t.boolean  "warn",               limit: 1
    t.integer  "user_id",            limit: 4
    t.boolean  "danger",             limit: 1
    t.boolean  "manual",             limit: 1
    t.boolean  "mark",               limit: 1
    t.string   "mpn",                limit: 255
    t.integer  "mpn_id",             limit: 4
    t.decimal  "price",                                 precision: 20, scale: 6
    t.string   "mf",                 limit: 255
    t.integer  "dn_id",              limit: 4
    t.string   "dn",                 limit: 255
    t.string   "dn_long",            limit: 255
    t.text     "other",              limit: 4294967295
    t.text     "all_info",           limit: 4294967295
    t.text     "remark",             limit: 4294967295
    t.string   "color",              limit: 255,                                 default: ""
    t.string   "supplier_tag",       limit: 255
    t.string   "supplier_out_tag",   limit: 255
    t.string   "sell_feed_back_tag", limit: 255,                                 default: ""
    t.string   "ecn_tag",            limit: 255,                                 default: ""
    t.datetime "created_at",                                                                  null: false
    t.datetime "updated_at",                                                                  null: false
  end

  add_index "moko_bom_items", ["color"], name: "color", using: :btree
  add_index "moko_bom_items", ["erp_no"], name: "pi_no", using: :btree
  add_index "moko_bom_items", ["user_do"], name: "user_do", using: :btree

  create_table "moko_parts_types", force: :cascade do |t|
    t.string   "part_name_main",           limit: 255
    t.string   "part_name_type_a_no",      limit: 255
    t.string   "part_name_type_a_name",    limit: 255
    t.string   "part_name_type_a_name_en", limit: 255
    t.string   "part_name_type_a_sname",   limit: 255
    t.string   "part_name_type_b_name",    limit: 255
    t.string   "part_name_type_b_name_en", limit: 255
    t.string   "part_name_type_b_sname",   limit: 255
    t.string   "part_name_type_c_no",      limit: 11
    t.string   "part_name_type_c_name_cn", limit: 255
    t.string   "part_name_type_c_name",    limit: 255
    t.string   "all_des_cn",               limit: 800
    t.string   "all_des_en",               limit: 800
    t.string   "part_example",             limit: 300
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
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
    t.integer  "app_id",        limit: 4
    t.string   "app_secret",    limit: 255
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

  create_table "other_baojia_boms", force: :cascade do |t|
    t.string   "order_do",            limit: 255
    t.string   "order_country",       limit: 255
    t.integer  "star",                limit: 4
    t.text     "sell_remark",         limit: 4294967295
    t.text     "sell_manager_remark", limit: 4294967295
    t.string   "check",               limit: 255
    t.string   "no",                  limit: 255
    t.string   "name",                limit: 255
    t.string   "p_name",              limit: 255
    t.integer  "qty",                 limit: 4
    t.text     "remark",              limit: 4294967295
    t.decimal  "t_p",                                    precision: 20, scale: 6
    t.integer  "profit",              limit: 4
    t.decimal  "t_pp",                                   precision: 20, scale: 6
    t.string   "d_day",               limit: 255
    t.string   "description",         limit: 255
    t.string   "excel_file",          limit: 255
    t.string   "att",                 limit: 255
    t.decimal  "pcb_p",                                  precision: 20, scale: 6
    t.string   "pcb_file",            limit: 255
    t.string   "pcb_layer",           limit: 255
    t.integer  "pcb_qty",             limit: 4
    t.integer  "pcb_size_c",          limit: 4
    t.integer  "pcb_size_k",          limit: 4
    t.string   "pcb_sc",              limit: 255
    t.string   "pcb_material",        limit: 255
    t.string   "pcb_cc",              limit: 255
    t.string   "pcb_ct",              limit: 255
    t.string   "pcb_sf",              limit: 255
    t.string   "pcb_t",               limit: 255
    t.integer  "t_c",                 limit: 4
    t.decimal  "c_p",                                    precision: 20, scale: 6
    t.integer  "user_id",             limit: 4
    t.text     "all_title",           limit: 4294967295
    t.integer  "row_use",             limit: 4
    t.string   "bom_eng_up",          limit: 255
    t.string   "bom_eng",             limit: 255
    t.string   "bom_team_ck",         limit: 255
    t.string   "remark_to_sell",      limit: 255
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
  end

  add_index "other_baojia_boms", ["p_name"], name: "p_name", using: :btree

  create_table "p_chk_dns", force: :cascade do |t|
    t.string   "state",          limit: 10,                                  default: ""
    t.string   "dn_type",        limit: 10,                                  default: "A"
    t.string   "owner_email",    limit: 255
    t.string   "email",          limit: 255
    t.integer  "p_item_id",      limit: 4
    t.integer  "pi_pmc_item_id", limit: 4
    t.string   "part_code",      limit: 255
    t.datetime "date",                                                                     null: false
    t.string   "dn",             limit: 255
    t.string   "dn_long",        limit: 255
    t.decimal  "cost",                              precision: 20, scale: 6
    t.integer  "qty",            limit: 4
    t.string   "info",           limit: 255
    t.text     "remark",         limit: 4294967295
    t.string   "tag",            limit: 255
    t.string   "up_alldn_tag",   limit: 10
    t.string   "color",          limit: 255,                                 default: ""
    t.datetime "created_at",                                                               null: false
    t.datetime "updated_at",                                                               null: false
  end

  create_table "p_dns", force: :cascade do |t|
    t.string   "state",        limit: 10,                                  default: ""
    t.string   "dn_type",      limit: 10,                                  default: "A"
    t.string   "owner_email",  limit: 255
    t.string   "email",        limit: 255
    t.integer  "p_item_id",    limit: 4
    t.string   "part_code",    limit: 255
    t.datetime "date",                                                                   null: false
    t.string   "dn",           limit: 255
    t.string   "dn_long",      limit: 255
    t.decimal  "cost",                            precision: 20, scale: 6
    t.integer  "qty",          limit: 4
    t.string   "info",         limit: 255
    t.text     "remark",       limit: 4294967295
    t.string   "tag",          limit: 255
    t.string   "up_alldn_tag", limit: 10
    t.string   "color",        limit: 255,                                 default: ""
    t.datetime "created_at",                                                             null: false
    t.datetime "updated_at",                                                             null: false
  end

  create_table "p_item_remarks", force: :cascade do |t|
    t.integer  "p_item_id",  limit: 4
    t.integer  "user_id",    limit: 4
    t.string   "user_name",  limit: 255
    t.string   "user_team",  limit: 255
    t.text     "remark",     limit: 4294967295
    t.string   "info",       limit: 255
    t.string   "state",      limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "p_item_remarks", ["p_item_id"], name: "p_item_id", using: :btree

  create_table "p_items", force: :cascade do |t|
    t.integer  "moko_bom_item_id",           limit: 4
    t.string   "add_state",                  limit: 255,                                 default: ""
    t.string   "bom_version",                limit: 255
    t.string   "p_type",                     limit: 255
    t.string   "buy",                        limit: 10,                                  default: ""
    t.integer  "erp_id",                     limit: 4
    t.string   "erp_no",                     limit: 50
    t.string   "user_do",                    limit: 11
    t.string   "user_do_change",             limit: 255
    t.string   "check",                      limit: 255
    t.integer  "procurement_vsrsion_bom_id", limit: 4
    t.integer  "procurement_bom_id",         limit: 4
    t.integer  "quantity",                   limit: 4
    t.integer  "pi_qty",                     limit: 4,                                   default: 0
    t.integer  "pmc_qty",                    limit: 4,                                   default: 0
    t.integer  "customer_qty",               limit: 4,                                   default: 0
    t.integer  "have_qty",                   limit: 4,                                   default: 0
    t.integer  "buy_qty",                    limit: 4,                                   default: 0
    t.string   "description",                limit: 5000
    t.text     "part_code",                  limit: 65535
    t.string   "fengzhuang",                 limit: 255
    t.text     "link",                       limit: 4294967295
    t.decimal  "cost",                                          precision: 20, scale: 6
    t.string   "info",                       limit: 255
    t.integer  "product_id",                 limit: 4
    t.string   "moko_part",                  limit: 255
    t.string   "moko_des",                   limit: 255
    t.boolean  "warn",                       limit: 1
    t.integer  "user_id",                    limit: 4
    t.boolean  "danger",                     limit: 1
    t.boolean  "manual",                     limit: 1
    t.boolean  "mark",                       limit: 1
    t.string   "mpn",                        limit: 255
    t.integer  "mpn_id",                     limit: 4
    t.decimal  "price",                                         precision: 20, scale: 6
    t.string   "mf",                         limit: 255
    t.integer  "dn_id",                      limit: 4
    t.string   "dn",                         limit: 255
    t.string   "dn_long",                    limit: 255
    t.text     "other",                      limit: 4294967295
    t.text     "all_info",                   limit: 4294967295
    t.text     "remark",                     limit: 4294967295
    t.string   "color",                      limit: 255,                                 default: ""
    t.string   "supplier_tag",               limit: 255
    t.string   "supplier_out_tag",           limit: 255
    t.string   "sell_feed_back_tag",         limit: 255,                                 default: ""
    t.string   "ecn_tag",                    limit: 255,                                 default: ""
    t.datetime "created_at",                                                                          null: false
    t.datetime "updated_at",                                                                          null: false
  end

  add_index "p_items", ["color"], name: "color", using: :btree
  add_index "p_items", ["erp_no"], name: "pi_no", using: :btree
  add_index "p_items", ["user_do"], name: "user_do", using: :btree

  create_table "p_version_dns", force: :cascade do |t|
    t.string   "email",             limit: 255
    t.integer  "p_version_item_id", limit: 4
    t.string   "part_code",         limit: 255
    t.datetime "date",                                                          null: false
    t.string   "dn",                limit: 255
    t.string   "dn_long",           limit: 255
    t.decimal  "cost",                                 precision: 20, scale: 6
    t.integer  "qty",               limit: 4
    t.string   "info",              limit: 255
    t.text     "remark",            limit: 4294967295
    t.string   "tag",               limit: 255
    t.string   "color",             limit: 255
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
  end

  create_table "p_version_item_remarks", force: :cascade do |t|
    t.integer  "p_version_item_id", limit: 4
    t.integer  "user_id",           limit: 4
    t.string   "user_name",         limit: 255
    t.string   "user_team",         limit: 255
    t.string   "remark",            limit: 600, default: ""
    t.string   "info",              limit: 255
    t.string   "state",             limit: 255
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "p_version_item_remarks", ["p_version_item_id"], name: "p_item_id", using: :btree

  create_table "p_version_items", force: :cascade do |t|
    t.string   "bom_version",                limit: 255
    t.string   "p_type",                     limit: 255
    t.string   "buy",                        limit: 10
    t.integer  "erp_id",                     limit: 4
    t.string   "erp_no",                     limit: 50
    t.integer  "user_do",                    limit: 4
    t.string   "user_do_change",             limit: 255
    t.string   "check",                      limit: 255
    t.integer  "procurement_version_bom_id", limit: 4
    t.integer  "procurement_bom_id",         limit: 4
    t.integer  "quantity",                   limit: 4
    t.integer  "pmc_qty",                    limit: 4
    t.string   "description",                limit: 5000
    t.text     "part_code",                  limit: 65535
    t.string   "fengzhuang",                 limit: 255
    t.text     "link",                       limit: 4294967295
    t.decimal  "cost",                                          precision: 20, scale: 6
    t.string   "info",                       limit: 255
    t.integer  "product_id",                 limit: 4
    t.string   "moko_part",                  limit: 255
    t.string   "moko_des",                   limit: 255
    t.boolean  "warn",                       limit: 1
    t.integer  "user_id",                    limit: 4
    t.boolean  "danger",                     limit: 1
    t.boolean  "manual",                     limit: 1
    t.boolean  "mark",                       limit: 1
    t.string   "mpn",                        limit: 255
    t.integer  "mpn_id",                     limit: 4
    t.decimal  "price",                                         precision: 20, scale: 6
    t.string   "mf",                         limit: 255
    t.integer  "dn_id",                      limit: 4
    t.string   "dn",                         limit: 255
    t.string   "dn_long",                    limit: 255
    t.text     "other",                      limit: 4294967295
    t.text     "all_info",                   limit: 4294967295
    t.text     "remark",                     limit: 4294967295
    t.string   "color",                      limit: 255
    t.string   "supplier_tag",               limit: 255
    t.string   "supplier_out_tag",           limit: 255
    t.string   "sell_feed_back_tag",         limit: 255
    t.datetime "created_at",                                                             null: false
    t.datetime "updated_at",                                                             null: false
  end

  add_index "p_version_items", ["color"], name: "color", using: :btree
  add_index "p_version_items", ["erp_no"], name: "pi_no", using: :btree
  add_index "p_version_items", ["user_do"], name: "user_do", using: :btree

  create_table "parts", force: :cascade do |t|
    t.string   "part_code",  limit: 255
    t.string   "part_name",  limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "pay_types", force: :cascade do |t|
    t.integer  "user_id",             limit: 4
    t.string   "type_name",           limit: 255
    t.integer  "supplier_list_count", limit: 4,   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_notice_infos", force: :cascade do |t|
    t.string   "state",              limit: 10,                           default: ""
    t.string   "no",                 limit: 100
    t.integer  "pi_info_id",         limit: 4
    t.integer  "pi_item_id",         limit: 4
    t.integer  "c_id",               limit: 4
    t.string   "pi_info_no",         limit: 30
    t.datetime "pi_date"
    t.string   "c_code",             limit: 11
    t.string   "c_des",              limit: 255
    t.string   "c_country",          limit: 255
    t.string   "payment_way",        limit: 50
    t.string   "currency_type",      limit: 10,                           default: "美金"
    t.decimal  "exchange_rate",                  precision: 10, scale: 3
    t.decimal  "pi_t_p",                         precision: 20, scale: 6
    t.decimal  "unreceived_p",                   precision: 20, scale: 6
    t.string   "pay_att",            limit: 255
    t.decimal  "pay_p",                          precision: 20, scale: 6
    t.string   "pay_type",           limit: 10
    t.string   "pay_account_name",   limit: 100
    t.string   "pay_account_number", limit: 50
    t.string   "pay_swift_code",     limit: 100
    t.string   "pay_bank_name",      limit: 255
    t.string   "remark",             limit: 500
    t.integer  "sell_id",            limit: 4
    t.string   "sell_full_name_new", limit: 255
    t.string   "sell_full_name_up",  limit: 255
    t.string   "sell_team",          limit: 255
    t.datetime "send_at"
    t.datetime "created_at",                                                             null: false
    t.datetime "updated_at",                                                             null: false
  end

  create_table "pcb_customer_remarks", force: :cascade do |t|
    t.integer  "pcb_c_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.string   "user_name",  limit: 255
    t.string   "remark",     limit: 5000, default: ""
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "pcb_customers", force: :cascade do |t|
    t.integer  "c_time",           limit: 4,                              default: 0
    t.string   "c_no",             limit: 255
    t.string   "customer_country", limit: 255
    t.string   "customer",         limit: 255
    t.string   "customer_com",     limit: 255
    t.string   "tel",              limit: 255
    t.string   "fax",              limit: 255
    t.text     "email",            limit: 65535
    t.string   "shipping_address", limit: 5000
    t.string   "sell",             limit: 255
    t.integer  "qty",              limit: 4
    t.string   "att",              limit: 255
    t.string   "order_no",         limit: 255,                            default: ""
    t.decimal  "price",                          precision: 20, scale: 6
    t.decimal  "buy_ptice",                      precision: 20, scale: 6
    t.datetime "target"
    t.datetime "in_storage"
    t.string   "follow",           limit: 1000
    t.text     "remark",           limit: 65535
    t.string   "follow_remark",    limit: 5000,                           default: ""
    t.datetime "created_at",                                                           null: false
    t.datetime "updated_at",                                                           null: false
  end

  create_table "pcb_item_infos", force: :cascade do |t|
    t.integer  "pcb_order_item_id", limit: 4
    t.string   "pcb_supplier",      limit: 255
    t.string   "pcb_order_no",      limit: 255
    t.string   "sell",              limit: 255
    t.float    "pcb_length",        limit: 53
    t.float    "pcb_width",         limit: 53
    t.string   "pcb_thickness",     limit: 255
    t.string   "pcb_panel",         limit: 255
    t.string   "pcb_layer",         limit: 255
    t.string   "pcb_gongyi",        limit: 255
    t.integer  "qty",               limit: 4
    t.decimal  "pcb_area",                      precision: 30, scale: 10
    t.decimal  "pcb_area_price",                precision: 20, scale: 6
    t.decimal  "price",                         precision: 20, scale: 6
    t.decimal  "eng_price",                     precision: 20, scale: 6
    t.decimal  "test_price",                    precision: 20, scale: 6
    t.decimal  "m_price",                       precision: 20, scale: 6
    t.decimal  "t_p",                           precision: 20, scale: 6
    t.string   "remark",            limit: 255
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
  end

  create_table "pcb_order_items", force: :cascade do |t|
    t.string   "pi_lock",                limit: 255,                          default: ""
    t.string   "buy_type",               limit: 255,                          default: ""
    t.integer  "item_pcba_id",           limit: 4
    t.integer  "item_pcb_id",            limit: 4
    t.integer  "c_id",                   limit: 4
    t.integer  "bom_id",                 limit: 4
    t.integer  "pcb_order_id",           limit: 4
    t.integer  "pcb_order_sell_item_id", limit: 4
    t.string   "pcb_order_no",           limit: 255
    t.string   "pcb_order_no_son",       limit: 255
    t.string   "moko_code",              limit: 255
    t.string   "moko_des",               limit: 255
    t.string   "des_en",                 limit: 255,                          default: ""
    t.string   "des_cn",                 limit: 255,                          default: ""
    t.integer  "qty",                    limit: 4
    t.string   "p_type",                 limit: 255,                          default: ""
    t.string   "moko_attribute",         limit: 255
    t.decimal  "t_p",                                precision: 20, scale: 6
    t.decimal  "price",                              precision: 20, scale: 6
    t.string   "att",                    limit: 255
    t.string   "state",                  limit: 255,                          default: ""
    t.string   "factory_state",          limit: 255,                          default: ""
    t.string   "remark",                 limit: 500
    t.string   "p_remark",               limit: 500
    t.string   "bom_team_ck",            limit: 255
    t.datetime "bom_team_ck_at"
    t.datetime "created_at",                                                               null: false
    t.datetime "updated_at",                                                               null: false
  end

  create_table "pcb_order_sell_items", force: :cascade do |t|
    t.integer  "c_id",         limit: 4
    t.integer  "pcb_order_id", limit: 4
    t.string   "pcb_order_no", limit: 255
    t.string   "des_en",       limit: 255, default: ""
    t.string   "des_cn",       limit: 255, default: ""
    t.integer  "qty",          limit: 4
    t.string   "att",          limit: 255
    t.string   "remark",       limit: 500
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "pcb_orders", force: :cascade do |t|
    t.string   "del_flag",           limit: 255,                            default: "active"
    t.integer  "star",               limit: 4,                              default: 0
    t.integer  "pcb_customer_id",    limit: 4
    t.string   "c_code",             limit: 255
    t.string   "c_des",              limit: 255
    t.string   "c_country",          limit: 255
    t.string   "c_shipping_address", limit: 1000
    t.string   "p_name",             limit: 255,                            default: ""
    t.string   "des_en",             limit: 255,                            default: ""
    t.string   "des_cn",             limit: 255,                            default: ""
    t.string   "order_no",           limit: 255
    t.string   "att",                limit: 255
    t.string   "sell",               limit: 255
    t.string   "order_sell",         limit: 255
    t.string   "team",               limit: 255
    t.string   "phone",              limit: 255
    t.string   "price_eng",          limit: 255
    t.decimal  "price",                            precision: 10, scale: 2
    t.integer  "qty",                limit: 4
    t.decimal  "other_price",                      precision: 10, scale: 2
    t.datetime "target"
    t.string   "su",                 limit: 255
    t.string   "state",              limit: 255,                            default: ""
    t.text     "remark",             limit: 65535
    t.text     "manager_remark",     limit: 65535
    t.text     "follow_remark",      limit: 65535
    t.datetime "remark_at"
    t.datetime "manager_remark_at"
    t.datetime "created_at",                                                                   null: false
    t.datetime "updated_at",                                                                   null: false
  end

  create_table "pcb_suppliers", force: :cascade do |t|
    t.string   "pcb_s_code",     limit: 255
    t.string   "name",           limit: 255
    t.string   "name_long",      limit: 255
    t.string   "name_des",       limit: 255
    t.string   "address",        limit: 255
    t.string   "person_contact", limit: 255
    t.string   "number",         limit: 255
    t.string   "email",          limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "pi_bom_qty_info_items", force: :cascade do |t|
    t.string   "lock_state",         limit: 255,                                 default: ""
    t.string   "pmc_back_state",     limit: 255,                                 default: ""
    t.string   "buy",                limit: 255,                                 default: ""
    t.integer  "pi_bom_qty_info_id", limit: 4
    t.integer  "pi_info_id",         limit: 4
    t.integer  "pi_item_id",         limit: 4
    t.integer  "order_item_id",      limit: 4
    t.integer  "bom_id",             limit: 4
    t.integer  "p_item_id",          limit: 4
    t.integer  "moko_bom_item_id",   limit: 4
    t.integer  "qty",                limit: 4
    t.integer  "t_qty",              limit: 4
    t.integer  "bom_ctl_qty",        limit: 4
    t.integer  "customer_qty",       limit: 4
    t.string   "bom_version",        limit: 255
    t.string   "p_type",             limit: 255
    t.integer  "erp_id",             limit: 4
    t.string   "erp_no",             limit: 50
    t.integer  "user_do",            limit: 4
    t.string   "user_do_change",     limit: 255
    t.string   "check",              limit: 255
    t.integer  "moko_bom_info_id",   limit: 4
    t.integer  "quantity",           limit: 4
    t.integer  "pi_qty",             limit: 4,                                   default: 0
    t.integer  "pmc_qty",            limit: 4,                                   default: 0
    t.integer  "have_qty",           limit: 4,                                   default: 0
    t.integer  "buy_qty",            limit: 4,                                   default: 0
    t.string   "description",        limit: 5000
    t.text     "part_code",          limit: 65535
    t.string   "fengzhuang",         limit: 255
    t.text     "link",               limit: 4294967295
    t.decimal  "cost",                                  precision: 20, scale: 6
    t.string   "info",               limit: 255
    t.integer  "product_id",         limit: 4
    t.string   "moko_part",          limit: 255
    t.string   "moko_des",           limit: 255
    t.boolean  "warn",               limit: 1
    t.integer  "user_id",            limit: 4
    t.boolean  "danger",             limit: 1
    t.boolean  "manual",             limit: 1
    t.boolean  "mark",               limit: 1
    t.string   "mpn",                limit: 255
    t.integer  "mpn_id",             limit: 4
    t.decimal  "price",                                 precision: 20, scale: 6
    t.string   "mf",                 limit: 255
    t.integer  "dn_id",              limit: 4
    t.string   "dn",                 limit: 255
    t.string   "dn_long",            limit: 255
    t.text     "other",              limit: 4294967295
    t.text     "all_info",           limit: 4294967295
    t.text     "remark",             limit: 4294967295
    t.string   "color",              limit: 255,                                 default: ""
    t.string   "supplier_tag",       limit: 255
    t.string   "supplier_out_tag",   limit: 255
    t.string   "sell_feed_back_tag", limit: 255,                                 default: ""
    t.string   "ecn_tag",            limit: 255,                                 default: ""
    t.datetime "created_at",                                                                  null: false
    t.datetime "updated_at",                                                                  null: false
  end

  create_table "pi_bom_qty_infos", force: :cascade do |t|
    t.string   "state",            limit: 10
    t.string   "p_name",           limit: 255
    t.integer  "pi_info_id",       limit: 4
    t.integer  "pi_item_id",       limit: 4
    t.integer  "bom_id",           limit: 4
    t.integer  "moko_bom_info_id", limit: 4
    t.integer  "qty",              limit: 4
    t.integer  "t_qty",            limit: 4
    t.string   "bom_team_ck",      limit: 60
    t.datetime "bom_team_ck_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "pi_buy_baojia_infos", force: :cascade do |t|
    t.string   "state",       limit: 50
    t.string   "zhi_dan_ren", limit: 255
    t.datetime "ti_jiao_at"
    t.string   "shen_he_ren", limit: 255
    t.datetime "shen_he_at"
    t.string   "remark",      limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "pi_buy_baojia_items", force: :cascade do |t|
    t.integer  "pi_buy_baojia_info_id", limit: 4
    t.integer  "pi_pmc_item_id",        limit: 4
    t.integer  "dn_chk_id",             limit: 4
    t.string   "dn_chk",                limit: 255
    t.string   "dn_chk_long",           limit: 255
    t.string   "color",                 limit: 255
    t.string   "remark",                limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "pi_buy_history_items", force: :cascade do |t|
    t.integer  "p_item_id",          limit: 4
    t.integer  "erp_id",             limit: 4
    t.string   "erp_no",             limit: 50
    t.integer  "user_do",            limit: 4
    t.string   "user_do_change",     limit: 255
    t.string   "check",              limit: 255
    t.integer  "pi_buy_info_id",     limit: 4
    t.integer  "procurement_bom_id", limit: 4
    t.integer  "quantity",           limit: 4
    t.integer  "qty",                limit: 4
    t.integer  "wh_qty_in",          limit: 4
    t.string   "description",        limit: 5000
    t.text     "part_code",          limit: 65535
    t.string   "fengzhuang",         limit: 255
    t.text     "link",               limit: 4294967295
    t.decimal  "cost",                                  precision: 20, scale: 6
    t.string   "info",               limit: 255
    t.integer  "product_id",         limit: 4
    t.string   "moko_part",          limit: 255
    t.string   "moko_des",           limit: 255
    t.boolean  "warn",               limit: 1
    t.integer  "user_id",            limit: 4
    t.boolean  "danger",             limit: 1
    t.boolean  "manual",             limit: 1
    t.boolean  "mark",               limit: 1
    t.string   "mpn",                limit: 255
    t.integer  "mpn_id",             limit: 4
    t.decimal  "price",                                 precision: 20, scale: 6
    t.string   "mf",                 limit: 255
    t.integer  "dn_id",              limit: 4
    t.string   "dn",                 limit: 255
    t.string   "dn_long",            limit: 255
    t.text     "other",              limit: 4294967295
    t.text     "all_info",           limit: 4294967295
    t.text     "remark",             limit: 4294967295
    t.string   "color",              limit: 255
    t.string   "supplier_tag",       limit: 255
    t.string   "supplier_out_tag",   limit: 255
    t.string   "sell_feed_back_tag", limit: 255
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
  end

  add_index "pi_buy_history_items", ["color"], name: "color", using: :btree
  add_index "pi_buy_history_items", ["erp_no"], name: "pi_no", using: :btree
  add_index "pi_buy_history_items", ["user_do"], name: "user_do", using: :btree

  create_table "pi_buy_infos", force: :cascade do |t|
    t.string   "pi_buy_no",         limit: 255
    t.string   "user",              limit: 255
    t.string   "state",             limit: 255
    t.integer  "supplier_list_id",  limit: 4
    t.string   "supplier_clearing", limit: 255
    t.string   "supplier_address",  limit: 255
    t.string   "supplier_contacts", limit: 255
    t.string   "supplier_phone",    limit: 255
    t.string   "dn",                limit: 255
    t.string   "dn_long",           limit: 255
    t.decimal  "t_p",                           precision: 20, scale: 6
    t.decimal  "yi_fu_kuan_p",                  precision: 20, scale: 6
    t.datetime "delivery_date"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
  end

  add_index "pi_buy_infos", ["pi_buy_no"], name: "pi_buy_no", using: :btree

  create_table "pi_buy_items", force: :cascade do |t|
    t.integer  "pi_bom_qty_info_item_id", limit: 4
    t.decimal  "yi_fu_kuan_p",                               precision: 20, scale: 6, default: 0.0
    t.integer  "pi_item_id",              limit: 4
    t.integer  "pi_info_id",              limit: 4
    t.integer  "supplier_list_id",        limit: 4
    t.string   "pmc_flag",                limit: 255,                                 default: ""
    t.string   "buy_user",                limit: 255
    t.string   "state",                   limit: 255,                                 default: ""
    t.integer  "pi_pmc_item_id",          limit: 4
    t.integer  "p_item_id",               limit: 4
    t.integer  "erp_id",                  limit: 4
    t.string   "erp_no",                  limit: 50
    t.string   "erp_no_son",              limit: 50
    t.integer  "user_do",                 limit: 4
    t.string   "user_do_change",          limit: 255
    t.string   "check",                   limit: 255
    t.integer  "pi_buy_info_id",          limit: 4
    t.integer  "procurement_bom_id",      limit: 4
    t.integer  "quantity",                limit: 4
    t.integer  "qty",                     limit: 4,                                   default: 0
    t.integer  "pmc_qty",                 limit: 4,                                   default: 0
    t.integer  "buy_qty",                 limit: 4,                                   default: 0
    t.integer  "qty_done",                limit: 4,                                   default: 0
    t.integer  "qty_wait",                limit: 4,                                   default: 0
    t.integer  "wh_qty",                  limit: 4
    t.string   "description",             limit: 5000
    t.text     "part_code",               limit: 65535
    t.string   "fengzhuang",              limit: 255
    t.text     "link",                    limit: 4294967295
    t.decimal  "cost",                                       precision: 20, scale: 6
    t.decimal  "tax_cost",                                   precision: 20, scale: 6
    t.decimal  "tax",                                        precision: 10, scale: 4
    t.decimal  "tax_t_p",                                    precision: 20, scale: 6
    t.datetime "delivery_date"
    t.string   "info",                    limit: 255
    t.integer  "product_id",              limit: 4
    t.string   "moko_part",               limit: 255
    t.string   "moko_des",                limit: 255
    t.boolean  "warn",                    limit: 1
    t.integer  "user_id",                 limit: 4
    t.boolean  "danger",                  limit: 1
    t.boolean  "manual",                  limit: 1
    t.boolean  "mark",                    limit: 1
    t.string   "mpn",                     limit: 255
    t.integer  "mpn_id",                  limit: 4
    t.decimal  "price",                                      precision: 20, scale: 6
    t.string   "mf",                      limit: 255
    t.integer  "dn_id",                   limit: 4
    t.string   "dn",                      limit: 255
    t.string   "dn_long",                 limit: 255
    t.text     "other",                   limit: 4294967295
    t.text     "all_info",                limit: 4294967295
    t.text     "remark",                  limit: 4294967295
    t.string   "color",                   limit: 255
    t.string   "supplier_tag",            limit: 255
    t.string   "supplier_out_tag",        limit: 255
    t.string   "sell_feed_back_tag",      limit: 255
    t.datetime "created_at",                                                                        null: false
    t.datetime "updated_at",                                                                        null: false
  end

  add_index "pi_buy_items", ["color"], name: "color", using: :btree
  add_index "pi_buy_items", ["erp_no"], name: "pi_no", using: :btree
  add_index "pi_buy_items", ["pi_buy_info_id"], name: "pi_buy_info_id", using: :btree
  add_index "pi_buy_items", ["user_do"], name: "user_do", using: :btree

  create_table "pi_fahuotongzhi_items", force: :cascade do |t|
    t.string   "state",            limit: 50
    t.integer  "pi_info_id",       limit: 4
    t.string   "pi_info_no",       limit: 50
    t.string   "pi_kehu",          limit: 255
    t.string   "pi_sell",          limit: 255
    t.string   "xiaoshou_fangshi", limit: 255
    t.string   "bianhao",          limit: 255
    t.string   "wuliu_danhao",     limit: 255
    t.string   "gouhuo_danwei",    limit: 255
    t.string   "bizhong",          limit: 255
    t.string   "huilv",            limit: 255
    t.string   "jiesuan_fangshi",  limit: 255
    t.string   "yunshu_fangshi",   limit: 255
    t.string   "maoyi_fangshi",    limit: 255
    t.string   "zhifu_fangshi",    limit: 255
    t.string   "xuandan_hao",      limit: 255
    t.string   "shenhe",           limit: 255
    t.datetime "shenhe_date"
    t.string   "xinyong_beizhu",   limit: 255
    t.string   "yewu_yuan",        limit: 255
    t.string   "bumen",            limit: 255
    t.string   "zhidan",           limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.datetime "tijiao_at"
  end

  create_table "pi_fengmian_items", force: :cascade do |t|
    t.integer  "pi_info_id",        limit: 4
    t.string   "kehufenlei",        limit: 5
    t.string   "kehuleixing",       limit: 5
    t.string   "pi_no",             limit: 20
    t.integer  "qty",               limit: 4
    t.datetime "pi_date"
    t.string   "pi_type",           limit: 5
    t.string   "pi_back_no",        limit: 50
    t.string   "moko_des",          limit: 255
    t.string   "moko_part",         limit: 255
    t.string   "pcb_gongyi",        limit: 255
    t.string   "kegongwuliao",      limit: 5
    t.datetime "get_date"
    t.string   "yangpin",           limit: 5
    t.integer  "yangpin_qty",       limit: 4
    t.string   "zuzhuangfangshi",   limit: 5
    t.string   "zuichang_weihao",   limit: 255
    t.string   "zuichang_xinghao",  limit: 255
    t.datetime "zuichang_date"
    t.string   "shifou_a",          limit: 5
    t.string   "shifou_b",          limit: 5
    t.string   "shifou_c",          limit: 5
    t.string   "shifou_d",          limit: 5
    t.string   "shifou_e",          limit: 5
    t.string   "shifou_f",          limit: 5
    t.string   "shifou_g",          limit: 5
    t.string   "shifou_h",          limit: 5
    t.string   "shifou_i",          limit: 5
    t.string   "shifou_j",          limit: 5
    t.string   "ic_weihao_xinghao", limit: 255
    t.string   "shifou_l",          limit: 5
    t.string   "shifou_m",          limit: 5
    t.string   "shifou_n",          limit: 5
    t.string   "shifou_o",          limit: 5
    t.string   "shifou_p",          limit: 5
    t.string   "shifou_q",          limit: 5
    t.string   "shifou_r",          limit: 5
    t.string   "shifou_s",          limit: 5
    t.string   "pi_teshuxuqiu",     limit: 255
    t.string   "kesu_issue",        limit: 255
    t.string   "eng_bom_baojia",    limit: 255
    t.string   "eng_bom_youhua",    limit: 255
    t.string   "eng_pnp_youhua",    limit: 255
    t.string   "eng_pcb_jianyan",   limit: 255
    t.string   "eng_shoujianhedui", limit: 255
    t.string   "eng_test_zhidao",   limit: 255
    t.string   "eng_qc",            limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "pi_fengmian_items", ["pi_info_id"], name: "pi_info_id", using: :btree

  create_table "pi_infos", force: :cascade do |t|
    t.integer  "bank_info_id",           limit: 4
    t.string   "pi_lock",                limit: 255
    t.string   "state",                  limit: 255,                            default: ""
    t.string   "bom_state",              limit: 255
    t.string   "buy_state",              limit: 255
    t.integer  "finance_state",          limit: 4
    t.string   "pi_bank_info",           limit: 11
    t.string   "pi_bank_account_name",   limit: 255
    t.string   "pi_bank_account_number", limit: 255
    t.string   "pi_remark",              limit: 500
    t.integer  "edit_time",              limit: 4
    t.integer  "pcb_customer_id",        limit: 4
    t.string   "c_code",                 limit: 255
    t.string   "c_des",                  limit: 255
    t.string   "c_country",              limit: 255
    t.string   "c_shipping_address",     limit: 1000
    t.string   "p_name",                 limit: 255,                            default: ""
    t.string   "des_en",                 limit: 255,                            default: ""
    t.string   "des_cn",                 limit: 255,                            default: ""
    t.string   "pi_no",                  limit: 255
    t.string   "att",                    limit: 255
    t.string   "sell",                   limit: 255
    t.string   "pi_sell",                limit: 255
    t.string   "team",                   limit: 255
    t.string   "phone",                  limit: 255
    t.string   "price_eng",              limit: 255
    t.decimal  "price",                                precision: 10, scale: 2
    t.integer  "qty",                    limit: 4
    t.decimal  "other_price",                          precision: 20, scale: 6
    t.datetime "target"
    t.string   "su",                     limit: 255
    t.text     "remark",                 limit: 65535
    t.text     "follow_remark",          limit: 65535
    t.decimal  "pi_shipping_cost",                     precision: 20, scale: 6
    t.decimal  "pi_bank_fee",                          precision: 20, scale: 6
    t.decimal  "t_p",                                  precision: 20, scale: 6
    t.decimal  "t_p_rmb",                              precision: 20, scale: 6
    t.datetime "created_at",                                                                    null: false
    t.datetime "updated_at",                                                                    null: false
    t.datetime "jiao_huo_at"
    t.integer  "user_id",                limit: 4
    t.integer  "bei_pin_qty",            limit: 4
    t.integer  "money_type",             limit: 4,                              default: 0
    t.decimal  "rate",                                 precision: 20, scale: 6
    t.text     "logger_info",            limit: 65535
    t.boolean  "finance_hide",           limit: 1,                              default: false
  end

  add_index "pi_infos", ["pi_no"], name: "pi_no", using: :btree

  create_table "pi_items", force: :cascade do |t|
    t.integer  "moko_bom_info_id",   limit: 4
    t.integer  "pi_bom_qty_info_id", limit: 4
    t.string   "to_pmc_state",       limit: 255,                          default: ""
    t.datetime "sell_at"
    t.datetime "caiwu_at"
    t.datetime "bom_at"
    t.datetime "caigou_at"
    t.datetime "pmc_at"
    t.string   "state",              limit: 255,                          default: ""
    t.string   "bom_state",          limit: 255,                          default: ""
    t.string   "buy_state",          limit: 255,                          default: ""
    t.string   "finance_state",      limit: 255,                          default: ""
    t.integer  "order_item_id",      limit: 4
    t.integer  "bom_id",             limit: 4
    t.integer  "c_id",               limit: 4
    t.integer  "pi_info_id",         limit: 4
    t.string   "pi_no",              limit: 255
    t.string   "moko_code",          limit: 255
    t.string   "moko_des",           limit: 255
    t.string   "des_en",             limit: 255
    t.string   "des_cn",             limit: 255
    t.string   "p_type",             limit: 255
    t.string   "moko_attribute",     limit: 255
    t.decimal  "price",                          precision: 20, scale: 6
    t.string   "att",                limit: 255
    t.string   "remark",             limit: 500
    t.datetime "created_at",                                                            null: false
    t.datetime "updated_at",                                                            null: false
    t.string   "c_p_no",             limit: 255
    t.string   "pcb_size",           limit: 255
    t.integer  "qty",                limit: 4
    t.string   "layer",              limit: 255
    t.string   "des",                limit: 500
    t.decimal  "unit_price",                     precision: 20, scale: 6, default: 0.0
    t.decimal  "pcb_price",                      precision: 20, scale: 6, default: 0.0
    t.decimal  "com_cost",                       precision: 20, scale: 6, default: 0.0
    t.decimal  "pcba",                           precision: 20, scale: 6, default: 0.0
    t.decimal  "t_p",                            precision: 20, scale: 6
    t.decimal  "bank_fee",                       precision: 20, scale: 6, default: 0.0
    t.decimal  "shipping_cost",                  precision: 20, scale: 6, default: 0.0
    t.decimal  "in_total",                       precision: 20, scale: 6
    t.decimal  "in_total_rmb",                   precision: 20, scale: 6
  end

  create_table "pi_other_items", force: :cascade do |t|
    t.integer  "c_id",       limit: 4
    t.integer  "pi_info_id", limit: 4
    t.string   "pi_no",      limit: 255
    t.string   "p_type",     limit: 255
    t.decimal  "t_p",                    precision: 20, scale: 6
    t.string   "remark",     limit: 500
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  create_table "pi_pmc_add_infos", force: :cascade do |t|
    t.string   "state",      limit: 255, default: ""
    t.string   "user",       limit: 255
    t.string   "no",         limit: 30
    t.string   "remark",     limit: 500
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "pi_pmc_add_items", force: :cascade do |t|
    t.string   "state",              limit: 255, default: ""
    t.integer  "pi_pmc_add_info_id", limit: 4
    t.string   "pi_pmc_add_info_no", limit: 30
    t.string   "moko_part",          limit: 255
    t.string   "moko_des",           limit: 255
    t.integer  "pmc_qty",            limit: 4,   default: 0
    t.string   "buy_user",           limit: 255
    t.string   "remark",             limit: 500
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  create_table "pi_pmc_items", force: :cascade do |t|
    t.string   "baojia_state",            limit: 255
    t.string   "up_flag",                 limit: 10
    t.integer  "pi_bom_qty_info_item_id", limit: 4
    t.integer  "pi_info_id",              limit: 4
    t.integer  "pi_item_id",              limit: 4
    t.string   "pmc_flag",                limit: 255,                                 default: ""
    t.string   "state",                   limit: 255,                                 default: ""
    t.string   "pmc_type",                limit: 255,                                 default: ""
    t.string   "buy_type",                limit: 255,                                 default: ""
    t.string   "erp_no",                  limit: 50
    t.string   "erp_no_son",              limit: 255
    t.string   "moko_part",               limit: 255
    t.string   "moko_des",                limit: 255
    t.text     "part_code",               limit: 65535
    t.integer  "qty",                     limit: 4
    t.integer  "pmc_qty",                 limit: 4,                                   default: 0
    t.integer  "qty_in",                  limit: 4
    t.text     "remark",                  limit: 4294967295
    t.string   "buy_user",                limit: 255,                                 default: ""
    t.integer  "buy_qty",                 limit: 4,                                   default: 0
    t.integer  "buyer_qty",               limit: 4,                                   default: 0
    t.integer  "p_item_id",               limit: 4
    t.integer  "erp_id",                  limit: 4
    t.integer  "user_do",                 limit: 4
    t.string   "user_do_change",          limit: 255
    t.string   "check",                   limit: 255,                                 default: ""
    t.integer  "pi_buy_info_id",          limit: 4
    t.integer  "procurement_bom_id",      limit: 4
    t.integer  "quantity",                limit: 4
    t.integer  "qty_done",                limit: 4,                                   default: 0
    t.integer  "qty_wait",                limit: 4,                                   default: 0
    t.integer  "wh_qty",                  limit: 4
    t.string   "description",             limit: 5000
    t.string   "fengzhuang",              limit: 255
    t.text     "link",                    limit: 4294967295
    t.decimal  "cost",                                       precision: 20, scale: 6
    t.string   "info",                    limit: 255
    t.integer  "product_id",              limit: 4
    t.boolean  "warn",                    limit: 1
    t.integer  "user_id",                 limit: 4
    t.boolean  "danger",                  limit: 1
    t.boolean  "manual",                  limit: 1
    t.boolean  "mark",                    limit: 1
    t.string   "mpn",                     limit: 255
    t.integer  "mpn_id",                  limit: 4
    t.decimal  "price",                                      precision: 20, scale: 6
    t.string   "mf",                      limit: 255
    t.integer  "dn_id",                   limit: 4
    t.string   "dn",                      limit: 255
    t.string   "dn_long",                 limit: 255
    t.integer  "dn_chk_id",               limit: 4
    t.string   "dn_chk",                  limit: 255
    t.string   "dn_chk_long",             limit: 255
    t.text     "other",                   limit: 4294967295
    t.text     "all_info",                limit: 4294967295
    t.string   "color",                   limit: 255
    t.string   "supplier_tag",            limit: 255
    t.string   "supplier_out_tag",        limit: 255
    t.string   "sell_feed_back_tag",      limit: 255
    t.datetime "pass_at"
    t.datetime "created_at",                                                                       null: false
    t.datetime "updated_at",                                                                       null: false
  end

  add_index "pi_pmc_items", ["color"], name: "color", using: :btree
  add_index "pi_pmc_items", ["erp_no"], name: "pi_no", using: :btree
  add_index "pi_pmc_items", ["user_do"], name: "user_do", using: :btree

  create_table "pi_sell_items", force: :cascade do |t|
    t.integer "pi_info_id",        limit: 4
    t.integer "pcb_order_item_id", limit: 4
    t.string  "c_p_no",            limit: 255
    t.string  "pcb_size",          limit: 255
    t.integer "qty",               limit: 4
    t.string  "layer",             limit: 255
    t.string  "des",               limit: 500
    t.decimal "unit_price",                    precision: 20, scale: 6
    t.decimal "pcb_price",                     precision: 20, scale: 6
    t.decimal "com_cost",                      precision: 20, scale: 6
    t.decimal "pcba",                          precision: 20, scale: 6
    t.decimal "t_p",                           precision: 20, scale: 6
    t.decimal "bank_fee",                      precision: 20, scale: 6
    t.decimal "shipping_cost",                 precision: 20, scale: 6
    t.decimal "in_total",                      precision: 20, scale: 6
    t.decimal "in_total_rmb",                  precision: 20, scale: 6
  end

  create_table "pi_wh_change_infos", force: :cascade do |t|
    t.string   "site",            limit: 255, default: ""
    t.string   "pi_wh_change_no", limit: 255
    t.string   "wh_user",         limit: 255
    t.string   "state",           limit: 255
    t.string   "dn",              limit: 255
    t.string   "dn_long",         limit: 255
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  create_table "pi_wh_change_items", force: :cascade do |t|
    t.integer  "pi_wh_change_info_id", limit: 4
    t.string   "pi_wh_change_info_no", limit: 255
    t.string   "moko_part",            limit: 255
    t.string   "moko_des",             limit: 255
    t.integer  "qty_in",               limit: 4,          default: 0
    t.text     "remark",               limit: 4294967295
    t.string   "state",                limit: 255
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  create_table "pi_wh_infos", force: :cascade do |t|
    t.string   "site",        limit: 255, default: ""
    t.string   "pi_wh_no",    limit: 255
    t.string   "wh_user",     limit: 255
    t.string   "state",       limit: 255
    t.string   "dn",          limit: 255
    t.string   "dn_long",     limit: 255
    t.string   "song_huo_no", limit: 255
    t.string   "remark",      limit: 500
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "pi_wh_items", force: :cascade do |t|
    t.string   "wh_type",            limit: 20,         default: ""
    t.string   "pmc_flag",           limit: 255,        default: ""
    t.integer  "pi_pmc_item_id",     limit: 4
    t.string   "buy_user",           limit: 255
    t.integer  "pi_wh_info_id",      limit: 4
    t.string   "pi_wh_info_no",      limit: 255
    t.integer  "pi_buy_item_id",     limit: 4
    t.string   "moko_part",          limit: 255
    t.string   "moko_des",           limit: 255
    t.integer  "qty_in",             limit: 4,          default: 0
    t.text     "remark",             limit: 4294967295
    t.integer  "p_item_id",          limit: 4
    t.integer  "erp_id",             limit: 4
    t.string   "erp_no",             limit: 50
    t.integer  "pi_buy_info_id",     limit: 4
    t.integer  "procurement_bom_id", limit: 4
    t.string   "state",              limit: 255
    t.integer  "supplier_list_id",   limit: 4
    t.integer  "dn_id",              limit: 4
    t.string   "dn",                 limit: 255
    t.string   "dn_long",            limit: 255
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  create_table "procurement_boms", force: :cascade do |t|
    t.string   "dai_ma",              limit: 255,                                 default: ""
    t.string   "jia_ji",              limit: 255,                                 default: ""
    t.string   "state",               limit: 255,                                 default: ""
    t.string   "pi_lock",             limit: 255,                                 default: ""
    t.integer  "moko_bom_info_id",    limit: 4
    t.string   "bom_id",              limit: 11
    t.string   "bom_active",          limit: 20,                                  default: "active"
    t.string   "bom_lock",            limit: 255
    t.string   "change_flag",         limit: 10,                                  default: ""
    t.integer  "bom_version",         limit: 4,                                   default: 1
    t.integer  "erp_id",              limit: 4
    t.integer  "erp_item_id",         limit: 4
    t.string   "erp_no",              limit: 255
    t.string   "erp_no_son",          limit: 255
    t.integer  "erp_qty",             limit: 4
    t.string   "order_do",            limit: 255
    t.string   "order_country",       limit: 255
    t.integer  "star",                limit: 4
    t.text     "sell_remark",         limit: 4294967295
    t.text     "sell_manager_remark", limit: 4294967295
    t.string   "check",               limit: 255
    t.string   "no",                  limit: 255
    t.string   "name",                limit: 255
    t.string   "p_name_mom",          limit: 255
    t.string   "p_name",              limit: 255
    t.integer  "qty",                 limit: 4
    t.text     "remark",              limit: 4294967295
    t.decimal  "t_p",                                    precision: 20, scale: 6
    t.integer  "profit",              limit: 4
    t.decimal  "t_pp",                                   precision: 20, scale: 6
    t.string   "d_day",               limit: 255
    t.string   "description",         limit: 255
    t.string   "excel_file",          limit: 255
    t.string   "att",                 limit: 255
    t.decimal  "pcb_p",                                  precision: 20, scale: 6
    t.string   "pcb_file",            limit: 255
    t.string   "pcb_layer",           limit: 255
    t.integer  "pcb_qty",             limit: 4
    t.integer  "pcb_size_c",          limit: 4
    t.integer  "pcb_size_k",          limit: 4
    t.string   "pcb_sc",              limit: 255
    t.string   "pcb_material",        limit: 255
    t.string   "pcb_cc",              limit: 255
    t.string   "pcb_ct",              limit: 255
    t.string   "pcb_sf",              limit: 255
    t.string   "pcb_t",               limit: 255
    t.integer  "t_c",                 limit: 4
    t.decimal  "c_p",                                    precision: 20, scale: 6
    t.integer  "user_id",             limit: 4
    t.text     "all_title",           limit: 4294967295
    t.integer  "row_use",             limit: 4
    t.string   "bom_eng_up",          limit: 255
    t.string   "bom_eng",             limit: 255
    t.string   "bom_team_ck",         limit: 255
    t.datetime "bom_team_ck_at"
    t.string   "remark_to_sell",      limit: 255
    t.datetime "remark_to_sell_at"
    t.string   "sell_feed_back_tag",  limit: 255
    t.datetime "created_at",                                                                         null: false
    t.datetime "updated_at",                                                                         null: false
    t.integer  "p_items_count",       limit: 4
  end

  add_index "procurement_boms", ["p_name"], name: "p_name", using: :btree

  create_table "procurement_version_boms", force: :cascade do |t|
    t.string   "bom_lock",            limit: 255
    t.integer  "procurement_bom_id",  limit: 4
    t.string   "bom_version",         limit: 255
    t.integer  "erp_id",              limit: 4
    t.integer  "erp_item_id",         limit: 4
    t.string   "erp_no",              limit: 255
    t.string   "erp_no_son",          limit: 255
    t.integer  "erp_qty",             limit: 4
    t.string   "order_do",            limit: 255
    t.string   "order_country",       limit: 255
    t.integer  "star",                limit: 4
    t.text     "sell_remark",         limit: 4294967295
    t.text     "sell_manager_remark", limit: 4294967295
    t.string   "check",               limit: 255
    t.string   "no",                  limit: 255
    t.string   "name",                limit: 255
    t.string   "p_name_mom",          limit: 255
    t.string   "p_name",              limit: 255
    t.integer  "qty",                 limit: 4
    t.text     "remark",              limit: 4294967295
    t.decimal  "t_p",                                    precision: 20, scale: 6
    t.integer  "profit",              limit: 4
    t.decimal  "t_pp",                                   precision: 20, scale: 6
    t.string   "d_day",               limit: 255
    t.string   "description",         limit: 255
    t.string   "excel_file",          limit: 255
    t.string   "att",                 limit: 255
    t.decimal  "pcb_p",                                  precision: 20, scale: 6
    t.string   "pcb_file",            limit: 255
    t.string   "pcb_layer",           limit: 255
    t.integer  "pcb_qty",             limit: 4
    t.integer  "pcb_size_c",          limit: 4
    t.integer  "pcb_size_k",          limit: 4
    t.string   "pcb_sc",              limit: 255
    t.string   "pcb_material",        limit: 255
    t.string   "pcb_cc",              limit: 255
    t.string   "pcb_ct",              limit: 255
    t.string   "pcb_sf",              limit: 255
    t.string   "pcb_t",               limit: 255
    t.integer  "t_c",                 limit: 4
    t.decimal  "c_p",                                    precision: 20, scale: 6
    t.integer  "user_id",             limit: 4
    t.text     "all_title",           limit: 4294967295
    t.integer  "row_use",             limit: 4
    t.string   "bom_eng_up",          limit: 255
    t.string   "bom_eng",             limit: 255
    t.string   "bom_team_ck",         limit: 255
    t.string   "remark_to_sell",      limit: 255
    t.string   "sell_feed_back_tag",  limit: 255
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
  end

  add_index "procurement_version_boms", ["p_name"], name: "p_name", using: :btree

  create_table "products", force: :cascade do |t|
    t.integer  "part_no",           limit: 4
    t.string   "all_des_cn",        limit: 800
    t.string   "all_des_en",        limit: 800
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
    t.string   "value9",            limit: 255
    t.string   "value10",           limit: 255
  end

  add_index "products", ["description"], name: "des", using: :btree
  add_index "products", ["name"], name: "name", using: :btree
  add_index "products", ["package2"], name: "package2", using: :btree
  add_index "products", ["product_able_id", "product_able_type"], name: "index_products_on_product_able_id_and_product_able_type", using: :btree

  create_table "products_copy20160728", force: :cascade do |t|
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

  add_index "products_copy20160728", ["description"], name: "des", using: :btree
  add_index "products_copy20160728", ["name"], name: "name", using: :btree
  add_index "products_copy20160728", ["package2"], name: "package2", using: :btree
  add_index "products_copy20160728", ["product_able_id", "product_able_type"], name: "index_products_on_product_able_id_and_product_able_type", using: :btree

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

  create_table "setup_finance_infos", force: :cascade do |t|
    t.decimal  "dollar_rate",           precision: 10, scale: 5
    t.integer  "user_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "supplier_bank_lists", force: :cascade do |t|
    t.string   "supplier_code",         limit: 255
    t.string   "supplier_name",         limit: 255
    t.string   "supplier_tax",          limit: 255
    t.string   "supplier_name_long",    limit: 255
    t.string   "supplier_bank_user",    limit: 255
    t.string   "supplier_bank_account", limit: 255
    t.string   "supplier_bank_name",    limit: 255
    t.string   "remark",                limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "supplier_d_lists", force: :cascade do |t|
    t.string   "dn_name",     limit: 255
    t.string   "dn_all_name", limit: 255
    t.string   "money",       limit: 255
    t.string   "remark",      limit: 2000
    t.string   "state",       limit: 255,  default: ""
    t.string   "back",        limit: 255,  default: ""
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "supplier_lists", force: :cascade do |t|
    t.string   "supplier_name",             limit: 255
    t.string   "supplier_code",             limit: 255
    t.string   "supplier_part_type_code",   limit: 255
    t.string   "supplier_part_type",        limit: 255
    t.string   "supplier_tax",              limit: 255
    t.string   "supplier_clearing",         limit: 255
    t.string   "supplier_remark",           limit: 255
    t.string   "supplier_name_long",        limit: 255
    t.string   "supplier_label",            limit: 255
    t.string   "supplier_type",             limit: 255
    t.string   "supplier_address",          limit: 255
    t.string   "supplier_invoice_fullname", limit: 255
    t.string   "supplier_contacts",         limit: 255
    t.string   "supplier_phone",            limit: 255
    t.string   "supplier_qq",               limit: 255
    t.string   "supplier_bank_user",        limit: 255
    t.string   "supplier_bank_name",        limit: 255
    t.string   "supplier_bank_account",     limit: 255
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "pay_type_id",               limit: 1
  end

  create_table "timesheets", force: :cascade do |t|
    t.string   "order_no",   limit: 255, default: ""
    t.integer  "order_id",   limit: 4
    t.integer  "gangwang",   limit: 4
    t.integer  "guolu",      limit: 4
    t.integer  "ceshi",      limit: 4
    t.float    "smt_time",   limit: 24
    t.float    "dip_time",   limit: 24
    t.float    "ceshi_time", limit: 24
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
    t.text     "mark",                  limit: 4294967295
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
    t.string   "en_name",                limit: 255
    t.string   "tel",                    limit: 255
    t.string   "fax",                    limit: 255
    t.string   "add",                    limit: 600
    t.string   "phone",                  limit: 255
    t.string   "team",                   limit: 255
    t.string   "full_name",              limit: 255, default: ""
    t.string   "s_name",                 limit: 255
    t.string   "s_name_self",            limit: 255
    t.string   "open_id",                limit: 255
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
    t.string   "menu_a",                 limit: 4
    t.string   "menu_b",                 limit: 4
    t.string   "menu_c",                 limit: 4
    t.string   "menu_d",                 limit: 4
    t.string   "menu_e",                 limit: 4
    t.string   "menu_f",                 limit: 4
    t.string   "block_a",                limit: 4
    t.string   "block_b",                limit: 4
    t.string   "block_c",                limit: 4
    t.string   "block_d",                limit: 4
    t.string   "block_e",                limit: 4
    t.string   "block_f",                limit: 4
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

  create_table "warehouse_infos", force: :cascade do |t|
    t.string   "moko_type",         limit: 50,         default: ""
    t.string   "erp_no_son",        limit: 255,        default: ""
    t.string   "moko_part",         limit: 255
    t.string   "moko_des",          limit: 255
    t.integer  "qty",               limit: 4,          default: 0
    t.integer  "future_qty",        limit: 4,          default: 0
    t.integer  "temp_future_qty",   limit: 4,          default: 0
    t.integer  "temp_buy_qty",      limit: 4,          default: 0
    t.integer  "true_buy_qty",      limit: 4,          default: 0
    t.integer  "temp_moko_qty",     limit: 4,          default: 0
    t.integer  "temp_customer_qty", limit: 4,          default: 0
    t.integer  "loss_qty",          limit: 4,          default: 0
    t.integer  "wh_qty",            limit: 4,          default: 0
    t.integer  "wh_c_qty",          limit: 4,          default: 0
    t.integer  "wh_f_qty",          limit: 4,          default: 0
    t.text     "remark",            limit: 4294967295
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  add_index "warehouse_infos", ["moko_part"], name: "moko_part", using: :btree

  create_table "wh_chk_infos", force: :cascade do |t|
    t.integer  "pi_pmc_item_id", limit: 4
    t.string   "erp_no_son",     limit: 255
    t.integer  "p_item_id",      limit: 4
    t.string   "moko_part",      limit: 255
    t.string   "moko_des",       limit: 255
    t.integer  "chk_qty",        limit: 4
    t.integer  "apply_for_qty",  limit: 4
    t.integer  "loss_qty",       limit: 4
    t.string   "state",          limit: 255, default: ""
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "wh_get_infos", force: :cascade do |t|
    t.string   "site",         limit: 255, default: ""
    t.string   "wh_get_no",    limit: 255
    t.string   "wh_get_user",  limit: 255
    t.string   "wh_send_user", limit: 255
    t.string   "pi_no",        limit: 20
    t.string   "state",        limit: 255
    t.string   "remark",       limit: 500
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "wh_get_items", force: :cascade do |t|
    t.string   "pmc_flag",           limit: 255,        default: ""
    t.integer  "pi_pmc_item_id",     limit: 4
    t.string   "buy_user",           limit: 255
    t.integer  "pi_buy_item_id",     limit: 4
    t.integer  "wh_get_info_id",     limit: 4
    t.string   "wh_get_info_no",     limit: 255
    t.string   "moko_part",          limit: 255
    t.string   "moko_des",           limit: 255
    t.integer  "qty",                limit: 4
    t.integer  "qty_out",            limit: 4,          default: 0
    t.text     "remark",             limit: 4294967295
    t.integer  "p_item_id",          limit: 4
    t.integer  "erp_id",             limit: 4
    t.string   "erp_no_son",         limit: 50
    t.integer  "pi_buy_info_id",     limit: 4
    t.integer  "procurement_bom_id", limit: 4
    t.string   "state",              limit: 255
    t.integer  "supplier_list_id",   limit: 4
    t.integer  "dn_id",              limit: 4
    t.string   "dn",                 limit: 255
    t.string   "dn_long",            limit: 255
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  create_table "wh_in_history_items", force: :cascade do |t|
    t.integer  "p_item_id",          limit: 4
    t.integer  "erp_id",             limit: 4
    t.string   "erp_no",             limit: 50
    t.string   "erp_no_son",         limit: 50
    t.integer  "user_do",            limit: 4
    t.string   "user_do_change",     limit: 255
    t.string   "check",              limit: 255
    t.integer  "pi_buy_info_id",     limit: 4
    t.integer  "procurement_bom_id", limit: 4
    t.integer  "quantity",           limit: 4
    t.integer  "qty",                limit: 4
    t.integer  "wh_qty_in",          limit: 4
    t.string   "description",        limit: 5000
    t.text     "part_code",          limit: 65535
    t.string   "fengzhuang",         limit: 255
    t.text     "link",               limit: 4294967295
    t.decimal  "cost",                                  precision: 20, scale: 6
    t.string   "info",               limit: 255
    t.integer  "product_id",         limit: 4
    t.string   "moko_part",          limit: 255
    t.string   "moko_des",           limit: 255
    t.boolean  "warn",               limit: 1
    t.integer  "user_id",            limit: 4
    t.boolean  "danger",             limit: 1
    t.boolean  "manual",             limit: 1
    t.boolean  "mark",               limit: 1
    t.string   "mpn",                limit: 255
    t.integer  "mpn_id",             limit: 4
    t.decimal  "price",                                 precision: 20, scale: 6
    t.string   "mf",                 limit: 255
    t.integer  "dn_id",              limit: 4
    t.string   "dn",                 limit: 255
    t.string   "dn_long",            limit: 255
    t.text     "other",              limit: 4294967295
    t.text     "all_info",           limit: 4294967295
    t.text     "remark",             limit: 4294967295
    t.string   "color",              limit: 255
    t.string   "supplier_tag",       limit: 255
    t.string   "supplier_out_tag",   limit: 255
    t.string   "sell_feed_back_tag", limit: 255
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
  end

  add_index "wh_in_history_items", ["color"], name: "color", using: :btree
  add_index "wh_in_history_items", ["erp_no"], name: "pi_no", using: :btree
  add_index "wh_in_history_items", ["user_do"], name: "user_do", using: :btree

  create_table "wh_out_infos", force: :cascade do |t|
    t.string   "site",         limit: 255, default: ""
    t.string   "wh_out_no",    limit: 255
    t.string   "wh_out_user",  limit: 255
    t.string   "wh_send_user", limit: 255
    t.string   "pi_no",        limit: 20
    t.string   "state",        limit: 255
    t.string   "remark",       limit: 500
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "wh_out_items", force: :cascade do |t|
    t.string   "out_type",              limit: 20,         default: ""
    t.integer  "wh_info_id",            limit: 4
    t.integer  "wh_in_history_item_id", limit: 4
    t.string   "pmc_flag",              limit: 255,        default: ""
    t.integer  "pi_pmc_item_id",        limit: 4
    t.string   "buy_user",              limit: 255
    t.integer  "pi_buy_item_id",        limit: 4
    t.integer  "wh_out_info_id",        limit: 4
    t.string   "wh_out_info_no",        limit: 255
    t.string   "moko_part",             limit: 255
    t.string   "moko_des",              limit: 255
    t.integer  "qty",                   limit: 4
    t.integer  "qty_out",               limit: 4,          default: 0
    t.text     "remark",                limit: 4294967295
    t.integer  "p_item_id",             limit: 4
    t.integer  "erp_id",                limit: 4
    t.string   "erp_no_son",            limit: 50
    t.integer  "pi_buy_info_id",        limit: 4
    t.integer  "procurement_bom_id",    limit: 4
    t.string   "state",                 limit: 255
    t.integer  "supplier_list_id",      limit: 4
    t.integer  "dn_id",                 limit: 4
    t.string   "dn",                    limit: 255
    t.string   "dn_long",               limit: 255
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

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
    t.float    "ceshi_time",          limit: 24,         default: 0.0
    t.float    "total_time",          limit: 24,         default: 0.0
    t.date     "last_at"
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

  create_table "zong_zhang_dai_items", force: :cascade do |t|
    t.integer  "zong_zhang_info_id", limit: 4
    t.string   "dai_fang_kemu",      limit: 255
    t.decimal  "dai_fang",                       precision: 20, scale: 6
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
  end

  create_table "zong_zhang_infos", force: :cascade do |t|
    t.string   "zong_zhang_type",         limit: 255,                          default: ""
    t.integer  "finance_voucher_info_id", limit: 4
    t.integer  "fu_kuan_dan_info_id",     limit: 4
    t.integer  "no",                      limit: 4
    t.string   "des",                     limit: 255
    t.string   "jie_fang_kemu",           limit: 255
    t.string   "dai_fang_kemu",           limit: 255
    t.decimal  "jie_fang",                            precision: 20, scale: 6
    t.decimal  "dai_fang",                            precision: 20, scale: 6
    t.datetime "finance_at"
    t.string   "remark",                  limit: 255
    t.datetime "created_at",                                                                null: false
    t.datetime "updated_at",                                                                null: false
  end

  create_table "zong_zhang_jie_items", force: :cascade do |t|
    t.integer  "zong_zhang_info_id", limit: 4
    t.string   "jie_fang_kemu",      limit: 255
    t.decimal  "jie_fang",                       precision: 20, scale: 6
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
  end

end
