class CreateTable < ActiveRecord::Migration
	def change
		create_table "admins", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
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
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.index ["email"], name: "index_admins_on_email", unique: true, using: :btree
			t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree
		end

		create_table "all_dns", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.datetime "date", null: false
			t.string "dn"
			t.string "dn_long"
			t.string "part_code"
			t.string "des"
			t.integer "qty"
			t.decimal "price", precision: 20, scale: 6
			t.index ["des"], name: "des", using: :btree
			t.index ["dn"], name: "dn", using: :btree
			t.index ["part_code"], name: "part_code", using: :btree
			t.index ["price"], name: "price", using: :btree
		end

		create_table "all_parts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "mpn"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "all_parts_bak", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
			t.string "mpn", collation: "utf8_unicode_ci"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "bank_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "des"
			t.string "bank_name"
			t.string "bank_account"
			t.string "user_name"
			t.string "first_name"
			t.string "last_name"
			t.string "bank_address"
			t.string "swift_code"
			t.string "bank_code"
			t.string "remark"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "billing_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "user_id", unsigned: true
			t.string "first_name"
			t.string "last_name"
			t.string "address_line"
			t.string "postal_code"
			t.string "email"
			t.string "phone"
			t.string "city"
			t.string "country"
			t.string "country_name"
			t.string "company"
			t.index ["user_id"], name: "user_id", using: :btree
		end

		create_table "bom_ecn_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "state", default: "new"
			t.integer "no"
			t.integer "bom_id"
			t.string "pi_id"
			t.integer "pi_item_id"
			t.string "pi_no", limit: 50
			t.string "bom_no", limit: 50
			t.string "chan_pin_xing_hao"
			t.integer "fa_qi_ren_id"
			t.string "fa_qi_ren_name"
			t.integer "shen_he_ren_id"
			t.string "shen_he_ren_name"
			t.integer "pi_zhun_ren_id"
			t.string "pi_zhun_ren_name"
			t.datetime "zhi_xing_date_at"
			t.datetime "bom_update_date_at"
			t.string "change_type"
			t.string "sheng_xiao_type"
			t.string "remark"
			t.datetime "send_at"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "bom_ecn_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "state", default: "new"
			t.integer "bom_ecn_info_id"
			t.integer "bom_item_id"
			t.integer "moko_bom_item_id"
			t.string "old_moko_part"
			t.string "old_moko_des"
			t.string "old_part_code"
			t.integer "old_quantity"
			t.string "new_moko_part"
			t.string "new_sell_des"
			t.string "new_moko_des"
			t.string "new_part_code"
			t.integer "new_quantity"
			t.string "change_type", default: ""
			t.string "remark"
			t.string "eng_moko_part"
			t.string "eng_moko_des"
			t.string "eng_part_code"
			t.string "eng_quantity"
			t.string "eng_remark"
			t.string "opt_type", default: ""
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "bom_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "quantity"
			t.string "description"
			t.text "part_code", limit: 65535
			t.integer "bom_id"
			t.integer "product_id"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.boolean "warn"
			t.integer "user_id"
			t.boolean "danger"
			t.boolean "manual"
			t.boolean "mark"
			t.string "mpn"
			t.integer "mpn_id"
			t.decimal "price", precision: 10, scale: 4
			t.string "mf"
			t.string "dn"
			t.text "other", limit: 4294967295
		end

		create_table "boms", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "no"
			t.string "name"
			t.string "p_name"
			t.integer "qty"
			t.decimal "t_p", precision: 10
			t.string "d_day"
			t.string "description"
			t.string "excel_file"
			t.decimal "pcb_p", precision: 10
			t.string "pcb_file"
			t.string "pcb_layer"
			t.integer "pcb_qty"
			t.integer "pcb_size_c"
			t.integer "pcb_size_k"
			t.string "pcb_sc"
			t.string "pcb_material"
			t.string "pcb_cc"
			t.string "pcb_ct"
			t.string "pcb_sf"
			t.string "pcb_t"
			t.integer "t_c"
			t.decimal "c_p", precision: 10
			t.integer "user_id"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.index ["name"], name: "name", using: :btree
			t.index ["user_id"], name: "uid", using: :btree
		end

		create_table "cai_gou_fa_piao_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "fa_piao_state", default: "new"
			t.string "site", default: ""
			t.string "pi_wh_id"
			t.string "pi_wh_no"
			t.string "wh_user"
			t.string "state"
			t.integer "supplier_list_id"
			t.string "dn"
			t.string "dn_long"
			t.string "cai_gou_fang_shi"
			t.datetime "wh_at"
			t.decimal "t_p", precision: 20, scale: 6
			t.decimal "tax_t_p", precision: 20, scale: 6
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "cai_gou_fa_piao_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "cai_gou_fa_piao_info_id"
			t.string "pmc_flag", default: ""
			t.integer "pi_pmc_item_id"
			t.string "buy_user"
			t.integer "pi_wh_info_id"
			t.string "pi_wh_info_no"
			t.integer "pi_buy_item_id"
			t.string "moko_part"
			t.string "moko_des"
			t.integer "qty_in", default: 0
			t.text "remark", limit: 4294967295
			t.integer "p_item_id"
			t.integer "erp_id"
			t.string "erp_no", limit: 50
			t.integer "pi_buy_info_id"
			t.integer "procurement_bom_id"
			t.string "state"
			t.decimal "cost", precision: 20, scale: 6
			t.decimal "tax_cost", precision: 20, scale: 6
			t.decimal "tax", precision: 10, scale: 4
			t.decimal "tax_t_p", precision: 20, scale: 6
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "e_boms", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "check"
			t.string "no"
			t.string "name"
			t.string "p_name"
			t.integer "qty"
			t.decimal "t_p", precision: 20
			t.integer "profit"
			t.decimal "t_pp", precision: 20
			t.string "d_day"
			t.string "description"
			t.string "excel_file"
			t.decimal "pcb_p", precision: 10
			t.string "pcb_file"
			t.string "pcb_layer"
			t.integer "pcb_qty"
			t.integer "pcb_size_c"
			t.integer "pcb_size_k"
			t.string "pcb_sc"
			t.string "pcb_material"
			t.string "pcb_cc"
			t.string "pcb_ct"
			t.string "pcb_sf"
			t.string "pcb_t"
			t.integer "t_c"
			t.decimal "c_p", precision: 20
			t.integer "user_id"
			t.text "all_title", limit: 4294967295
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "e_dns", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "item_id"
			t.string "part_code"
			t.datetime "date", null: false
			t.string "dn"
			t.string "dn_long"
			t.decimal "cost", precision: 20, scale: 6
			t.integer "qty"
			t.string "info"
			t.text "remark", limit: 4294967295
			t.string "tag"
			t.string "color"
		end

		create_table "e_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "user_do"
			t.string "user_do_change"
			t.string "check"
			t.integer "e_bom_id"
			t.integer "quantity"
			t.string "description"
			t.text "part_code", limit: 65535
			t.string "fengzhuang"
			t.text "link", limit: 4294967295
			t.decimal "cost", precision: 20, scale: 6
			t.string "info"
			t.integer "product_id"
			t.boolean "warn"
			t.integer "user_id"
			t.boolean "danger"
			t.boolean "manual"
			t.boolean "mark"
			t.string "mpn"
			t.integer "mpn_id"
			t.decimal "price", precision: 20, scale: 6
			t.string "mf"
			t.string "dn"
			t.integer "dn_id"
			t.text "other", limit: 4294967295
			t.text "all_info", limit: 4294967295
			t.text "remark", limit: 4294967295
			t.string "color"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "feedbacks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "topic_id"
			t.string "order_no", default: ""
			t.integer "order_id"
			t.string "product_code", default: ""
			t.integer "feedback_id", default: 0
			t.string "feedback_title", default: ""
			t.text "feedback", limit: 4294967295
			t.string "user_name", default: ""
			t.string "feedback_type", default: ""
			t.string "feedback_receive", default: ""
			t.string "feedback_receive_user"
			t.integer "feedback_level", default: 0
			t.string "send_to"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "finance_payment_voucher_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "type", default: ""
			t.integer "finance_voucher_info_id"
			t.integer "fu_kuan_dan_info_id"
			t.integer "no"
			t.string "des"
			t.string "jie_fang_kemu"
			t.string "dai_fang_kemu"
			t.decimal "jie_fang", precision: 20, scale: 6
			t.decimal "dai_fang", precision: 20, scale: 6
			t.datetime "finance_at"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "finance_voucher_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "state", limit: 10, default: ""
			t.integer "payment_notice_info_id"
			t.string "payment_notice_info_no", limit: 100
			t.integer "pi_info_id"
			t.integer "pi_item_id"
			t.integer "c_id"
			t.string "pi_info_no", limit: 30
			t.datetime "pi_date"
			t.string "c_code", limit: 11
			t.string "c_des"
			t.string "c_country"
			t.string "payment_way", limit: 50
			t.string "currency_type", limit: 10
			t.decimal "exchange_rate", precision: 10, scale: 3
			t.decimal "pi_t_p", precision: 20, scale: 6
			t.decimal "unreceived_p", precision: 20, scale: 6
			t.string "pay_att"
			t.decimal "pay_p", precision: 20, scale: 6
			t.string "pay_type", limit: 10
			t.string "pay_account_name", limit: 100
			t.string "pay_account_number", limit: 50
			t.string "pay_swift_code", limit: 100
			t.string "pay_bank_name"
			t.string "remark", limit: 500
			t.integer "sell_id"
			t.string "sell_full_name_new"
			t.string "sell_full_name_up"
			t.string "sell_team"
			t.datetime "send_at"
			t.string "voucher_item"
			t.string "voucher_way"
			t.string "collection_type", limit: 50
			t.string "xianjin_kemu"
			t.string "voucher_bank_name"
			t.string "voucher_bank_account"
			t.decimal "get_money", precision: 20, scale: 6
			t.decimal "get_money_self", precision: 20, scale: 6
			t.decimal "loss_money", precision: 20, scale: 6
			t.decimal "loss_money_self", precision: 20, scale: 6
			t.string "voucher_remark"
			t.string "voucher_no", limit: 50
			t.datetime "voucher_at"
			t.datetime "finance_at"
			t.string "voucher_currency_type", limit: 10
			t.decimal "voucher_exchange_rate", precision: 10, scale: 3
			t.string "voucher_full_name_new", limit: 20
			t.string "voucher_full_name_up", limit: 20
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "fu_kuan_dan_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "fu_kuan_shen_qing_dan_info_id"
			t.string "user_new"
			t.string "user_checked"
			t.string "user_fu_kuan_shen_qing_dan"
			t.string "state", limit: 10, default: ""
			t.decimal "t_p", precision: 20, scale: 6
			t.decimal "true_t_p", precision: 20, scale: 6
			t.string "supplier_code"
			t.string "supplier_name"
			t.string "supplier_name_long"
			t.integer "supplier_list_id"
			t.string "supplier_clearing", collation: "utf8_general_ci"
			t.string "supplier_address", collation: "utf8_general_ci"
			t.string "supplier_contacts", collation: "utf8_general_ci"
			t.string "supplier_phone", collation: "utf8_general_ci"
			t.string "supplier_bank_user"
			t.string "supplier_bank_account"
			t.string "supplier_bank_name"
			t.decimal "shen_qing_jiner", precision: 20, scale: 6
			t.decimal "shen_pi_jiner", precision: 20, scale: 6
			t.string "remark"
			t.string "kuai_ji_ke_mu"
			t.datetime "finance_at"
			t.string "xianjin_kemu"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "fu_kuan_dan_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "pi_info_id"
			t.integer "pi_item_id"
			t.integer "fu_kuan_dan_info_id"
			t.integer "pi_buy_info_id"
			t.integer "pi_buy_item_id"
			t.string "pi_buy_no"
			t.decimal "t_p", precision: 20, scale: 6
			t.decimal "ding_dan_zhi_fu_bi_li", precision: 5, scale: 2
			t.decimal "shen_qing_p", precision: 20, scale: 6, default: "0.0"
			t.decimal "fu_kuan_p", precision: 20, scale: 6
			t.decimal "zhe_kou_p", precision: 20, scale: 6, default: "0.0"
			t.decimal "shen_pi_p", precision: 20, scale: 6, default: "0.0"
			t.string "moko_part"
			t.string "moko_des"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "fu_kuan_ping_zheng_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "fu_kuan_dan_info_id"
			t.integer "no"
			t.string "des"
			t.string "jie_fang_kemu"
			t.string "dai_fang_kemu"
			t.decimal "jie_fang", precision: 20, scale: 6
			t.decimal "dai_fang", precision: 20, scale: 6
			t.datetime "finance_at"
			t.string "remark"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "fu_kuan_ping_zheng_yuejie_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "cai_gou_fa_piao_info_id"
			t.integer "fu_kuan_dan_info_id"
			t.integer "no"
			t.string "des"
			t.string "jie_fang_kemu"
			t.string "dai_fang_kemu"
			t.decimal "jie_fang", precision: 20, scale: 6
			t.decimal "dai_fang", precision: 20, scale: 6
			t.decimal "yuan_cai_liao", precision: 20, scale: 6
			t.decimal "ying_jiao_shui_fei", precision: 20, scale: 6
			t.datetime "finance_at"
			t.string "remark"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "fu_kuan_shen_qing_dan_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "user_new"
			t.string "user_checked"
			t.string "fu_kuan_dan_state", default: ""
			t.string "state", limit: 10, default: ""
			t.decimal "t_p", precision: 20, scale: 6
			t.string "supplier_code"
			t.string "supplier_name"
			t.string "supplier_name_long"
			t.integer "supplier_list_id"
			t.string "supplier_clearing", collation: "utf8_general_ci"
			t.string "supplier_address", collation: "utf8_general_ci"
			t.string "supplier_contacts", collation: "utf8_general_ci"
			t.string "supplier_phone", collation: "utf8_general_ci"
			t.string "supplier_bank_user"
			t.string "supplier_bank_account"
			t.string "supplier_bank_name"
			t.decimal "shen_qing_jiner", precision: 20, scale: 6
			t.decimal "shen_pi_jiner", precision: 20, scale: 6
			t.string "remark"
			t.string "info_a"
			t.string "info_b"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "fu_kuan_shen_qing_dan_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "pi_wh_id"
			t.integer "pi_info_id"
			t.integer "pi_item_id"
			t.integer "fu_kuan_shen_qing_dan_info_id"
			t.integer "pi_buy_info_id"
			t.integer "pi_buy_item_id"
			t.string "pi_buy_no"
			t.decimal "t_p", precision: 20, scale: 6
			t.decimal "ding_dan_zhi_fu_bi_li", precision: 5, scale: 2
			t.decimal "shen_qing_p", precision: 20, scale: 6, default: "0.0"
			t.decimal "shen_pi_p", precision: 20, scale: 6, default: "0.0"
			t.string "moko_part"
			t.string "moko_des"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "info_parts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "mpn"
			t.text "info", limit: 4294967295
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.index ["mpn"], name: "mpn", using: :btree
		end

		create_table "keywords", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "keywords"
			t.string "ip"
			t.datetime "created_at"
			t.datetime "updated_at"
		end

		create_table "kindeditor_assets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "asset"
			t.integer "file_size"
			t.string "file_type"
			t.integer "owner_id"
			t.string "asset_type"
			t.datetime "created_at"
			t.datetime "updated_at"
		end

		create_table "kinds", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "code_a"
			t.string "code_b"
			t.string "des"
			t.text "attr", limit: 4294967295
		end

		create_table "kuaijikemu_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "code_a", default: ""
			t.string "code_a_name", default: ""
			t.string "code_b", default: ""
			t.string "code_b_name", default: ""
			t.string "code_c", default: ""
			t.string "code_c_name", default: ""
			t.string "zhu_ji_ma", default: ""
			t.string "kemu_type", default: ""
			t.string "yu_er_fang_xiang", default: ""
			t.string "wai_bi_he_suan", default: ""
			t.string "quan_ming", default: ""
			t.string "qi_mo_diao_hui", default: ""
			t.string "wang_lai_ye_wu_he_suan", default: ""
			t.string "shu_liang_jin_er_fu_zhu_he_suan", default: ""
			t.string "ji_liang_dan_wei", default: ""
			t.string "xian_jin_kemu", default: ""
			t.string "yin_hang_kemu", default: ""
			t.string "chu_ri_ji_zhang", default: ""
			t.string "xian_jin_deng_jia_wu", default: ""
			t.string "kemu_ji_xi", default: ""
			t.string "ri_li_lv", default: ""
			t.string "xiang_mu_fu_zhu_he_suan", default: ""
			t.string "zhu_biao_xiang_mu", default: ""
			t.string "fu_biao_xiang_mu", default: ""
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "ling_liao_dan_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "ling_liao_state", default: "new"
			t.string "ling_liao_user"
			t.string "ling_liao_user_name"
			t.string "checked_user"
			t.string "checked_name"
			t.string "pi_lock", default: ""
			t.string "buy_type", default: ""
			t.integer "item_pcba_id"
			t.integer "item_pcb_id"
			t.integer "c_id"
			t.integer "bom_id"
			t.integer "pcb_order_id"
			t.integer "pcb_order_sell_item_id"
			t.string "pcb_order_no"
			t.string "pcb_order_no_son"
			t.string "moko_code"
			t.string "moko_des"
			t.string "des_en", default: ""
			t.string "des_cn", default: ""
			t.integer "qty"
			t.string "p_type", default: ""
			t.string "moko_attribute"
			t.decimal "t_p", precision: 20, scale: 6
			t.decimal "price", precision: 20, scale: 6
			t.string "att"
			t.string "state", default: ""
			t.string "remark", limit: 500
			t.string "p_remark", limit: 500
			t.datetime "checked_at"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "ling_liao_dan_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "ling_liao_dan_info_id"
			t.integer "pi_bom_qty_info_item_id"
			t.integer "pi_info_id"
			t.integer "pi_item_id"
			t.string "pmc_flag", default: ""
			t.string "state", default: ""
			t.string "pmc_type", default: ""
			t.string "buy_type", default: ""
			t.string "erp_no", limit: 50
			t.string "erp_no_son"
			t.string "moko_part"
			t.string "moko_des"
			t.text "part_code", limit: 65535
			t.integer "qty"
			t.integer "f_qty"
			t.integer "pmc_qty", default: 0
			t.integer "qty_in"
			t.text "remark", limit: 4294967295
			t.string "buy_user", default: ""
			t.integer "buy_qty"
			t.integer "p_item_id"
			t.integer "erp_id"
			t.integer "user_do"
			t.string "user_do_change"
			t.string "check", default: ""
			t.integer "pi_buy_info_id"
			t.integer "procurement_bom_id"
			t.integer "quantity"
			t.integer "qty_done", default: 0
			t.integer "qty_wait", default: 0
			t.integer "wh_qty"
			t.string "description", limit: 5000
			t.string "fengzhuang"
			t.text "link", limit: 4294967295
			t.decimal "cost", precision: 20, scale: 6
			t.string "info"
			t.integer "product_id"
			t.boolean "warn"
			t.integer "user_id"
			t.boolean "danger"
			t.boolean "manual"
			t.boolean "mark"
			t.string "mpn"
			t.integer "mpn_id"
			t.decimal "price", precision: 20, scale: 6
			t.string "mf"
			t.integer "dn_id"
			t.string "dn"
			t.string "dn_long"
			t.text "other", limit: 4294967295
			t.text "all_info", limit: 4294967295
			t.string "color"
			t.string "supplier_tag"
			t.string "supplier_out_tag"
			t.string "sell_feed_back_tag"
			t.datetime "pass_at"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "moko_bom_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "copy_id"
			t.string "moko_state", default: ""
			t.string "state", default: ""
			t.string "pi_lock", default: ""
			t.string "bom_id", limit: 11
			t.string "bom_active", limit: 20, default: "active"
			t.string "bom_lock"
			t.string "change_flag", limit: 10, default: ""
			t.integer "bom_version", default: 1
			t.integer "erp_id"
			t.integer "erp_item_id"
			t.string "erp_no"
			t.string "erp_no_son"
			t.integer "erp_qty"
			t.string "order_do"
			t.string "order_country"
			t.integer "star"
			t.text "sell_remark", limit: 4294967295
			t.text "sell_manager_remark", limit: 4294967295
			t.string "check"
			t.string "no"
			t.string "name"
			t.string "p_name_mom"
			t.string "p_name"
			t.integer "qty"
			t.text "remark", limit: 4294967295
			t.decimal "t_p", precision: 20, scale: 6
			t.integer "profit"
			t.decimal "t_pp", precision: 20, scale: 6
			t.string "d_day"
			t.string "description"
			t.string "excel_file"
			t.string "att"
			t.decimal "pcb_p", precision: 20, scale: 6
			t.string "pcb_file"
			t.string "pcb_layer"
			t.integer "pcb_qty"
			t.integer "pcb_size_c"
			t.integer "pcb_size_k"
			t.string "pcb_sc"
			t.string "pcb_material"
			t.string "pcb_cc"
			t.string "pcb_ct"
			t.string "pcb_sf"
			t.string "pcb_t"
			t.integer "t_c"
			t.decimal "c_p", precision: 20, scale: 6
			t.integer "user_id"
			t.text "all_title", limit: 4294967295
			t.integer "row_use"
			t.string "bom_eng_up"
			t.string "bom_eng"
			t.string "bom_team_ck"
			t.datetime "bom_team_ck_at"
			t.string "remark_to_sell"
			t.string "sell_feed_back_tag"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.integer "moko_bom_items_count"
			t.index ["p_name"], name: "p_name", using: :btree
		end

		create_table "moko_bom_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "bom_version"
			t.string "p_type"
			t.string "buy", limit: 10, default: ""
			t.integer "erp_id"
			t.string "erp_no", limit: 50
			t.integer "user_do"
			t.string "user_do_change"
			t.string "check"
			t.integer "moko_bom_info_id"
			t.integer "quantity"
			t.integer "pi_qty", default: 0
			t.integer "pmc_qty", default: 0
			t.integer "customer_qty", default: 0
			t.integer "have_qty", default: 0
			t.integer "buy_qty", default: 0
			t.string "description", limit: 5000
			t.text "part_code", limit: 65535
			t.string "fengzhuang"
			t.text "link", limit: 4294967295
			t.decimal "cost", precision: 20, scale: 6
			t.string "info"
			t.integer "product_id"
			t.string "moko_part"
			t.string "moko_des"
			t.boolean "warn"
			t.integer "user_id"
			t.boolean "danger"
			t.boolean "manual"
			t.boolean "mark"
			t.string "mpn"
			t.integer "mpn_id"
			t.decimal "price", precision: 20, scale: 6
			t.string "mf"
			t.integer "dn_id"
			t.string "dn"
			t.string "dn_long"
			t.text "other", limit: 4294967295
			t.text "all_info", limit: 4294967295
			t.text "remark", limit: 4294967295
			t.string "color", default: ""
			t.string "supplier_tag"
			t.string "supplier_out_tag"
			t.string "sell_feed_back_tag", default: ""
			t.string "ecn_tag", default: ""
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.index ["color"], name: "color", using: :btree
			t.index ["erp_no"], name: "pi_no", using: :btree
			t.index ["user_do"], name: "user_do", using: :btree
		end

		create_table "moko_parts_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "part_name_main"
			t.string "part_name_type_a_no"
			t.string "part_name_type_a_name"
			t.string "part_name_type_a_name_en"
			t.string "part_name_type_a_sname"
			t.string "part_name_type_b_name"
			t.string "part_name_type_b_name_en"
			t.string "part_name_type_b_sname"
			t.string "part_name_type_c_no", limit: 11
			t.string "part_name_type_c_name_cn"
			t.string "part_name_type_c_name"
			t.string "all_des_cn", limit: 800
			t.string "all_des_en", limit: 800
			t.string "part_example", limit: 300
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "mpn_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "mpn"
			t.string "manufacturer"
			t.string "authorized_distributor"
			t.string "description"
			t.string "datasheets", collation: "utf8_general_ci"
			t.string "price"
			t.string "last_update"
			t.datetime "created_at"
			t.datetime "updated_at"
			t.index ["mpn"], name: "mpn", using: :btree
		end

		create_table "oauths", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "app_id"
			t.string "app_secret"
			t.string "company_id"
			t.string "company_token"
			t.integer "expires_in"
			t.string "refresh_token"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "order_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "quantity"
			t.string "description"
			t.text "part_code", limit: 65535
			t.integer "order_id"
			t.integer "product_id"
			t.boolean "warn"
			t.integer "user_id"
			t.boolean "danger"
			t.boolean "manual"
			t.boolean "mark"
			t.string "mpn"
			t.integer "mpn_id"
			t.decimal "price", precision: 10, scale: 2
			t.string "mf"
			t.string "dn"
			t.text "other", limit: 4294967295
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "orders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "order_no"
			t.integer "bom_id"
			t.string "no"
			t.text "shipping_info", limit: 4294967295
			t.string "name"
			t.string "p_name"
			t.integer "qty"
			t.decimal "t_p", precision: 10
			t.string "d_day"
			t.string "description"
			t.string "excel_file"
			t.decimal "pcb_p", precision: 10
			t.decimal "pcb_r_p", precision: 10
			t.decimal "pcb_dc_p", precision: 10
			t.string "pcb_file"
			t.string "pcb_layer"
			t.integer "pcb_qty"
			t.integer "pcb_size_c"
			t.integer "pcb_size_k"
			t.string "pcb_sc"
			t.string "pcb_material"
			t.string "pcb_cc"
			t.string "pcb_ct"
			t.string "pcb_sf"
			t.string "pcb_t"
			t.integer "t_c"
			t.decimal "c_p", precision: 10
			t.integer "user_id"
			t.string "state", default: "review"
			t.string "double_check_state"
			t.string "pcb_r_remark"
			t.string "pcb_dc_remark"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "other_baojia_boms", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "order_do"
			t.string "order_country"
			t.integer "star"
			t.text "sell_remark", limit: 4294967295
			t.text "sell_manager_remark", limit: 4294967295
			t.string "check"
			t.string "no"
			t.string "name"
			t.string "p_name"
			t.integer "qty"
			t.text "remark", limit: 4294967295
			t.decimal "t_p", precision: 20, scale: 6
			t.integer "profit"
			t.decimal "t_pp", precision: 20, scale: 6
			t.string "d_day"
			t.string "description"
			t.string "excel_file"
			t.string "att"
			t.decimal "pcb_p", precision: 20, scale: 6
			t.string "pcb_file"
			t.string "pcb_layer"
			t.integer "pcb_qty"
			t.integer "pcb_size_c"
			t.integer "pcb_size_k"
			t.string "pcb_sc"
			t.string "pcb_material"
			t.string "pcb_cc"
			t.string "pcb_ct"
			t.string "pcb_sf"
			t.string "pcb_t"
			t.integer "t_c"
			t.decimal "c_p", precision: 20, scale: 6
			t.integer "user_id"
			t.text "all_title", limit: 4294967295
			t.integer "row_use"
			t.string "bom_eng_up"
			t.string "bom_eng"
			t.string "bom_team_ck"
			t.string "remark_to_sell"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.index ["p_name"], name: "p_name", using: :btree
		end

		create_table "p_chk_dns", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci ROW_FORMAT=COMPACT" do |t|
			t.string "state", limit: 10, default: ""
			t.string "dn_type", limit: 10, default: "A"
			t.string "owner_email"
			t.string "email"
			t.integer "p_item_id"
			t.integer "pi_pmc_item_id"
			t.string "part_code"
			t.datetime "date", null: false
			t.string "dn"
			t.string "dn_long"
			t.decimal "cost", precision: 20, scale: 6
			t.integer "qty"
			t.string "info"
			t.text "remark", limit: 4294967295
			t.string "tag"
			t.string "up_alldn_tag", limit: 10
			t.string "color", default: ""
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "p_dns", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "state", limit: 10, default: ""
			t.string "dn_type", limit: 10, default: "A"
			t.string "owner_email"
			t.string "email"
			t.integer "p_item_id"
			t.string "part_code"
			t.datetime "date", null: false
			t.string "dn"
			t.string "dn_long"
			t.decimal "cost", precision: 20, scale: 6
			t.integer "qty"
			t.string "info"
			t.text "remark", limit: 4294967295
			t.string "tag"
			t.string "up_alldn_tag", limit: 10
			t.string "color", default: ""
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "p_item_remarks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "p_item_id"
			t.integer "user_id"
			t.string "user_name"
			t.string "user_team"
			t.text "remark", limit: 4294967295
			t.string "info"
			t.string "state"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.index ["p_item_id"], name: "p_item_id", using: :btree
		end

		create_table "p_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "moko_bom_item_id"
			t.string "add_state", default: ""
			t.string "bom_version"
			t.string "p_type"
			t.string "buy", limit: 10, default: ""
			t.integer "erp_id"
			t.string "erp_no", limit: 50
			t.string "user_do", limit: 11
			t.string "user_do_change"
			t.string "check"
			t.integer "procurement_vsrsion_bom_id"
			t.integer "procurement_bom_id"
			t.integer "quantity"
			t.integer "pi_qty", default: 0
			t.integer "pmc_qty", default: 0
			t.integer "customer_qty", default: 0
			t.integer "have_qty", default: 0
			t.integer "buy_qty", default: 0
			t.string "description", limit: 5000
			t.text "part_code", limit: 65535
			t.string "fengzhuang"
			t.text "link", limit: 4294967295
			t.decimal "cost", precision: 20, scale: 6
			t.string "info"
			t.integer "product_id"
			t.string "moko_part"
			t.string "moko_des"
			t.boolean "warn"
			t.integer "user_id"
			t.boolean "danger"
			t.boolean "manual"
			t.boolean "mark"
			t.string "mpn"
			t.integer "mpn_id"
			t.decimal "price", precision: 20, scale: 6
			t.string "mf"
			t.integer "dn_id"
			t.string "dn"
			t.string "dn_long"
			t.text "other", limit: 4294967295
			t.text "all_info", limit: 4294967295
			t.text "remark", limit: 4294967295
			t.string "color", default: ""
			t.string "supplier_tag"
			t.string "supplier_out_tag"
			t.string "sell_feed_back_tag", default: ""
			t.string "ecn_tag", default: ""
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.index ["color"], name: "color", using: :btree
			t.index ["erp_no"], name: "pi_no", using: :btree
			t.index ["user_do"], name: "user_do", using: :btree
		end

		create_table "p_version_dns", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "email"
			t.integer "p_version_item_id"
			t.string "part_code"
			t.datetime "date", null: false
			t.string "dn"
			t.string "dn_long"
			t.decimal "cost", precision: 20, scale: 6
			t.integer "qty"
			t.string "info"
			t.text "remark", limit: 4294967295
			t.string "tag"
			t.string "color"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "p_version_item_remarks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "p_version_item_id"
			t.integer "user_id"
			t.string "user_name"
			t.string "user_team"
			t.string "remark", limit: 600, default: ""
			t.string "info"
			t.string "state"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.index ["p_version_item_id"], name: "p_item_id", using: :btree
		end

		create_table "p_version_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "bom_version"
			t.string "p_type"
			t.string "buy", limit: 10
			t.integer "erp_id"
			t.string "erp_no", limit: 50
			t.integer "user_do"
			t.string "user_do_change"
			t.string "check"
			t.integer "procurement_version_bom_id"
			t.integer "procurement_bom_id"
			t.integer "quantity"
			t.integer "pmc_qty"
			t.string "description", limit: 5000
			t.text "part_code", limit: 65535
			t.string "fengzhuang"
			t.text "link", limit: 4294967295
			t.decimal "cost", precision: 20, scale: 6
			t.string "info"
			t.integer "product_id"
			t.string "moko_part"
			t.string "moko_des"
			t.boolean "warn"
			t.integer "user_id"
			t.boolean "danger"
			t.boolean "manual"
			t.boolean "mark"
			t.string "mpn"
			t.integer "mpn_id"
			t.decimal "price", precision: 20, scale: 6
			t.string "mf"
			t.integer "dn_id"
			t.string "dn"
			t.string "dn_long"
			t.text "other", limit: 4294967295
			t.text "all_info", limit: 4294967295
			t.text "remark", limit: 4294967295
			t.string "color"
			t.string "supplier_tag"
			t.string "supplier_out_tag"
			t.string "sell_feed_back_tag"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.index ["color"], name: "color", using: :btree
			t.index ["erp_no"], name: "pi_no", using: :btree
			t.index ["user_do"], name: "user_do", using: :btree
		end

		create_table "parts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "part_code"
			t.string "part_name"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "payment_notice_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "state", limit: 10, default: ""
			t.string "no", limit: 100
			t.integer "pi_info_id"
			t.integer "pi_item_id"
			t.integer "c_id"
			t.string "pi_info_no", limit: 30
			t.datetime "pi_date"
			t.string "c_code", limit: 11
			t.string "c_des"
			t.string "c_country"
			t.string "payment_way", limit: 50
			t.string "currency_type", limit: 10, default: "美金"
			t.decimal "exchange_rate", precision: 10, scale: 3
			t.decimal "pi_t_p", precision: 20, scale: 6
			t.decimal "unreceived_p", precision: 20, scale: 6
			t.string "pay_att"
			t.decimal "pay_p", precision: 20, scale: 6
			t.string "pay_type", limit: 10
			t.string "pay_account_name", limit: 100
			t.string "pay_account_number", limit: 50
			t.string "pay_swift_code", limit: 100
			t.string "pay_bank_name"
			t.string "remark", limit: 500
			t.integer "sell_id"
			t.string "sell_full_name_new"
			t.string "sell_full_name_up"
			t.string "sell_team"
			t.datetime "send_at"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "pcb_customer_remarks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "pcb_c_id"
			t.integer "user_id"
			t.string "user_name"
			t.string "remark", limit: 5000, default: ""
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "pcb_customers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "c_time", default: 0
			t.string "c_no"
			t.string "customer_country"
			t.string "customer"
			t.string "customer_com"
			t.string "tel"
			t.string "fax"
			t.text "email", limit: 65535
			t.string "shipping_address", limit: 5000
			t.string "sell"
			t.integer "qty"
			t.string "att"
			t.string "order_no", default: ""
			t.decimal "price", precision: 20, scale: 6
			t.decimal "buy_ptice", precision: 20, scale: 6
			t.datetime "target"
			t.datetime "in_storage"
			t.string "follow", limit: 1000
			t.text "remark", limit: 65535
			t.string "follow_remark", limit: 5000, default: ""
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "pcb_item_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "pcb_order_item_id"
			t.string "pcb_supplier"
			t.string "pcb_order_no"
			t.string "sell"
			t.float "pcb_length", limit: 53
			t.float "pcb_width", limit: 53
			t.string "pcb_thickness"
			t.string "pcb_panel"
			t.string "pcb_layer"
			t.string "pcb_gongyi"
			t.integer "qty"
			t.decimal "pcb_area", precision: 30, scale: 10
			t.decimal "pcb_area_price", precision: 20, scale: 6
			t.decimal "price", precision: 20, scale: 6
			t.decimal "eng_price", precision: 20, scale: 6
			t.decimal "test_price", precision: 20, scale: 6
			t.decimal "m_price", precision: 20, scale: 6
			t.decimal "t_p", precision: 20, scale: 6
			t.string "remark"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "pcb_order_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "pi_lock", default: ""
			t.string "buy_type", default: ""
			t.integer "item_pcba_id"
			t.integer "item_pcb_id"
			t.integer "c_id"
			t.integer "bom_id"
			t.integer "pcb_order_id"
			t.integer "pcb_order_sell_item_id"
			t.string "pcb_order_no"
			t.string "pcb_order_no_son"
			t.string "moko_code"
			t.string "moko_des"
			t.string "des_en", default: ""
			t.string "des_cn", default: ""
			t.integer "qty"
			t.string "p_type", default: ""
			t.string "moko_attribute"
			t.decimal "t_p", precision: 20, scale: 6
			t.decimal "price", precision: 20, scale: 6
			t.string "att"
			t.string "state", default: ""
			t.string "factory_state", default: ""
			t.string "remark", limit: 500
			t.string "p_remark", limit: 500
			t.string "bom_team_ck"
			t.datetime "bom_team_ck_at"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "pcb_order_sell_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "c_id"
			t.integer "pcb_order_id"
			t.string "pcb_order_no"
			t.string "des_en", default: ""
			t.string "des_cn", default: ""
			t.integer "qty"
			t.string "att"
			t.string "remark", limit: 500
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "pcb_orders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "del_flag", default: "active"
			t.integer "star", default: 0
			t.integer "pcb_customer_id"
			t.string "c_code"
			t.string "c_des"
			t.string "c_country"
			t.string "c_shipping_address", limit: 1000
			t.string "p_name", default: ""
			t.string "des_en", default: ""
			t.string "des_cn", default: ""
			t.string "order_no"
			t.string "att"
			t.string "sell"
			t.string "order_sell"
			t.string "team"
			t.string "phone"
			t.string "price_eng"
			t.decimal "price", precision: 10, scale: 2
			t.integer "qty"
			t.decimal "other_price", precision: 10, scale: 2
			t.datetime "target"
			t.string "su"
			t.string "state", default: ""
			t.text "remark", limit: 65535
			t.text "manager_remark", limit: 65535
			t.text "follow_remark", limit: 65535
			t.datetime "remark_at"
			t.datetime "manager_remark_at"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "pcb_suppliers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "pcb_s_code"
			t.string "name"
			t.string "name_long"
			t.string "name_des"
			t.string "address"
			t.string "person_contact"
			t.string "number"
			t.string "email"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "pi_bom_qty_info_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "lock_state", default: ""
			t.string "pmc_back_state", default: ""
			t.string "buy", default: ""
			t.integer "pi_bom_qty_info_id"
			t.integer "pi_info_id"
			t.integer "pi_item_id"
			t.integer "order_item_id"
			t.integer "bom_id"
			t.integer "p_item_id"
			t.integer "moko_bom_item_id"
			t.integer "qty"
			t.integer "t_qty"
			t.integer "bom_ctl_qty"
			t.integer "customer_qty"
			t.string "bom_version"
			t.string "p_type"
			t.integer "erp_id"
			t.string "erp_no", limit: 50
			t.integer "user_do"
			t.string "user_do_change"
			t.string "check"
			t.integer "moko_bom_info_id"
			t.integer "quantity"
			t.integer "pi_qty", default: 0
			t.integer "pmc_qty", default: 0
			t.integer "have_qty", default: 0
			t.integer "buy_qty", default: 0
			t.string "description", limit: 5000
			t.text "part_code", limit: 65535
			t.string "fengzhuang"
			t.text "link", limit: 4294967295
			t.decimal "cost", precision: 20, scale: 6
			t.string "info"
			t.integer "product_id"
			t.string "moko_part"
			t.string "moko_des"
			t.boolean "warn"
			t.integer "user_id"
			t.boolean "danger"
			t.boolean "manual"
			t.boolean "mark"
			t.string "mpn"
			t.integer "mpn_id"
			t.decimal "price", precision: 20, scale: 6
			t.string "mf"
			t.integer "dn_id"
			t.string "dn"
			t.string "dn_long"
			t.text "other", limit: 4294967295
			t.text "all_info", limit: 4294967295
			t.text "remark", limit: 4294967295
			t.string "color", default: ""
			t.string "supplier_tag"
			t.string "supplier_out_tag"
			t.string "sell_feed_back_tag", default: ""
			t.string "ecn_tag", default: ""
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "pi_bom_qty_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "state", limit: 10
			t.string "p_name"
			t.integer "pi_info_id"
			t.integer "pi_item_id"
			t.integer "bom_id"
			t.integer "moko_bom_info_id"
			t.integer "qty"
			t.integer "t_qty"
			t.string "bom_team_ck", limit: 60
			t.datetime "bom_team_ck_at"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "pi_buy_baojia_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "state", limit: 50
			t.string "zhi_dan_ren"
			t.datetime "ti_jiao_at"
			t.string "shen_he_ren"
			t.datetime "shen_he_at"
			t.string "remark"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "pi_buy_baojia_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "pi_buy_baojia_info_id"
			t.integer "pi_pmc_item_id"
			t.integer "dn_chk_id"
			t.string "dn_chk"
			t.string "dn_chk_long"
			t.string "color"
			t.string "remark"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "pi_buy_history_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "p_item_id"
			t.integer "erp_id"
			t.string "erp_no", limit: 50
			t.integer "user_do"
			t.string "user_do_change"
			t.string "check"
			t.integer "pi_buy_info_id"
			t.integer "procurement_bom_id"
			t.integer "quantity"
			t.integer "qty"
			t.integer "wh_qty_in"
			t.string "description", limit: 5000
			t.text "part_code", limit: 65535
			t.string "fengzhuang"
			t.text "link", limit: 4294967295
			t.decimal "cost", precision: 20, scale: 6
			t.string "info"
			t.integer "product_id"
			t.string "moko_part"
			t.string "moko_des"
			t.boolean "warn"
			t.integer "user_id"
			t.boolean "danger"
			t.boolean "manual"
			t.boolean "mark"
			t.string "mpn"
			t.integer "mpn_id"
			t.decimal "price", precision: 20, scale: 6
			t.string "mf"
			t.integer "dn_id"
			t.string "dn"
			t.string "dn_long"
			t.text "other", limit: 4294967295
			t.text "all_info", limit: 4294967295
			t.text "remark", limit: 4294967295
			t.string "color"
			t.string "supplier_tag"
			t.string "supplier_out_tag"
			t.string "sell_feed_back_tag"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.index ["color"], name: "color", using: :btree
			t.index ["erp_no"], name: "pi_no", using: :btree
			t.index ["user_do"], name: "user_do", using: :btree
		end

		create_table "pi_buy_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "pi_buy_no"
			t.string "user"
			t.string "state"
			t.integer "supplier_list_id"
			t.string "supplier_clearing", collation: "utf8_general_ci"
			t.string "supplier_address", collation: "utf8_general_ci"
			t.string "supplier_contacts", collation: "utf8_general_ci"
			t.string "supplier_phone", collation: "utf8_general_ci"
			t.string "dn"
			t.string "dn_long"
			t.decimal "t_p", precision: 20, scale: 6
			t.decimal "yi_fu_kuan_p", precision: 20, scale: 6
			t.datetime "delivery_date"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.index ["pi_buy_no"], name: "pi_buy_no", using: :btree
		end

		create_table "pi_buy_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "pi_bom_qty_info_item_id"
			t.decimal "yi_fu_kuan_p", precision: 20, scale: 6, default: "0.0"
			t.integer "pi_item_id"
			t.integer "pi_info_id"
			t.integer "supplier_list_id"
			t.string "pmc_flag", default: ""
			t.string "buy_user"
			t.string "state", default: ""
			t.integer "pi_pmc_item_id"
			t.integer "p_item_id"
			t.integer "erp_id"
			t.string "erp_no", limit: 50
			t.string "erp_no_son", limit: 50
			t.integer "user_do"
			t.string "user_do_change"
			t.string "check"
			t.integer "pi_buy_info_id"
			t.integer "procurement_bom_id"
			t.integer "quantity"
			t.integer "qty", default: 0
			t.integer "pmc_qty", default: 0
			t.integer "buy_qty", default: 0
			t.integer "qty_done", default: 0
			t.integer "qty_wait", default: 0
			t.integer "wh_qty"
			t.string "description", limit: 5000
			t.text "part_code", limit: 65535
			t.string "fengzhuang"
			t.text "link", limit: 4294967295
			t.decimal "cost", precision: 20, scale: 6
			t.decimal "tax_cost", precision: 20, scale: 6
			t.decimal "tax", precision: 10, scale: 4
			t.decimal "tax_t_p", precision: 20, scale: 6
			t.datetime "delivery_date"
			t.string "info"
			t.integer "product_id"
			t.string "moko_part"
			t.string "moko_des"
			t.boolean "warn"
			t.integer "user_id"
			t.boolean "danger"
			t.boolean "manual"
			t.boolean "mark"
			t.string "mpn"
			t.integer "mpn_id"
			t.decimal "price", precision: 20, scale: 6
			t.string "mf"
			t.integer "dn_id"
			t.string "dn"
			t.string "dn_long"
			t.text "other", limit: 4294967295
			t.text "all_info", limit: 4294967295
			t.text "remark", limit: 4294967295
			t.string "color"
			t.string "supplier_tag"
			t.string "supplier_out_tag"
			t.string "sell_feed_back_tag"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.index ["color"], name: "color", using: :btree
			t.index ["erp_no"], name: "pi_no", using: :btree
			t.index ["pi_buy_info_id"], name: "pi_buy_info_id", using: :btree
			t.index ["user_do"], name: "user_do", using: :btree
		end

		create_table "pi_fahuotongzhi_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "state", limit: 50
			t.integer "pi_info_id"
			t.string "pi_info_no", limit: 50
			t.string "pi_kehu"
			t.string "pi_sell"
			t.string "xiaoshou_fangshi"
			t.string "bianhao"
			t.string "wuliu_danhao"
			t.string "gouhuo_danwei"
			t.string "bizhong"
			t.string "huilv"
			t.string "jiesuan_fangshi"
			t.string "yunshu_fangshi"
			t.string "maoyi_fangshi"
			t.string "zhifu_fangshi"
			t.string "xuandan_hao"
			t.string "shenhe"
			t.datetime "shenhe_date"
			t.string "xinyong_beizhu"
			t.string "yewu_yuan"
			t.string "bumen"
			t.string "zhidan"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.datetime "tijiao_at"
		end

		create_table "pi_fengmian_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "pi_info_id"
			t.string "kehufenlei", limit: 5
			t.string "kehuleixing", limit: 5
			t.string "pi_no", limit: 20
			t.integer "qty"
			t.datetime "pi_date"
			t.string "pi_type", limit: 5
			t.string "pi_back_no", limit: 50
			t.string "moko_des"
			t.string "moko_part"
			t.string "pcb_gongyi"
			t.string "kegongwuliao", limit: 5
			t.datetime "get_date"
			t.string "yangpin", limit: 5
			t.integer "yangpin_qty"
			t.string "zuzhuangfangshi", limit: 5
			t.string "zuichang_weihao"
			t.string "zuichang_xinghao"
			t.datetime "zuichang_date"
			t.string "shifou_a", limit: 5, comment: "是否程序项目"
			t.string "shifou_b", limit: 5, comment: "是否有样板"
			t.string "shifou_c", limit: 5, comment: "PCB文件是否有更新"
			t.string "shifou_d", limit: 5, comment: "BOM文件是否有更新"
			t.string "shifou_e", limit: 5, comment: "客户能否提供PNP"
			t.string "shifou_f", limit: 5, comment: "客户能否提供摆位图"
			t.string "shifou_g", limit: 5, comment: "客户能否提供PCB文件"
			t.string "shifou_h", limit: 5, comment: "客户能否提供原理图"
			t.string "shifou_i", limit: 5, comment: "IC是否需要提前烧录"
			t.string "shifou_j", limit: 5, comment: "IC是否需要在办烧录"
			t.string "ic_weihao_xinghao"
			t.string "shifou_l", limit: 5, comment: "是否要求功能测试"
			t.string "shifou_m", limit: 5, comment: "客户能否提供测试程序"
			t.string "shifou_n", limit: 5, comment: "客户能否提供测试方法"
			t.string "shifou_o", limit: 5, comment: "是否加强目测"
			t.string "shifou_p", limit: 5, comment: "是否刷三防漆"
			t.string "shifou_q", limit: 5, comment: "是否贴标签"
			t.string "shifou_r", limit: 5, comment: "是否气泡袋包装"
			t.string "shifou_s", limit: 5, comment: "是否防静电袋包装"
			t.string "pi_teshuxuqiu"
			t.string "kesu_issue"
			t.string "eng_bom_baojia"
			t.string "eng_bom_youhua"
			t.string "eng_pnp_youhua"
			t.string "eng_pcb_jianyan"
			t.string "eng_shoujianhedui"
			t.string "eng_test_zhidao"
			t.string "eng_qc"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.index ["pi_info_id"], name: "pi_info_id", using: :btree
		end

		create_table "pi_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "bank_info_id"
			t.string "pi_lock"
			t.string "state", default: ""
			t.string "bom_state"
			t.string "buy_state"
			t.integer "finance_state"
			t.string "pi_bank_info", limit: 11
			t.string "pi_bank_account_name"
			t.string "pi_bank_account_number"
			t.string "pi_remark", limit: 500
			t.integer "edit_time"
			t.integer "pcb_customer_id"
			t.string "c_code"
			t.string "c_des"
			t.string "c_country"
			t.string "c_shipping_address", limit: 1000
			t.string "p_name", default: ""
			t.string "des_en", default: ""
			t.string "des_cn", default: ""
			t.string "pi_no"
			t.string "att"
			t.string "sell"
			t.string "pi_sell"
			t.string "team"
			t.string "phone"
			t.string "price_eng"
			t.decimal "price", precision: 10, scale: 2
			t.integer "qty"
			t.decimal "other_price", precision: 20, scale: 6
			t.datetime "target"
			t.string "su"
			t.text "remark", limit: 65535
			t.text "follow_remark", limit: 65535
			t.decimal "pi_shipping_cost", precision: 20, scale: 6
			t.decimal "pi_bank_fee", precision: 20, scale: 6
			t.decimal "t_p", precision: 20, scale: 6
			t.decimal "t_p_rmb", precision: 20, scale: 6
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.datetime "jiao_huo_at"
			t.integer "user_id"
			t.integer "bei_pin_qty"
			t.integer "money_type", default: 0
			t.decimal "rate", precision: 20, scale: 6
			t.text "logger_info", limit: 65535
			t.index ["pi_no"], name: "pi_no", using: :btree
		end

		create_table "pi_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "moko_bom_info_id"
			t.integer "pi_bom_qty_info_id"
			t.string "to_pmc_state", default: ""
			t.datetime "sell_at"
			t.datetime "caiwu_at"
			t.datetime "bom_at"
			t.datetime "caigou_at"
			t.datetime "pmc_at"
			t.string "state", default: ""
			t.string "bom_state", default: ""
			t.string "buy_state", default: ""
			t.string "finance_state", default: ""
			t.integer "order_item_id"
			t.integer "bom_id"
			t.integer "c_id"
			t.integer "pi_info_id"
			t.string "pi_no"
			t.string "moko_code"
			t.string "moko_des"
			t.string "des_en"
			t.string "des_cn"
			t.string "p_type"
			t.string "moko_attribute"
			t.decimal "price", precision: 20, scale: 6
			t.string "att"
			t.string "remark", limit: 500
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.string "c_p_no"
			t.string "pcb_size"
			t.integer "qty"
			t.string "layer"
			t.string "des", limit: 500
			t.decimal "unit_price", precision: 20, scale: 6, default: "0.0"
			t.decimal "pcb_price", precision: 20, scale: 6, default: "0.0"
			t.decimal "com_cost", precision: 20, scale: 6, default: "0.0"
			t.decimal "pcba", precision: 20, scale: 6, default: "0.0"
			t.decimal "t_p", precision: 20, scale: 6
			t.decimal "bank_fee", precision: 20, scale: 6, default: "0.0"
			t.decimal "shipping_cost", precision: 20, scale: 6, default: "0.0"
			t.decimal "in_total", precision: 20, scale: 6
			t.decimal "in_total_rmb", precision: 20, scale: 6
		end

		create_table "pi_other_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "c_id"
			t.integer "pi_info_id"
			t.string "pi_no"
			t.string "p_type"
			t.decimal "t_p", precision: 20, scale: 6
			t.string "remark", limit: 500
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "pi_pmc_add_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "state", default: ""
			t.string "user"
			t.string "no", limit: 30
			t.string "remark", limit: 500
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "pi_pmc_add_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "state", default: ""
			t.integer "pi_pmc_add_info_id"
			t.string "pi_pmc_add_info_no", limit: 30
			t.string "moko_part"
			t.string "moko_des"
			t.integer "pmc_qty", default: 0
			t.string "buy_user"
			t.string "remark", limit: 500
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "pi_pmc_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "baojia_state"
			t.string "up_flag", limit: 10
			t.integer "pi_bom_qty_info_item_id"
			t.integer "pi_info_id"
			t.integer "pi_item_id"
			t.string "pmc_flag", default: ""
			t.string "state", default: ""
			t.string "pmc_type", default: ""
			t.string "buy_type", default: ""
			t.string "erp_no", limit: 50
			t.string "erp_no_son"
			t.string "moko_part"
			t.string "moko_des"
			t.text "part_code", limit: 65535
			t.integer "qty"
			t.integer "pmc_qty", default: 0
			t.integer "qty_in"
			t.text "remark", limit: 4294967295
			t.string "buy_user", default: ""
			t.integer "buy_qty", default: 0
			t.integer "buyer_qty", default: 0
			t.integer "p_item_id"
			t.integer "erp_id"
			t.integer "user_do"
			t.string "user_do_change"
			t.string "check", default: ""
			t.integer "pi_buy_info_id"
			t.integer "procurement_bom_id"
			t.integer "quantity"
			t.integer "qty_done", default: 0
			t.integer "qty_wait", default: 0
			t.integer "wh_qty"
			t.string "description", limit: 5000
			t.string "fengzhuang"
			t.text "link", limit: 4294967295
			t.decimal "cost", precision: 20, scale: 6
			t.string "info"
			t.integer "product_id"
			t.boolean "warn"
			t.integer "user_id"
			t.boolean "danger"
			t.boolean "manual"
			t.boolean "mark"
			t.string "mpn"
			t.integer "mpn_id"
			t.decimal "price", precision: 20, scale: 6
			t.string "mf"
			t.integer "dn_id"
			t.string "dn"
			t.string "dn_long"
			t.integer "dn_chk_id"
			t.string "dn_chk"
			t.string "dn_chk_long"
			t.text "other", limit: 4294967295
			t.text "all_info", limit: 4294967295
			t.string "color"
			t.string "supplier_tag"
			t.string "supplier_out_tag"
			t.string "sell_feed_back_tag"
			t.datetime "pass_at"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.index ["color"], name: "color", using: :btree
			t.index ["erp_no"], name: "pi_no", using: :btree
			t.index ["user_do"], name: "user_do", using: :btree
		end

		create_table "pi_sell_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "pi_info_id"
			t.integer "pcb_order_item_id"
			t.string "c_p_no"
			t.string "pcb_size"
			t.integer "qty"
			t.string "layer"
			t.string "des", limit: 500
			t.decimal "unit_price", precision: 20, scale: 6
			t.decimal "pcb_price", precision: 20, scale: 6
			t.decimal "com_cost", precision: 20, scale: 6
			t.decimal "pcba", precision: 20, scale: 6
			t.decimal "t_p", precision: 20, scale: 6
			t.decimal "bank_fee", precision: 20, scale: 6
			t.decimal "shipping_cost", precision: 20, scale: 6
			t.decimal "in_total", precision: 20, scale: 6
			t.decimal "in_total_rmb", precision: 20, scale: 6
		end

		create_table "pi_wh_change_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "site", default: ""
			t.string "pi_wh_change_no"
			t.string "wh_user"
			t.string "state"
			t.string "dn"
			t.string "dn_long"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "pi_wh_change_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "pi_wh_change_info_id"
			t.string "pi_wh_change_info_no"
			t.string "moko_part"
			t.string "moko_des"
			t.integer "qty_in", default: 0
			t.text "remark", limit: 4294967295
			t.string "state"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "pi_wh_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "site", default: ""
			t.string "pi_wh_no"
			t.string "wh_user"
			t.string "state"
			t.string "dn"
			t.string "dn_long"
			t.string "song_huo_no"
			t.string "remark", limit: 500
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "pi_wh_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "wh_type", limit: 20, default: ""
			t.string "pmc_flag", default: ""
			t.integer "pi_pmc_item_id"
			t.string "buy_user"
			t.integer "pi_wh_info_id"
			t.string "pi_wh_info_no"
			t.integer "pi_buy_item_id"
			t.string "moko_part"
			t.string "moko_des"
			t.integer "qty_in", default: 0
			t.text "remark", limit: 4294967295
			t.integer "p_item_id"
			t.integer "erp_id"
			t.string "erp_no", limit: 50
			t.integer "pi_buy_info_id"
			t.integer "procurement_bom_id"
			t.string "state"
			t.integer "supplier_list_id"
			t.integer "dn_id"
			t.string "dn"
			t.string "dn_long"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "procurement_boms", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "dai_ma", default: ""
			t.string "jia_ji", default: ""
			t.string "state", default: ""
			t.string "pi_lock", default: ""
			t.integer "moko_bom_info_id"
			t.string "bom_id", limit: 11
			t.string "bom_active", limit: 20, default: "active"
			t.string "bom_lock"
			t.string "change_flag", limit: 10, default: ""
			t.integer "bom_version", default: 1
			t.integer "erp_id"
			t.integer "erp_item_id"
			t.string "erp_no"
			t.string "erp_no_son"
			t.integer "erp_qty"
			t.string "order_do"
			t.string "order_country"
			t.integer "star"
			t.text "sell_remark", limit: 4294967295
			t.text "sell_manager_remark", limit: 4294967295
			t.string "check"
			t.string "no"
			t.string "name"
			t.string "p_name_mom"
			t.string "p_name"
			t.integer "qty"
			t.text "remark", limit: 4294967295
			t.decimal "t_p", precision: 20, scale: 6
			t.integer "profit"
			t.decimal "t_pp", precision: 20, scale: 6
			t.string "d_day"
			t.string "description"
			t.string "excel_file"
			t.string "att"
			t.decimal "pcb_p", precision: 20, scale: 6
			t.string "pcb_file"
			t.string "pcb_layer"
			t.integer "pcb_qty"
			t.integer "pcb_size_c"
			t.integer "pcb_size_k"
			t.string "pcb_sc"
			t.string "pcb_material"
			t.string "pcb_cc"
			t.string "pcb_ct"
			t.string "pcb_sf"
			t.string "pcb_t"
			t.integer "t_c"
			t.decimal "c_p", precision: 20, scale: 6
			t.integer "user_id"
			t.text "all_title", limit: 4294967295
			t.integer "row_use"
			t.string "bom_eng_up"
			t.string "bom_eng"
			t.string "bom_team_ck"
			t.datetime "bom_team_ck_at"
			t.string "remark_to_sell"
			t.datetime "remark_to_sell_at"
			t.string "sell_feed_back_tag"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.integer "p_items_count"
			t.index ["p_name"], name: "p_name", using: :btree
		end

		create_table "procurement_version_boms", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "bom_lock"
			t.integer "procurement_bom_id"
			t.string "bom_version"
			t.integer "erp_id"
			t.integer "erp_item_id"
			t.string "erp_no"
			t.string "erp_no_son"
			t.integer "erp_qty"
			t.string "order_do"
			t.string "order_country"
			t.integer "star"
			t.text "sell_remark", limit: 4294967295
			t.text "sell_manager_remark", limit: 4294967295
			t.string "check"
			t.string "no"
			t.string "name"
			t.string "p_name_mom"
			t.string "p_name"
			t.integer "qty"
			t.text "remark", limit: 4294967295
			t.decimal "t_p", precision: 20, scale: 6
			t.integer "profit"
			t.decimal "t_pp", precision: 20, scale: 6
			t.string "d_day"
			t.string "description"
			t.string "excel_file"
			t.string "att"
			t.decimal "pcb_p", precision: 20, scale: 6
			t.string "pcb_file"
			t.string "pcb_layer"
			t.integer "pcb_qty"
			t.integer "pcb_size_c"
			t.integer "pcb_size_k"
			t.string "pcb_sc"
			t.string "pcb_material"
			t.string "pcb_cc"
			t.string "pcb_ct"
			t.string "pcb_sf"
			t.string "pcb_t"
			t.integer "t_c"
			t.decimal "c_p", precision: 20, scale: 6
			t.integer "user_id"
			t.text "all_title", limit: 4294967295
			t.integer "row_use"
			t.string "bom_eng_up"
			t.string "bom_eng"
			t.string "bom_team_ck"
			t.string "remark_to_sell"
			t.string "sell_feed_back_tag"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.index ["p_name"], name: "p_name", using: :btree
		end

		create_table "products", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "part_no"
			t.string "all_des_cn", limit: 800
			t.string "all_des_en", limit: 800
			t.string "name"
			t.text "mpn", limit: 4294967295
			t.string "description"
			t.float "price", limit: 24, default: 0.0
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.string "part_name"
			t.string "part_name_en"
			t.integer "product_able_id"
			t.string "product_able_type"
			t.integer "prefer", default: 0
			t.boolean "delta", default: true, null: false
			t.string "ptype", default: "default"
			t.string "package1", default: "default"
			t.string "package2", default: "default"
			t.string "value1"
			t.string "value2"
			t.string "value3"
			t.string "value4"
			t.string "value5"
			t.string "value6"
			t.string "value7"
			t.string "value8"
			t.string "value9"
			t.string "value10"
			t.index ["description"], name: "des", using: :btree
			t.index ["name"], name: "name", using: :btree
			t.index ["package2"], name: "package2", using: :btree
			t.index ["product_able_id", "product_able_type"], name: "index_products_on_product_able_id_and_product_able_type", using: :btree
		end

		create_table "products_copy20160728", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "name"
			t.text "mpn", limit: 4294967295
			t.string "description"
			t.float "price", limit: 24, default: 0.0
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.string "part_name"
			t.string "part_name_en"
			t.integer "product_able_id"
			t.string "product_able_type"
			t.integer "prefer", default: 0
			t.boolean "delta", default: true, null: false
			t.string "ptype", default: "default"
			t.string "package1", default: "default"
			t.string "package2", default: "default"
			t.string "value1"
			t.string "value2"
			t.string "value3"
			t.string "value4"
			t.string "value5"
			t.string "value6"
			t.string "value7"
			t.string "value8"
			t.index ["description"], name: "des", using: :btree
			t.index ["name"], name: "name", using: :btree
			t.index ["package2"], name: "package2", using: :btree
			t.index ["product_able_id", "product_able_type"], name: "index_products_on_product_able_id_and_product_able_type", using: :btree
		end

		create_table "products_price", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "name"
			t.float "price", limit: 24
			t.index ["name"], name: "name", using: :btree
		end

		create_table "roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "name"
			t.integer "resource_id"
			t.string "resource_type"
			t.datetime "created_at"
			t.datetime "updated_at"
			t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
			t.index ["name"], name: "index_roles_on_name", using: :btree
		end

		create_table "setup_finance_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.decimal "dollar_rate", precision: 10, scale: 5
			t.integer "user_id"
			t.datetime "created_at"
			t.datetime "updated_at"
		end

		create_table "shipping_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "user_id"
			t.string "first_name"
			t.string "last_name"
			t.string "address_line"
			t.string "postal_code"
			t.string "email"
			t.string "phone"
			t.string "city"
			t.string "country"
			t.string "country_name"
			t.string "company"
			t.index ["user_id"], name: "user_id", using: :btree
		end

		create_table "supplier_bank_lists", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "supplier_code"
			t.string "supplier_name"
			t.string "supplier_tax"
			t.string "supplier_name_long"
			t.string "supplier_bank_user"
			t.string "supplier_bank_account"
			t.string "supplier_bank_name"
			t.string "remark"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "supplier_d_lists", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "dn_name"
			t.string "dn_all_name"
			t.string "money"
			t.string "remark", limit: 2000
			t.string "state", default: ""
			t.string "back", default: ""
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "supplier_lists", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "supplier_name", collation: "utf8_general_ci"
			t.string "supplier_code", collation: "utf8_general_ci"
			t.string "supplier_part_type_code", collation: "utf8_general_ci"
			t.string "supplier_part_type", collation: "utf8_general_ci"
			t.string "supplier_tax", collation: "utf8_general_ci"
			t.string "supplier_clearing", collation: "utf8_general_ci"
			t.string "supplier_remark", collation: "utf8_general_ci"
			t.string "supplier_name_long", collation: "utf8_general_ci"
			t.string "supplier_label", collation: "utf8_general_ci"
			t.string "supplier_type", collation: "utf8_general_ci"
			t.string "supplier_address", collation: "utf8_general_ci"
			t.string "supplier_invoice_fullname", collation: "utf8_general_ci"
			t.string "supplier_contacts", collation: "utf8_general_ci"
			t.string "supplier_phone", collation: "utf8_general_ci"
			t.string "supplier_qq", collation: "utf8_general_ci"
			t.string "supplier_bank_user"
			t.string "supplier_bank_name"
			t.string "supplier_bank_account"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "timesheets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "order_no", default: ""
			t.integer "order_id"
			t.integer "gangwang"
			t.integer "guolu"
			t.integer "ceshi"
			t.float "smt_time", limit: 24
			t.float "dip_time", limit: 24
			t.float "ceshi_time", limit: 24
			t.float "total_time", limit: 24
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "topics", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "order_no", default: ""
			t.integer "order_id"
			t.string "product_code", default: ""
			t.integer "feedback_id", default: 0
			t.string "feedback_title", default: ""
			t.text "feedback", limit: 4294967295
			t.string "user_name", default: ""
			t.string "feedback_type", default: ""
			t.string "feedback_receive", default: ""
			t.string "feedback_receive_user", default: ""
			t.integer "feedback_level", default: 0
			t.text "mark", limit: 4294967295
			t.string "topic_state", default: "open"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "translate", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "translate_cn", collation: "utf8_general_ci"
			t.string "translate_en", collation: "utf8_general_ci"
		end

		create_table "units", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "unit"
			t.string "targetunit"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "email", default: "", null: false
			t.string "en_name"
			t.string "tel"
			t.string "fax"
			t.string "add", limit: 600
			t.string "phone"
			t.string "team"
			t.string "full_name", default: ""
			t.string "s_name"
			t.string "s_name_self"
			t.string "open_id"
			t.string "first_name"
			t.string "last_name"
			t.string "country"
			t.string "country_name"
			t.string "skype"
			t.string "encrypted_password", default: "", null: false
			t.string "reset_password_token"
			t.datetime "reset_password_sent_at"
			t.datetime "remember_created_at"
			t.integer "sign_in_count", default: 0, null: false
			t.datetime "current_sign_in_at"
			t.datetime "last_sign_in_at"
			t.string "current_sign_in_ip"
			t.string "last_sign_in_ip"
			t.string "menu_a", limit: 4
			t.string "menu_b", limit: 4
			t.string "menu_c", limit: 4
			t.string "menu_d", limit: 4
			t.string "menu_e", limit: 4
			t.string "menu_f", limit: 4
			t.string "block_a", limit: 4
			t.string "block_b", limit: 4
			t.string "block_c", limit: 4
			t.string "block_d", limit: 4
			t.string "block_e", limit: 4
			t.string "block_f", limit: 4
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
			t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
		end

		create_table "users_roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "user_id"
			t.integer "role_id"
			t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree
		end

		create_table "warehouse_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "moko_type", limit: 50, default: ""
			t.string "erp_no_son", default: ""
			t.string "moko_part"
			t.string "moko_des"
			t.integer "qty", default: 0
			t.integer "future_qty", default: 0
			t.integer "temp_future_qty", default: 0
			t.integer "temp_buy_qty", default: 0
			t.integer "true_buy_qty", default: 0
			t.integer "temp_moko_qty", default: 0
			t.integer "temp_customer_qty", default: 0
			t.integer "loss_qty", default: 0
			t.integer "wh_qty", default: 0
			t.integer "wh_c_qty", default: 0
			t.integer "wh_f_qty", default: 0
			t.text "remark", limit: 4294967295
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.index ["moko_part"], name: "moko_part", using: :btree
		end

		create_table "wh_chk_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "pi_pmc_item_id"
			t.string "erp_no_son"
			t.integer "p_item_id"
			t.string "moko_part"
			t.string "moko_des"
			t.integer "chk_qty"
			t.integer "apply_for_qty"
			t.integer "loss_qty"
			t.string "state", default: ""
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "wh_get_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "site", default: ""
			t.string "wh_get_no"
			t.string "wh_get_user"
			t.string "wh_send_user"
			t.string "pi_no", limit: 20
			t.string "state"
			t.string "remark", limit: 500
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "wh_get_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "pmc_flag", default: ""
			t.integer "pi_pmc_item_id"
			t.string "buy_user"
			t.integer "pi_buy_item_id"
			t.integer "wh_get_info_id"
			t.string "wh_get_info_no"
			t.string "moko_part"
			t.string "moko_des"
			t.integer "qty"
			t.integer "qty_out", default: 0
			t.text "remark", limit: 4294967295
			t.integer "p_item_id"
			t.integer "erp_id"
			t.string "erp_no_son", limit: 50
			t.integer "pi_buy_info_id"
			t.integer "procurement_bom_id"
			t.string "state"
			t.integer "supplier_list_id"
			t.integer "dn_id"
			t.string "dn"
			t.string "dn_long"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "wh_in_history_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "p_item_id"
			t.integer "erp_id"
			t.string "erp_no", limit: 50
			t.string "erp_no_son", limit: 50
			t.integer "user_do"
			t.string "user_do_change"
			t.string "check"
			t.integer "pi_buy_info_id"
			t.integer "procurement_bom_id"
			t.integer "quantity"
			t.integer "qty"
			t.integer "wh_qty_in"
			t.string "description", limit: 5000
			t.text "part_code", limit: 65535
			t.string "fengzhuang"
			t.text "link", limit: 4294967295
			t.decimal "cost", precision: 20, scale: 6
			t.string "info"
			t.integer "product_id"
			t.string "moko_part"
			t.string "moko_des"
			t.boolean "warn"
			t.integer "user_id"
			t.boolean "danger"
			t.boolean "manual"
			t.boolean "mark"
			t.string "mpn"
			t.integer "mpn_id"
			t.decimal "price", precision: 20, scale: 6
			t.string "mf"
			t.integer "dn_id"
			t.string "dn"
			t.string "dn_long"
			t.text "other", limit: 4294967295
			t.text "all_info", limit: 4294967295
			t.text "remark", limit: 4294967295
			t.string "color"
			t.string "supplier_tag"
			t.string "supplier_out_tag"
			t.string "sell_feed_back_tag"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.index ["color"], name: "color", using: :btree
			t.index ["erp_no"], name: "pi_no", using: :btree
			t.index ["user_do"], name: "user_do", using: :btree
		end

		create_table "wh_out_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "site", default: ""
			t.string "wh_out_no"
			t.string "wh_out_user"
			t.string "wh_send_user"
			t.string "pi_no", limit: 20
			t.string "state"
			t.string "remark", limit: 500
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "wh_out_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "out_type", limit: 20, default: ""
			t.integer "wh_info_id"
			t.integer "wh_in_history_item_id"
			t.string "pmc_flag", default: ""
			t.integer "pi_pmc_item_id"
			t.string "buy_user"
			t.integer "pi_buy_item_id"
			t.integer "wh_out_info_id"
			t.string "wh_out_info_no"
			t.string "moko_part"
			t.string "moko_des"
			t.integer "qty"
			t.integer "qty_out", default: 0
			t.text "remark", limit: 4294967295
			t.integer "p_item_id"
			t.integer "erp_id"
			t.string "erp_no_son", limit: 50
			t.integer "pi_buy_info_id"
			t.integer "procurement_bom_id"
			t.string "state"
			t.integer "supplier_list_id"
			t.integer "dn_id"
			t.string "dn"
			t.string "dn_long"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "work_flows", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.date "order_date"
			t.string "order_no", default: "", null: false
			t.integer "order_quantity"
			t.date "salesman_end_date"
			t.string "product_code", default: ""
			t.integer "warehouse_quantity"
			t.string "smd", default: ""
			t.string "dip", default: ""
			t.date "smd_start_date"
			t.date "smd_end_date"
			t.string "smd_state", default: ""
			t.date "dip_start_date"
			t.date "dip_end_date"
			t.date "update_date"
			t.text "production_feedback", limit: 4294967295
			t.text "test_feedback", limit: 4294967295
			t.date "supplement_date"
			t.string "feed_state", default: ""
			t.date "clear_date"
			t.string "salesman_state", default: ""
			t.string "remark", default: ""
			t.integer "order_state", default: 0, unsigned: true
			t.integer "feedback_state", default: 0, unsigned: true
			t.integer "gangwang", default: 0
			t.integer "guolu", default: 0
			t.integer "ceshi", default: 0
			t.float "smt_time", limit: 24, default: 0.0
			t.float "dip_time", limit: 24, default: 0.0
			t.float "ceshi_time", limit: 24, default: 0.0
			t.float "total_time", limit: 24, default: 0.0
			t.date "last_at"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
			t.index ["order_no"], name: "order_no", unique: true, using: :btree
		end

		create_table "works", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.date "order_date"
			t.string "order_no", default: ""
			t.integer "order_quantity"
			t.date "salesman_end_date"
			t.string "product_code", default: ""
			t.integer "warehouse_quantity"
			t.string "smd", default: ""
			t.string "dip", default: ""
			t.date "smd_start_date"
			t.string "smd_end_date"
			t.string "smd_state", default: ""
			t.date "dip_start_date"
			t.date "dip_end_date"
			t.date "update_date"
			t.string "production_feedback", default: ""
			t.string "test_feedback", default: ""
			t.date "supplement_date"
			t.string "feed_state", default: ""
			t.date "clear_date"
			t.string "salesman_state", default: ""
			t.string "remark", default: ""
			t.integer "order_state", default: 0, unsigned: true
			t.string "user_name"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "zong_zhang_dai_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "zong_zhang_info_id"
			t.string "dai_fang_kemu"
			t.decimal "dai_fang", precision: 20, scale: 6
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "zong_zhang_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.string "zong_zhang_type", default: ""
			t.integer "finance_voucher_info_id"
			t.integer "fu_kuan_dan_info_id"
			t.integer "no"
			t.string "des"
			t.string "jie_fang_kemu"
			t.string "dai_fang_kemu"
			t.decimal "jie_fang", precision: 20, scale: 6
			t.decimal "dai_fang", precision: 20, scale: 6
			t.datetime "finance_at"
			t.string "remark"
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

		create_table "zong_zhang_jie_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
			t.integer "zong_zhang_info_id"
			t.string "jie_fang_kemu"
			t.decimal "jie_fang", precision: 20, scale: 6
			t.datetime "created_at", null: false
			t.datetime "updated_at", null: false
		end

	end
end
