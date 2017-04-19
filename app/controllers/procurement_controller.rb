#encoding: UTF-8
require 'roo'
require 'spreadsheet'
require 'will_paginate/array'
require 'rubygems'
require 'json'
require 'net/http'
class ProcurementController < ApplicationController
skip_before_action :verify_authenticity_token
before_filter :authenticate_user!

    def moko_bom_up_done
        if not can? :work_d, :all or can? :work_admin, :all
            render plain: "You don't have permission to view this page !" and return
        end

        find_bom = MokoBomInfo.find_by_id(params[:up_bom])
        old_active_bom = MokoBomInfo.find_by(bom_id: find_bom.bom_id,moko_state: "active")
        if not old_active_bom.blank?
            old_active_bom.moko_state = "old"
            old_active_bom.save
        end
        find_bom.moko_state = "active"
        find_bom.save
        redirect_to :back
    end

    def moko_bom_upgrade
        if not can? :work_d, :all or can? :work_admin, :all
            render plain: "You don't have permission to view this page !" and return
        end
        find_bom = MokoBomInfo.find_by_id(params[:old_bom])
        bom_version_find = MokoBomInfo.where(bom_id: find_bom.bom_id)
        if not bom_version_find.blank?
            bom_version = bom_version_find.last.bom_version.to_i + 1
        else
            bom_version = 1
        end
        if not find_bom.blank?
            up_bom = MokoBomInfo.new
            up_bom.moko_state = "new"
            up_bom.bom_id = find_bom.bom_id
            up_bom.bom_version = bom_version
            up_bom.order_country = find_bom.order_country
            up_bom.erp_id = find_bom.erp_id
            up_bom.erp_item_id = find_bom.erp_item_id
            up_bom.erp_no = find_bom.erp_no
            up_bom.erp_no_son = find_bom.erp_no_son
            up_bom.erp_qty = find_bom.erp_qty
            up_bom.order_do = find_bom.order_do
            up_bom.star = find_bom.star
            up_bom.sell_remark = find_bom.sell_remark
            up_bom.sell_manager_remark = find_bom.sell_manager_remark
            up_bom.name = find_bom.name
            up_bom.p_name_mom = find_bom.p_name_mom
            up_bom.p_name = find_bom.p_name
            up_bom.bom_eng = find_bom.bom_eng
            up_bom.bom_eng_up = current_user.full_name
                #up_bom.remark_to_sell = find_bom.remark_to_sell

            up_bom.check = find_bom.check
   
            up_bom.remark = find_bom.remark
            up_bom.t_p = find_bom.t_p
            up_bom.profit = find_bom.profit
            up_bom.t_pp = find_bom.t_pp
            up_bom.d_day = find_bom.d_day
            up_bom.description = find_bom.description
            up_bom.excel_file = find_bom.excel_file
            up_bom.att = find_bom.att
            up_bom.pcb_p = find_bom.pcb_p
            up_bom.pcb_file = find_bom.pcb_file
            up_bom.pcb_layer = find_bom.pcb_layer
            up_bom.pcb_qty = find_bom.pcb_qty
            up_bom.pcb_size_c = find_bom.pcb_size_c
            up_bom.pcb_size_k = find_bom.pcb_size_k
            up_bom.pcb_sc = find_bom.pcb_sc
            up_bom.pcb_material = find_bom.pcb_material
            up_bom.pcb_cc = find_bom.pcb_cc
            up_bom.pcb_ct = find_bom.pcb_ct
            up_bom.pcb_sf = find_bom.pcb_sf
            up_bom.pcb_t = find_bom.pcb_t
            up_bom.t_c = find_bom.t_c
            up_bom.c_p = find_bom.c_p
            up_bom.user_id = find_bom.user_id
            up_bom.all_title = find_bom.all_title
            up_bom.row_use = find_bom.row_use
            up_bom.bom_eng_up = current_user.full_name

            up_bom.bom_team_ck = find_bom.bom_team_ck

            up_bom.sell_feed_back_tag = find_bom.sell_feed_back_tag
            if up_bom.save 
                find_bom_item = MokoBomItem.where(moko_bom_info_id: find_bom.id)
                if not find_bom_item.blank?
                    find_bom_item.each do |item_p|
                        up_item = up_bom.moko_bom_items.build()
                        up_item.bom_version = up_bom.bom_version
                        up_item.p_type = item_p.p_type
                        up_item.erp_id = item_p.erp_id
                        up_item.erp_no = item_p.erp_no
                        up_item.user_do = item_p.user_do
                        up_item.user_do_change = item_p.user_do_change
                        up_item.check = item_p.check

                        up_item.quantity = item_p.quantity
 
 
                        up_item.customer_qty = item_p.customer_qty
                        up_item.description = item_p.description
                        up_item.part_code = item_p.part_code
                        up_item.fengzhuang = item_p.fengzhuang
                        up_item.link = item_p.link
                        up_item.cost = item_p.cost
                        up_item.info = item_p.info
                        up_item.product_id = item_p.product_id
                        up_item.moko_part = item_p.moko_part
                        up_item.moko_des = item_p.moko_des
                        up_item.warn = item_p.warn
                        up_item.user_id = item_p.user_id
                        up_item.danger = item_p.danger
                        up_item.manual = item_p.manual
                        up_item.mark = item_p.mark
                        up_item.mpn = item_p.mpn
                        up_item.mpn_id = item_p.mpn_id
                        up_item.price = item_p.price
                        up_item.mf = item_p.mf
                        up_item.dn_id = item_p.dn_id
                        up_item.dn = item_p.dn
                        up_item.dn_long = item_p.dn_long
                        up_item.other = item_p.other
                        up_item.all_info = item_p.all_info
                        up_item.remark = item_p.remark
                        up_item.color = item_p.color
                        up_item.supplier_tag = item_p.supplier_tag
                        up_item.supplier_out_tag = item_p.supplier_out_tag
                        up_item.sell_feed_back_tag = item_p.sell_feed_back_tag
                        up_item.save
                    end
                end
            end
        end
        redirect_to moko_view_bom_path(bom_id: up_bom.id)
    end

    def edit_item_ref_moko
        if can? :work_d, :all or can? :work_admin, :all 
            if not params[:item_id].blank?
                get_item_data = MokoBomItem.find_by_id(params[:item_id])
                if not get_item_data.blank?
                    @bom = MokoBomInfo.find(get_item_data.moko_bom_info_id) 
                    get_item_data.part_code = params[:item_ref]
                    get_item_data.quantity = params[:ref_quantity]
                    get_item_data.pmc_qty = @bom.qty.to_i*params[:ref_quantity].to_i
                    if get_item_data.save
                        #@bom = ProcurementBom.find(get_item_data.procurement_bom_id)  
                        @bom_item = MokoBomItem.where(moko_bom_info_id: get_item_data.moko_bom_info_id)
                        @total_p = 0
                        @bom_item.each do |bomitem|
                            if not bomitem.cost.blank?
                                @total_p += bomitem.cost*bomitem.pmc_qty
                                #@total_p += bomitem.cost*bomitem.quantity*@bom.qty
                            end
                        end
                        @bom.t_p = @total_p
                        @bom.change_flag = "done"
                        @bom.save
                    end
                end
            end
        end
        redirect_to :back
    end

    def edit_item_ref
        if can? :work_d, :all or can? :work_admin, :all 
            if not params[:item_id].blank?
                get_item_data = PItem.find_by_id(params[:item_id])
                if not get_item_data.blank?
                    @bom = ProcurementBom.find(get_item_data.procurement_bom_id) 
                    get_item_data.part_code = params[:item_ref]
                    get_item_data.quantity = params[:ref_quantity]
                    get_item_data.link = params[:item_link]
                    get_item_data.pmc_qty = @bom.qty.to_i*params[:ref_quantity].to_i
                    if get_item_data.save
                        #@bom = ProcurementBom.find(get_item_data.procurement_bom_id)  
                        @bom_item = PItem.where(procurement_bom_id: get_item_data.procurement_bom_id)
                        @total_p = 0
                        @bom_item.each do |bomitem|
                            if not bomitem.cost.blank?
                                @total_p += bomitem.cost*bomitem.pmc_qty
                                #@total_p += bomitem.cost*bomitem.quantity*@bom.qty
                            end
                        end
                        @bom.t_p = @total_p
                        @bom.change_flag = "done"
                        @bom.save
                    end
                end
            end
        end
        redirect_to :back
    end

    def p_add_bom
        get_bom = ProcurementBom.find_by_id(params[:p_id])
        if not get_bom.blank?
            bom_item = PItem.new
            if not params[:ecn].blank?
                bom_item.add_state = "new"
            end
            bom_item.bom_version = get_bom.bom_version
            bom_item.pmc_qty = params[:p_qty].to_i*get_bom.qty.to_i
            bom_item.procurement_bom_id = params[:p_id]
            bom_item.quantity = params[:p_qty]
            if not params[:p_mpn].blank?
                bom_item.mpn = params[:p_mpn]
            end
            bom_item.part_code = params[:p_code]
            if not params[:p_des].blank?
                bom_item.description = params[:p_des]
            end
            if not params[:p_link].blank?
                bom_item.link = params[:p_link]
            end
            bom_item.user_id = current_user.id
            if bom_item.save
                get_bom.change_flag = "done"
                get_bom.save
            end
        end
        redirect_to :back
    end

    def del_bom_item
        if can? :work_d, :all or can? :work_admin, :all 
            if not params[:id].blank?
                get_data = PItem.find_by_id(params[:id])
                if not get_data.blank?
                    if not get_data.cost.blank? and not get_data.pmc_qty.blank?
                        del_t_p = get_data.pmc_qty*get_data.cost
                        get_bom = ProcurementBom.find_by_id(get_data.procurement_bom_id)  
                        if not get_bom.blank?
                            get_bom.t_p = get_bom.t_p - del_t_p
                            get_bom.save
                        end
                    end
                    if get_data.destroy
                        render "del_bom_item.js.erb" and return
                    end
                end
            end
        end
        redirect_to :back
    end

    def chk_add_bom_item
        if can? :work_d, :all or can? :work_admin, :all 
            if not params[:id].blank?
                get_data = PItem.find_by_id(params[:id])
                if not get_data.blank?
                    get_data.add_state = ""
                    get_data.save
                    get_bom = ProcurementBom.find_by_id(get_data.procurement_bom_id)  



                    new_qty_info = PiBomQtyInfo.find_by(pi_info_id: params[:pi_info_id],pi_item_id: params[:pi_item_id],bom_id: get_data.procurement_bom_id)
                    pi_draft = PiInfo.find_by_id(params[:pi_info_id])
                    pi_item_data = PiItem.find_by_id(params[:pi_item_id])
                    #新建数量申请item
                    q_item = get_data
                    new_qty_info_item = PiBomQtyInfoItem.new
                    new_qty_info_item.pi_bom_qty_info_id = new_qty_info.id
                    new_qty_info_item.pi_info_id = new_qty_info.pi_info_id
                    new_qty_info_item.pi_item_id = pi_item_data.id
                    new_qty_info_item.order_item_id = pi_item_data.order_item_id
                    new_qty_info_item.bom_id = new_qty_info.bom_id
                    new_qty_info_item.p_item_id = q_item.id
                    new_qty_info_item.qty = new_qty_info.qty
                    new_qty_info_item.t_qty = new_qty_info.t_qty
                    history_qty_info_item = PiBomQtyInfoItem.find_by_sql("SELECT SUM(qty) AS qty FROM pi_bom_qty_info_items WHERE pi_info_id = '#{pi_draft.id}' AND p_item_id = '#{q_item.id}'")
                    h_qty = 0
                    if not history_qty_info_item.blank?
                        h_qty = history_qty_info_item.first.qty.to_i
                    end
                    history_c_qty_info_item = PiBomQtyInfoItem.find_by_sql("SELECT SUM(qty) AS c_qty FROM pi_bom_qty_info_items WHERE pi_info_id = '#{pi_draft.id}' AND p_item_id = '#{q_item.id}'")
                    c_qty = 0
                    if not history_c_qty_info_item.blank?
                        c_qty = history_c_qty_info_item.first.c_qty.to_i
                    end
                    if not history_qty_info_item.blank?
                        use_qty = (new_qty_info.t_qty*q_item.quantity) - h_qty - c_qty
                        if use_qty >= new_qty_info.qty*q_item.quantity
                            new_qty_info_item.bom_ctl_qty = new_qty_info.qty*q_item.quantity
                        elsif use_qty < new_qty_info.qty*q_item.quantity
                            new_qty_info_item.bom_ctl_qty = use_qty
                        end
                    else
                        new_qty_info_item.bom_ctl_qty = new_qty_info.qty*q_item.quantity
                    end
                    new_qty_info_item.save

                    item_buy = PiBomQtyInfoItem.find_by_sql("SELECT pi_bom_qty_info_items.pi_item_id,pi_bom_qty_info_items.pi_info_id,pi_bom_qty_info_items.bom_ctl_qty AS pmc_qty,pi_bom_qty_info_items.customer_qty,pi_bom_qty_info_items.p_item_id,pi_bom_qty_info_items.order_item_id,pi_bom_qty_info_items.id AS qty_item_id FROM pi_bom_qty_info_items WHERE pi_bom_qty_info_items.id = '#{new_qty_info_item.id}'").first
                    need_buy = "no"
                    need_chk = "no"
                    item_id = item_buy.p_item_id
                    item_data = PItem.find_by_id(item_id)
                    if not item_data.blank?
                        Rails.logger.info("pmc_new--------------------------------------3")
                        find_buy_data = PiPmcItem.find_by_p_item_id(item_id)
                        #find_buy_data = ""
                        if find_buy_data.blank?
                            Rails.logger.info("pmc_new--------------------------------------4")
                            add_buy_data = PiPmcItem.new
                            add_buy_data.state = "new"
                            add_buy_data.pi_info_id = item_buy.pi_info_id
                            add_buy_data.pi_item_id = item_buy.pi_item_id
                            add_buy_data.pi_bom_qty_info_item_id = item_buy.qty_item_id
                            add_buy_data.erp_no = item_data.erp_no
                            add_buy_data.erp_no_son = PcbOrderItem.find_by_id(item_buy.order_item_id).pcb_order_no_son
                            #add_buy_data.erp_no_son = item_data.erp_no
                            add_buy_data.moko_part = item_data.moko_part
                            add_buy_data.moko_des = item_data.moko_des
                            add_buy_data.part_code = item_data.part_code
        

                            moko_data = Product.find_by_id(item_data.product_id)
                            wh_data = WarehouseInfo.find_by_moko_part(item_data.moko_part)
                            if wh_data.blank?
                                wh_data = WarehouseInfo.new
                                wh_data.moko_part = item_data.moko_part
                                wh_data.moko_des = item_data.moko_des
                                wh_data.save
                            end
                            use_data = WhChkInfo.find_by_sql("SELECT SUM(wh_chk_infos.chk_qty) AS use_qty FROM wh_chk_infos WHERE (wh_chk_infos.state = 'new' OR wh_chk_infos.state = 'applying') AND wh_chk_infos.moko_part = '#{item_data.moko_part}'")
                            use_qty = 0
                            if not use_data.blank?
                                if not use_data.first.use_qty.blank?
                                    use_qty = use_data.first.use_qty
                                end 
                            end
                            #sell_qty = item_data.quantity*ProcurementBom.find(item_data.procurement_bom_id).qty
                            #需求
                            #sell_qty = item_data.quantity*PcbOrderItem.find_by_id(item_buy.order_item_id).qty
                            #sell_qty = item_data.pmc_qty
                            sell_qty = item_buy.pmc_qty
                            add_buy_data.qty = sell_qty
                            add_buy_data.qty_in = sell_qty 
                            chk_data = WhChkInfo.where(moko_part: item_data.moko_part,state: "new")
                            #如果这个料正在被申请盘点中
                            if not chk_data.blank?
                                add_buy_data.buy_user = "CHK"
                                add_buy_data.pmc_type = "CHK"
                                add_buy_data.buy_qty = sell_qty
                                add_buy_data.pmc_qty = sell_qty
                            else
                                #如果库存中有这个料
                                if not wh_data.blank? and not moko_data.blank?
                                    Rails.logger.info("pmc_new--------------------------------------5")
                                    #如果库存大于0
                                    if wh_data.qty > 0 and wh_data.qty - use_qty > 0
                                        Rails.logger.info("pmc_new--------------------------------------6")
                                        add_buy_data.buy_user = "CHK"
                                        add_buy_data.pmc_type = "CHK"
                                        add_buy_data.buy_qty = sell_qty
                                        add_buy_data.pmc_qty = sell_qty
                                        need_chk = "do"
=begin
                                send_chk_wh = WhChkInfo.new
                                send_chk_wh.pi_pmc_item_id = add_buy_data.id
                                send_chk_wh.erp_no_son = PcbOrderItem.find_by_id(item_buy.order_item_id).pcb_order_no_son
                                send_chk_wh.p_item_id = item_data.id
                                send_chk_wh.moko_part = item_data.moko_part
                                send_chk_wh.moko_des = item_data.moko_des
                                send_chk_wh.chk_qty = wh_data.qty
                                send_chk_wh.state = "new"
                                send_chk_wh.save
=end
                            
                                    else
                                        Rails.logger.info("pmc_new--------------------------------------7")
                                        #如果虚拟库存大于0
                                        if wh_data.future_qty > 0
                                        Rails.logger.info("pmc_new--------------------------------------8")
                                            #如果库存虚拟大于等于需求
                                            if wh_data.future_qty - sell_qty >= 0
                                                Rails.logger.info("pmc_new--------------------------------------9")
                                                add_buy_data.buy_user = "MOKO_TEMP"
                                                add_buy_data.buy_qty = sell_qty
                                                add_buy_data.pmc_qty = sell_qty
                                                wh_data.future_qty = wh_data.future_qty - sell_qty
                                                wh_data.temp_future_qty = wh_data.temp_future_qty + sell_qty
                                                wh_data.save
                                            elsif wh_data.future_qty - sell_qty < 0
                                                Rails.logger.info("pmc_new--------------------------------------10")
                                                add_buy_data.buy_user = "MOKO_TEMP"
                                                add_buy_data.buy_qty = wh_data.future_qty
                                                add_buy_data.pmc_qty = wh_data.future_qty
                                                wh_data.future_qty = 0
                                                wh_data.temp_future_qty = wh_data.temp_future_qty + wh_data.temp_future_qty
                                                wh_data.save
                                                #不够的让采购员补齐
                                                need_buy = "do"
                                    
                                            end
                                        else
                                            Rails.logger.info("pmc_new--------------------------------------11")
                                            add_buy_data.buy_qty = sell_qty
                                            add_buy_data.pmc_qty = sell_qty
                                            if moko_data.package1 == "D" or moko_data.package1 == "Q"
                                                add_buy_data.buy_user = "A"
                                            elsif moko_data.package1 == "PZ"
                                                add_buy_data.buy_user = "B"
                                            end
                                            wh_data.temp_buy_qty = wh_data.temp_buy_qty.to_i + sell_qty.to_i
                                            wh_data.true_buy_qty = wh_data.true_buy_qty.to_i + sell_qty.to_i
                                            wh_data.save
                                        end
                                    end
                                else
                                    Rails.logger.info("pmc_new--------------------------------------12")
                                    wh_data = WarehouseInfo.new
                                    wh_data.moko_part = item_data.moko_part
                                    wh_data.moko_des = item_data.moko_des
                                    wh_data.save
                                    add_buy_data.buy_qty = sell_qty
                                    add_buy_data.pmc_qty = sell_qty
                            
                                end
                            end
                            Rails.logger.info("pmc_new--------------------------------------13")


                            add_buy_data.remark = item_data.remark

                         


                            add_buy_data.p_item_id = item_data.id
                            add_buy_data.erp_id = item_data.erp_id
                            add_buy_data.user_do = item_data.user_do
                            add_buy_data.user_do_change = item_data.user_do_change
                            add_buy_data.check = item_data.check
                            add_buy_data.pi_buy_info_id = params[:pi_buy_id]
                            add_buy_data.procurement_bom_id = item_data.procurement_bom_id
                            add_buy_data.quantity = item_data.quantity
                            add_buy_data.description = item_data.description
                            add_buy_data.fengzhuang = item_data.fengzhuang
                            add_buy_data.link = item_data.link
                            add_buy_data.cost = item_data.cost
                            add_buy_data.info = item_data.info
                            add_buy_data.product_id = item_data.product_id
                            add_buy_data.warn = item_data.warn
                            add_buy_data.user_id = item_data.user_id
                            add_buy_data.danger = item_data.danger
                            add_buy_data.manual = item_data.manual
                            add_buy_data.mark = item_data.mark
                            add_buy_data.mpn = item_data.mpn
                            add_buy_data.mpn_id = item_data.mpn_id
                            add_buy_data.price = item_data.price
                            add_buy_data.mf = item_data.mf
                            add_buy_data.dn = item_data.dn
                            add_buy_data.dn_id = item_data.dn_id
                            add_buy_data.dn_long = item_data.dn_long
                            add_buy_data.other = item_data.other
                            add_buy_data.all_info = item_data.all_info
                            add_buy_data.color = item_data.color
                            add_buy_data.supplier_tag = item_data.supplier_tag
                            add_buy_data.supplier_out_tag = item_data.supplier_out_tag
                            add_buy_data.sell_feed_back_tag = item_data.sell_feed_back_tag
                            if add_buy_data.save
                                Rails.logger.info("pmc_new--------------------------------------14")
                                #判断是否需要工厂盘料
                                #if not wh_data.blank? and not moko_data.blank?
                                if need_chk == "do"  
                                    Rails.logger.info("pmc_new--------------------------------------15")
                                    if wh_data.qty > 0 and wh_data.qty - use_qty > 0
                                        Rails.logger.info("pmc_new--------------------------------------16")
                                        send_chk_wh = WhChkInfo.new
                                        send_chk_wh.pi_pmc_item_id = add_buy_data.id
                                        send_chk_wh.erp_no_son = PcbOrderItem.find_by_id(item_buy.order_item_id).pcb_order_no_son
                                        send_chk_wh.p_item_id = item_data.id
                                        send_chk_wh.moko_part = item_data.moko_part
                                        send_chk_wh.moko_des = item_data.moko_des
                                        send_chk_wh.chk_qty = wh_data.qty
                                        send_chk_wh.state = "new"
                                        send_chk_wh.save
                                    end
                                end
                                #判断是否需要采购补齐
                                if need_buy == "do"
                                    Rails.logger.info("pmc_new--------------------------------------17")
                                    add_buy_do = PiPmcItem.new
                                    add_buy_do.state = "new"
                                    add_buy_do.pi_bom_qty_info_item_id = item_buy.qty_item_id
                                    add_buy_do.pi_info_id = item_buy.pi_info_id
                                    add_buy_do.pi_item_id = item_buy.pi_item_id
                                    add_buy_do.erp_no = add_buy_data.erp_no
                                    add_buy_do.erp_no_son = add_buy_data.erp_no_son
                                    add_buy_do.moko_part = add_buy_data.moko_part
                                    add_buy_do.moko_des = add_buy_data.moko_des
                                    add_buy_do.part_code = add_buy_data.part_code

                                    add_buy_do.qty = add_buy_data.qty
                                    add_buy_do.qty_in = add_buy_data.qty

                                    if moko_data.package1 == "D" or moko_data.package1 == "Q"
                                        add_buy_do.buy_user = "A"
                                    elsif moko_data.package1 == "PZ"
                                        add_buy_do.buy_user = "B"
                                    end
                                    add_buy_do.buy_qty = add_buy_data.qty - add_buy_data.buy_qty
                                    add_buy_do.pmc_qty = add_buy_data.qty - add_buy_data.buy_qty
                                    add_buy_do.remark = add_buy_data.remark
                                    add_buy_do.p_item_id = add_buy_data.p_item_id
                                    add_buy_do.erp_id = add_buy_data.erp_id
                                    add_buy_do.user_do = add_buy_data.user_do
                                    add_buy_do.user_do_change = add_buy_data.user_do_change
                                    add_buy_do.check = add_buy_data.check
                                    add_buy_do.pi_buy_info_id = add_buy_data.pi_buy_info_id
                                    add_buy_do.procurement_bom_id = add_buy_data.procurement_bom_id
                                    add_buy_do.quantity = add_buy_data.quantity
                                    add_buy_do.description = add_buy_data.description
                                    add_buy_do.fengzhuang = add_buy_data.fengzhuang
                                    add_buy_do.link = add_buy_data.link
                                    add_buy_do.cost = add_buy_data.cost
                                    add_buy_do.info = add_buy_data.info
                                    add_buy_do.product_id = add_buy_data.product_id
                                    add_buy_do.warn = add_buy_data.warn
                                    add_buy_do.user_id = add_buy_data.user_id
                                    add_buy_do.danger = add_buy_data.danger
                                    add_buy_do.manual = add_buy_data.manual
                                    add_buy_do.mark = add_buy_data.mark
                                    add_buy_do.mpn = add_buy_data.mpn
                                    add_buy_do.mpn_id = add_buy_data.mpn_id
                                    add_buy_do.price = add_buy_data.price
                                    add_buy_do.mf = add_buy_data.mf
                                    add_buy_do.dn = add_buy_data.dn
                                    add_buy_do.dn_id = add_buy_data.dn_id
                                    add_buy_do.dn_long = add_buy_data.dn_long
                                    add_buy_do.other = add_buy_data.other
                                    add_buy_do.all_info = add_buy_data.all_info
                                    add_buy_do.color = add_buy_data.color
                                    add_buy_do.supplier_tag = add_buy_data.supplier_tag
                                    add_buy_do.supplier_out_tag = add_buy_data.supplier_out_tag
                                    add_buy_do.sell_feed_back_tag = add_buy_data.sell_feed_back_tag
                                    if add_buy_do.save
                                        Rails.logger.info("pmc_new--------------------------------------18")
                                        wh_data.temp_buy_qty = wh_data.temp_buy_qty + add_buy_do.buy_qty
                                        wh_data.save
                                    end
                                end
                                get_qty_item_date = PiBomQtyInfoItem.find_by_id(item_buy.qty_item_id)
                                get_qty_item_date.buy = "pmc"
                                get_qty_item_date.save
                                Rails.logger.info("pmc_new--------------------------------------19")
                                #判断是否需要客供
                                #if item_data.customer_qty > 0
                                if item_buy.customer_qty.to_i > 0
                                    add_customer_data = PiPmcItem.new
                                    add_customer_data.pi_info_id = item_buy.pi_info_id
                                    add_customer_data.pi_item_id = item_buy.pi_item_id
                                    add_customer_data.pi_bom_qty_info_item_id = item_buy.qty_item_id
                                    add_customer_data.state = "new"
                                    add_customer_data.erp_no = item_data.erp_no
                                    add_customer_data.erp_no_son = PcbOrderItem.find_by_id(item_buy.order_item_id).pcb_order_no_son
                                    #add_customer_data.erp_no_son = item_data.erp_no
                                    add_customer_data.moko_part = item_data.moko_part
                                    add_customer_data.moko_des = item_data.moko_des
                                    add_customer_data.part_code = item_data.part_code
                                    add_customer_data.qty = sell_qty
                                    add_customer_data.qty_in = item_buy.customer_qty
                                    add_customer_data.buy_user = "CUSTOMER"
                                    add_customer_data.pmc_type = "CHK"
                                    add_customer_data.buy_qty = item_buy.customer_qty
                                    add_customer_data.pmc_qty = item_buy.customer_qty
                                    add_customer_data.remark = item_data.remark
                                    add_customer_data.p_item_id = item_data.id
                                    add_customer_data.erp_id = item_data.erp_id
                                    add_customer_data.user_do = item_data.user_do
                                    add_customer_data.user_do_change = item_data.user_do_change
                                    add_customer_data.check = item_data.check
                                    add_customer_data.pi_buy_info_id = params[:pi_buy_id]
                                    add_customer_data.procurement_bom_id = item_data.procurement_bom_id
                                    add_customer_data.quantity = item_data.quantity
                                    add_customer_data.description = item_data.description
                                    add_customer_data.fengzhuang = item_data.fengzhuang
                                    add_customer_data.link = item_data.link
                                    add_customer_data.cost = item_data.cost
                                    add_customer_data.info = item_data.info
                                    add_customer_data.product_id = item_data.product_id
                                    add_customer_data.warn = item_data.warn
                                    add_customer_data.user_id = item_data.user_id
                                    add_customer_data.danger = item_data.danger
                                    add_customer_data.manual = item_data.manual
                                    add_customer_data.mark = item_data.mark
                                    add_customer_data.mpn = item_data.mpn
                                    add_customer_data.mpn_id = item_data.mpn_id
                                    add_customer_data.price = item_data.price
                                    add_customer_data.mf = item_data.mf
                                    add_customer_data.dn = item_data.dn
                                    add_customer_data.dn_id = item_data.dn_id
                                    add_customer_data.dn_long = item_data.dn_long
                                    add_customer_data.other = item_data.other
                                    add_customer_data.all_info = item_data.all_info
                                    add_customer_data.color = item_data.color
                                    add_customer_data.supplier_tag = item_data.supplier_tag
                                    add_customer_data.supplier_out_tag = item_data.supplier_out_tag
                                    add_customer_data.sell_feed_back_tag = item_data.sell_feed_back_tag
                                    if add_customer_data.save
                                        wh_data.temp_customer_qty = wh_data.temp_customer_qty.to_i + add_customer_data.pmc_qty.to_i
                                        wh_data.save
                                    end
                                end
                            end
                        end
                    end


                end
            end
        end
        redirect_to :back
    end

    def del_bom_item_moko
        if can? :work_d, :all or can? :work_admin, :all 
            if not params[:id].blank?
                get_data = MokoBomItem.find_by_id(params[:id])
                if not get_data.blank?
                    if not get_data.cost.blank? and not get_data.pmc_qty.blank?
                        del_t_p = get_data.pmc_qty*get_data.cost
                        get_bom = MokoBomInfo.find_by_id(get_data.moko_bom_info_id)  
                        if not get_bom.blank?
                            get_bom.t_p = get_bom.t_p - del_t_p
                            get_bom.save
                        end
                    end
                    if get_data.destroy
                        render "del_bom_item.js.erb" and return
                    end
                end
            end
        end
        redirect_to :back
    end

    def edit_item_qty
        if can? :work_d, :all or can? :work_admin, :all 
            if not params[:item_id].blank?
                get_item_data = PiBomQtyInfoItem.find_by_id(params[:item_id])
                if not get_item_data.blank?
                    get_item_data.bom_ctl_qty = params[:pmc_qty]
                    get_item_data.customer_qty = params[:customer_qty]
                    get_item_data.save
=begin
                        @bom = ProcurementBom.find(get_item_data.procurement_bom_id)  
                        @bom_item = PItem.where(procurement_bom_id: get_item_data.procurement_bom_id)
                        @total_p = 0
                        @bom_item.each do |bomitem|
                            if not bomitem.cost.blank?
                                @total_p += bomitem.cost*bomitem.pmc_qty
                            end
                        end
                        @bom.t_p = @total_p
                        @bom.save
                    end
=end
                end
            end
        end
        redirect_to :back
    end

    def sell_feeback_list
        if can? :work_admin, :all 
            @quate = PItem.find_by_sql("SELECT pcb_orders.order_sell, pcb_order_items.pcb_order_id, pcb_order_items.pcb_order_no_son, p_items.* FROM pcb_order_items INNER JOIN pcb_orders ON pcb_order_items.pcb_order_id = pcb_orders.id INNER JOIN p_items ON p_items.procurement_bom_id = pcb_order_items.bom_id WHERE pcb_order_items.p_type = 'PCBA' AND p_items.sell_feed_back_tag = 'sell'").paginate(:page => params[:page], :per_page => 10)
        elsif can? :work_e, :all
            @quate = PItem.find_by_sql("SELECT pcb_orders.order_sell, pcb_order_items.pcb_order_id, pcb_order_items.pcb_order_no_son, p_items.* FROM pcb_order_items INNER JOIN pcb_orders ON pcb_order_items.pcb_order_id = pcb_orders.id INNER JOIN p_items ON p_items.procurement_bom_id = pcb_order_items.bom_id WHERE pcb_order_items.p_type = 'PCBA' AND pcb_orders.order_sell = '#{current_user.email}' AND p_items.sell_feed_back_tag = 'sell' ").paginate(:page => params[:page], :per_page => 10)
        elsif can? :work_d, :all
            @bom_item = PItem.find_by_sql("SELECT pcb_orders.order_sell, pcb_order_items.pcb_order_id, pcb_order_items.pcb_order_no_son, p_items.* FROM pcb_order_items INNER JOIN pcb_orders ON pcb_order_items.pcb_order_id = pcb_orders.id INNER JOIN p_items ON p_items.procurement_bom_id = pcb_order_items.bom_id WHERE pcb_order_items.p_type = 'PCBA' AND p_items.sell_feed_back_tag = 'eng'").paginate(:page => params[:page], :per_page => 10)
            render "eng_feeback_list.html.erb" and return
        end
    end

    def cost_history
        order_set = "created_at DESC, date DESC"
        if params[:order_by] == "time"
            order_set = "created_at DESC, date DESC"
        elsif params[:order_by] == "dn"
            order_set = "dn DESC, created_at DESC, date DESC"
        elsif params[:order_by] == "qty"
            order_set = "qty DESC, created_at DESC, date DESC"
        elsif params[:order_by] == "cost"
            order_set = "cost DESC, created_at DESC, date DESC"
        end
        @history_list = PDn.where(part_code: params[:part_code]).order(order_set)
        if not @history_list.blank?
            @c_table = '<br>'
            @c_table += '<small>'
            @c_table += '<table class="table table-bordered">'
            @c_table += '<thead>'
            @c_table += '<tr class="active">'
            @c_table += '<th width="100"><a class="text-primary" data-method="get" data-remote="true" href="/cost_history?part_code='+params[:part_code].to_s+'&item_id='+params[:item_id].to_s+'&order_by=time">询价时间</a><span class="caret"></span></th>'
            @c_table += '<th>MOKO代码</th>' 
            @c_table += '<th width="120"><a class="text-primary" data-method="get" data-remote="true" href="/cost_history?part_code='+params[:part_code].to_s+'&item_id='+params[:item_id].to_s+'&order_by=dn">供应商代码</a><span class="caret"></span></th>'
            @c_table += '<th>供应商全称</th>'    
            @c_table += '<th width="100"><a class="text-primary" data-method="get" data-remote="true" href="/cost_history?part_code='+params[:part_code].to_s+'&item_id='+params[:item_id].to_s+'&order_by=qty">数量</a><span class="caret"></span></th>'        
            @c_table += '<th width="100"><a class="text-primary" data-method="get" data-remote="true" href="/cost_history?part_code='+params[:part_code].to_s+'&item_id='+params[:item_id].to_s+'&order_by=cost">价格</a><span class="caret"></span></th>' 
            @c_table += '<tr>'
            @c_table += '</thead>'
            @c_table += '<tbody>'
            @history_list.each do |item|
                @c_table += '<tr>'
                if not item.created_at.blank?
                    @c_table += '<td>' + item.created_at.localtime.strftime('%Y-%m-%d').to_s + '</td>'
                else
                    @c_table += '<td>' + item.date.strftime('%Y-%m-%d').to_s + '</td>'
                end
         

                @c_table += '<td><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_edit?item_id=' + params[:item_id].to_s + '&cost=' + item.cost.to_s + '&dn= ' + item.dn.to_s + '&dn_long= ' + item.dn_long.to_s + '&part_code=' + item.part_code.to_s + '" ><div>' + item.part_code.to_s + '</div></a></small></td>'
                @c_table += '<td><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_edit?item_id=' + params[:item_id].to_s + '&cost=' + item.cost.to_s + '&dn= ' + item.dn.to_s + '&dn_long= ' + item.dn_long.to_s + '&part_code=' + item.part_code.to_s + '" ><div>' + item.dn.to_s + '</div></a></small></td>'
                @c_table += '<td><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_edit?item_id=' + params[:item_id].to_s + '&cost=' + item.cost.to_s + '&dn= ' + item.dn.to_s + '&dn_long= ' + item.dn_long.to_s + '&part_code=' + item.part_code.to_s + '" ><div>' + item.dn_long.to_s + '</div></a></small></td>'
                @c_table += '<td><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_edit?item_id=' + params[:item_id].to_s + '&cost=' + item.cost.to_s + '&dn= ' + item.dn.to_s + '&dn_long= ' + item.dn_long.to_s + '&part_code=' + item.part_code.to_s + '" ><div>' + item.qty.to_s + '</div></a></small></td>'
                @c_table += '<td><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_edit?item_id=' + params[:item_id].to_s + '&cost=' + item.cost.to_s + '&dn= ' + item.dn.to_s + '&dn_long= ' + item.dn_long.to_s + '&part_code=' + item.part_code.to_s + '" ><div>' + item.cost.to_s + '</div></a></small></td>'
                @c_table += '</tr>'
            end
            @c_table += '</tbody>'
            @c_table += '</table>'
            @c_table += '</small>'
        end
    end

    def bom_v_up_moko
        if not params[:order_id].blank?
            upstart = PcbOrderItem.find_by_id(params[:order_id])
        end
        find_bom = MokoBomInfo.find_by_id(params[:bom_id])
        if not find_bom.blank?
=begin
            bom_version_find = ProcurementVersionBom.where(procurement_bom_id: find_bom.id)
            if not bom_version_find.blank?
                bom_version = bom_version_find.last.bom_version.to_i + 1
            else
                bom_version = 1
            end
            up_bom = ProcurementVersionBom.new
=end
            bom_version_find = ProcurementBom.where(bom_id: find_bom.bom_id)
            if not bom_version_find.blank?
                bom_version = bom_version_find.last.bom_version.to_i + 1
            else
                bom_version = 999
            end
            up_bom = ProcurementBom.new
            up_bom.bom_id = find_bom.bom_id
            up_bom.bom_version = bom_version
            up_bom.order_country = find_bom.order_country
            if not params[:bom_unlock].blank?
                up_bom.erp_id = find_bom.erp_id
                up_bom.erp_item_id = find_bom.erp_item_id
                up_bom.erp_no = find_bom.erp_no
                up_bom.erp_no_son = find_bom.erp_no_son
                up_bom.erp_qty = find_bom.erp_qty
                up_bom.order_do = find_bom.order_do
                up_bom.star = find_bom.star
                up_bom.sell_remark = find_bom.sell_remark
                up_bom.sell_manager_remark = find_bom.sell_manager_remark
                up_bom.name = find_bom.name
                up_bom.p_name_mom = find_bom.p_name_mom
                up_bom.p_name = find_bom.p_name
                up_bom.bom_eng = find_bom.bom_eng
                up_bom.bom_eng_up = current_user.full_name
                #up_bom.remark_to_sell = find_bom.remark_to_sell
            end
            up_bom.check = find_bom.check
            if ProcurementBom.find_by_sql('SELECT no FROM procurement_boms WHERE to_days(procurement_boms.created_at) = to_days(NOW())').blank?
            order_n =1
            else

                order_n = ProcurementBom.find_by_sql('SELECT no FROM procurement_boms WHERE to_days(procurement_boms.created_at) = to_days(NOW())').last.no.split("B")[-1].to_i + 1
            end
            up_bom.no = "MB" + Time.new.strftime('%Y').to_s[-1] + Time.new.strftime('%m%d').to_s + "B" + order_n.to_s + "B"

            #up_bom.p_name_mom = "COPY"
            #up_bom.p_name = "COPY"
            #up_bom.qty = find_bom.qty
            if not params[:order_id].blank?
                up_bom.qty = upstart.qty
            else
                up_bom.qty = find_bom.erp_qty
            end
            up_bom.remark = find_bom.remark
            up_bom.t_p = find_bom.t_p
            up_bom.profit = find_bom.profit
            up_bom.t_pp = find_bom.t_pp
            up_bom.d_day = find_bom.d_day
            up_bom.description = find_bom.description
            up_bom.excel_file = find_bom.excel_file
            up_bom.att = find_bom.att
            up_bom.pcb_p = find_bom.pcb_p
            up_bom.pcb_file = find_bom.pcb_file
            up_bom.pcb_layer = find_bom.pcb_layer
            up_bom.pcb_qty = find_bom.pcb_qty
            up_bom.pcb_size_c = find_bom.pcb_size_c
            up_bom.pcb_size_k = find_bom.pcb_size_k
            up_bom.pcb_sc = find_bom.pcb_sc
            up_bom.pcb_material = find_bom.pcb_material
            up_bom.pcb_cc = find_bom.pcb_cc
            up_bom.pcb_ct = find_bom.pcb_ct
            up_bom.pcb_sf = find_bom.pcb_sf
            up_bom.pcb_t = find_bom.pcb_t
            up_bom.t_c = find_bom.t_c
            up_bom.c_p = find_bom.c_p
            up_bom.user_id = find_bom.user_id
            up_bom.all_title = find_bom.all_title
            up_bom.row_use = find_bom.row_use
            up_bom.bom_eng_up = current_user.full_name

            up_bom.bom_team_ck = find_bom.bom_team_ck

            up_bom.sell_feed_back_tag = find_bom.sell_feed_back_tag
            if up_bom.save 
                find_bom_item = MokoBomItem.where(moko_bom_info_id: find_bom.id)
                if not find_bom_item.blank?
                    find_bom_item.each do |item|
                        up_item = up_bom.p_items.build()
                        up_item.bom_version = bom_version
                        up_item.p_type = item.p_type
                        #up_item.buy = item.buy
                        if not params[:bom_unlock].blank?
                            up_item.erp_id = item.erp_id
                            up_item.erp_no = item.erp_no
                        end
                        up_item.user_do = item.user_do
                        up_item.user_do_change = item.user_do_change
                        up_item.check = item.check
                        #up_item.procurement_version_bom_id =
                        up_item.quantity = item.quantity
                        if not params[:order_id].blank?
                            if upstart.p_type == "COMPONENTS"
                                up_item.pmc_qty = item.quantity
                            else
                                up_item.pmc_qty = upstart.qty*item.quantity
                            end
                        else
                            up_item.pmc_qty = item.pmc_qty
                        end
                        up_item.customer_qty = item.customer_qty
                        up_item.description = item.description
                        up_item.part_code = item.part_code
                        up_item.fengzhuang = item.fengzhuang
                        up_item.link = item.link
                        up_item.cost = item.cost
                        up_item.info = item.info
                        up_item.product_id = item.product_id
                        up_item.moko_part = item.moko_part
                        up_item.moko_des = item.moko_des
                        up_item.warn = item.warn
                        up_item.user_id = item.user_id
                        up_item.danger = item.danger
                        up_item.manual = item.manual
                        up_item.mark = item.mark
                        up_item.mpn = item.mpn
                        up_item.mpn_id = item.mpn_id
                        up_item.price = item.price
                        up_item.mf = item.mf
                        up_item.dn_id = item.dn_id
                        up_item.dn = item.dn
                        up_item.dn_long = item.dn_long
                        up_item.other = item.other
                        up_item.all_info = item.all_info
                        up_item.remark = item.remark
                        up_item.color = item.color
                        up_item.supplier_tag = item.supplier_tag
                        up_item.supplier_out_tag = item.supplier_out_tag
                        up_item.sell_feed_back_tag = item.sell_feed_back_tag
                        if up_item.save
                            find_item_dn = PDn.where(p_item_id: item.id,state: "")
                            if not find_item_dn.blank?
                                find_item_dn.each do |item|
                                    up_item_dn = up_item.p_dns.build()
                                    #up_item_dn.p_version_item_id = 
                                    up_item_dn.part_code = item.part_code
                                    up_item_dn.date = item.date
                                    up_item_dn.dn = item.dn
                                    up_item_dn.dn_long = item.dn_long
                                    up_item_dn.cost = item.cost
                                    up_item_dn.qty = item.qty
                                    up_item_dn.info = item.info
                                    up_item_dn.remark = item.remark
                                    up_item_dn.tag = item.tag
                                    up_item_dn.color = item.color
                                    up_item_dn.save
                                end
                            end
                            find_item_remark = PItemRemark.where(p_item_id: item.id)
                            if not find_item_remark.blank?
                                find_item_remark.each do |item|
                                    up_item_remark = up_item.p_item_remarks.build()
                                    #up_item_remark.p_version_item_id = 
                                    up_item_remark.user_id = item.user_id
                                    up_item_remark.user_name = item.user_name
                                    up_item_remark.user_team = item.user_team
                                    up_item_remark.remark = item.remark
                                    up_item_remark.info = item.info
                                    up_item_remark.state = item.state
                                    up_item_remark.save
                                end
                            end
                        end
                    end
                end
            end 
        end
        if not params[:order_id].blank?
            upstart = PcbOrderItem.find_by_id(params[:order_id])
            if params[:state] == "mark"
                upstart.state = "quotechked"
            else
                upstart.state = "quote"
            end
            upstart.p_type = "PCBA"
            upstart.bom_id = up_bom.id
            if upstart.save
                up_bom.erp_id = upstart.pcb_order_id
                up_bom.erp_item_id = upstart.id
                up_bom.erp_no = upstart.pcb_order_no
                up_bom.erp_no_son = upstart.pcb_order_no_son
                up_bom.erp_qty = upstart.qty
                #up_bom.name = find_bom.name
                up_bom.p_name_mom = upstart.pcb_order_no
                up_bom.p_name = upstart.pcb_order_no_son
                up_bom.save
                up_bom_item = PItem.where(procurement_bom_id: up_bom.id).update_all(erp_id: upstart.id,erp_no: upstart.pcb_order_no_son)
            end
        else
            upstart = PcbOrderItem.find_by_id(up_bom.erp_item_id)
            upstart.bom_id = up_bom.id
            upstart.save
            pi_draft = PiItem.find_by_id(params[:pi_item_id])
            pi_draft.bom_id = up_bom.id
            if pi_draft.save
                pi_data = PiInfo.find_by_id(pi_draft.pi_info_id)
                pi_data.state = "check"
                pi_data.bom_state = nil
                pi_data.save
            end
        end
        redirect_to p_viewbom_path(bom_id: up_bom.id)
    end

    def bom_v_up
        if not params[:order_id].blank?
            upstart = PcbOrderItem.find_by_id(params[:order_id])
        end
        find_bom = ProcurementBom.find_by_id(params[:bom_id])
        if not find_bom.blank?
=begin
            bom_version_find = ProcurementVersionBom.where(procurement_bom_id: find_bom.id)
            if not bom_version_find.blank?
                bom_version = bom_version_find.last.bom_version.to_i + 1
            else
                bom_version = 1
            end
            up_bom = ProcurementVersionBom.new
=end
            bom_version_find = ProcurementBom.where(bom_id: find_bom.bom_id)
            if not bom_version_find.blank?
                bom_version = bom_version_find.last.bom_version.to_i + 1
            else
                bom_version = 999
            end
            up_bom = ProcurementBom.new
            up_bom.moko_bom_info_id = find_bom.moko_bom_info_id
            up_bom.bom_id = find_bom.bom_id
            up_bom.bom_version = bom_version
            up_bom.order_country = find_bom.order_country
            if not params[:bom_unlock].blank?
                up_bom.erp_id = find_bom.erp_id
                up_bom.erp_item_id = find_bom.erp_item_id
                up_bom.erp_no = find_bom.erp_no
                up_bom.erp_no_son = find_bom.erp_no_son
                up_bom.erp_qty = find_bom.erp_qty
                up_bom.order_do = find_bom.order_do
                up_bom.star = find_bom.star
                up_bom.sell_remark = find_bom.sell_remark
                up_bom.sell_manager_remark = find_bom.sell_manager_remark
                up_bom.name = find_bom.name
                up_bom.p_name_mom = find_bom.p_name_mom
                up_bom.p_name = find_bom.p_name
                up_bom.bom_eng = find_bom.bom_eng
                up_bom.bom_eng_up = current_user.full_name
                #up_bom.remark_to_sell = find_bom.remark_to_sell
            end
            up_bom.check = find_bom.check
            if ProcurementBom.find_by_sql('SELECT no FROM procurement_boms WHERE to_days(procurement_boms.created_at) = to_days(NOW())').blank?
            order_n =1
            else

                order_n = ProcurementBom.find_by_sql('SELECT no FROM procurement_boms WHERE to_days(procurement_boms.created_at) = to_days(NOW())').last.no.split("B")[-1].to_i + 1
            end
            up_bom.no = "MB" + Time.new.strftime('%Y').to_s[-1] + Time.new.strftime('%m%d').to_s + "B" + order_n.to_s + "B"

            #up_bom.p_name_mom = "COPY"
            #up_bom.p_name = "COPY"
            #up_bom.qty = find_bom.qty
            if not params[:order_id].blank?
                up_bom.qty = upstart.qty
            else
                up_bom.qty = find_bom.erp_qty
            end
            up_bom.remark = find_bom.remark
            up_bom.t_p = find_bom.t_p
            up_bom.profit = find_bom.profit
            up_bom.t_pp = find_bom.t_pp
            up_bom.d_day = find_bom.d_day
            up_bom.description = find_bom.description
            up_bom.excel_file = find_bom.excel_file
            up_bom.att = find_bom.att
            up_bom.pcb_p = find_bom.pcb_p
            up_bom.pcb_file = find_bom.pcb_file
            up_bom.pcb_layer = find_bom.pcb_layer
            up_bom.pcb_qty = find_bom.pcb_qty
            up_bom.pcb_size_c = find_bom.pcb_size_c
            up_bom.pcb_size_k = find_bom.pcb_size_k
            up_bom.pcb_sc = find_bom.pcb_sc
            up_bom.pcb_material = find_bom.pcb_material
            up_bom.pcb_cc = find_bom.pcb_cc
            up_bom.pcb_ct = find_bom.pcb_ct
            up_bom.pcb_sf = find_bom.pcb_sf
            up_bom.pcb_t = find_bom.pcb_t
            up_bom.t_c = find_bom.t_c
            up_bom.c_p = find_bom.c_p
            up_bom.user_id = find_bom.user_id
            up_bom.all_title = find_bom.all_title
            up_bom.row_use = find_bom.row_use
            up_bom.bom_eng_up = current_user.full_name

            up_bom.bom_team_ck = find_bom.bom_team_ck

            up_bom.sell_feed_back_tag = find_bom.sell_feed_back_tag
            if up_bom.save 
                find_bom_item = PItem.where(procurement_bom_id: find_bom.id)
                if not find_bom_item.blank?
                    find_bom_item.each do |item|
                        up_item = up_bom.p_items.build()
                        up_item.moko_bom_item_id = item.moko_bom_item_id
                        up_item.bom_version = bom_version
                        up_item.p_type = item.p_type
                        #up_item.buy = item.buy
                        if not params[:bom_unlock].blank?
                            up_item.erp_id = item.erp_id
                            up_item.erp_no = item.erp_no
                        end
                        up_item.user_do = item.user_do
                        up_item.user_do_change = item.user_do_change
                        up_item.check = item.check
                        #up_item.procurement_version_bom_id =
                        up_item.quantity = item.quantity
                        if not params[:order_id].blank?
                            if upstart.p_type == "COMPONENTS"
                                up_item.pmc_qty = item.quantity
                            else
                                up_item.pmc_qty = upstart.qty*item.quantity
                            end
                        else
                            up_item.pmc_qty = item.pmc_qty
                        end
                        up_item.customer_qty = item.customer_qty
                        up_item.description = item.description
                        up_item.part_code = item.part_code
                        up_item.fengzhuang = item.fengzhuang
                        up_item.link = item.link
                        up_item.cost = item.cost
                        up_item.info = item.info
                        up_item.product_id = item.product_id
                        up_item.moko_part = item.moko_part
                        up_item.moko_des = item.moko_des
                        up_item.warn = item.warn
                        up_item.user_id = item.user_id
                        up_item.danger = item.danger
                        up_item.manual = item.manual
                        up_item.mark = item.mark
                        up_item.mpn = item.mpn
                        up_item.mpn_id = item.mpn_id
                        up_item.price = item.price
                        up_item.mf = item.mf
                        up_item.dn_id = item.dn_id
                        up_item.dn = item.dn
                        up_item.dn_long = item.dn_long
                        up_item.other = item.other
                        up_item.all_info = item.all_info
                        up_item.remark = item.remark
                        up_item.color = item.color
                        up_item.supplier_tag = item.supplier_tag
                        up_item.supplier_out_tag = item.supplier_out_tag
                        up_item.sell_feed_back_tag = item.sell_feed_back_tag
                        if up_item.save
                            find_item_dn = PDn.where(p_item_id: item.id,state: "")
                            if not find_item_dn.blank?
                                find_item_dn.each do |item|
                                    up_item_dn = up_item.p_dns.build()
                                    #up_item_dn.p_version_item_id = 
                                    up_item_dn.part_code = item.part_code
                                    up_item_dn.date = item.date
                                    up_item_dn.dn = item.dn
                                    up_item_dn.dn_long = item.dn_long
                                    up_item_dn.cost = item.cost
                                    up_item_dn.qty = item.qty
                                    up_item_dn.info = item.info
                                    up_item_dn.remark = item.remark
                                    up_item_dn.tag = item.tag
                                    up_item_dn.color = item.color
                                    up_item_dn.save
                                end
                            end
                            find_item_remark = PItemRemark.where(p_item_id: item.id)
                            if not find_item_remark.blank?
                                find_item_remark.each do |item|
                                    up_item_remark = up_item.p_item_remarks.build()
                                    #up_item_remark.p_version_item_id = 
                                    up_item_remark.user_id = item.user_id
                                    up_item_remark.user_name = item.user_name
                                    up_item_remark.user_team = item.user_team
                                    up_item_remark.remark = item.remark
                                    up_item_remark.info = item.info
                                    up_item_remark.state = item.state
                                    up_item_remark.save
                                end
                            end
                        end
                    end
                end
            end 
        end
        if not params[:order_id].blank?
            upstart = PcbOrderItem.find_by_id(params[:order_id])
            if params[:state] == "mark"
                upstart.state = "quotechked"
            else
                upstart.state = "quote"
            end
            upstart.p_type = "PCBA"
            upstart.bom_id = up_bom.id
            if upstart.save
                up_bom.erp_id = upstart.pcb_order_id
                up_bom.erp_item_id = upstart.id
                up_bom.erp_no = upstart.pcb_order_no
                up_bom.erp_no_son = upstart.pcb_order_no_son
                up_bom.erp_qty = upstart.qty
                #up_bom.name = find_bom.name
                up_bom.p_name_mom = upstart.pcb_order_no
                up_bom.p_name = upstart.pcb_order_no_son
                up_bom.save
                up_bom_item = PItem.where(procurement_bom_id: up_bom.id).update_all(erp_id: upstart.id,erp_no: upstart.pcb_order_no_son)
            end
        else
            upstart = PcbOrderItem.find_by_id(up_bom.erp_item_id)
            upstart.bom_id = up_bom.id
            upstart.save
            pi_draft = PiItem.find_by_id(params[:pi_item_id])
            pi_draft.bom_id = up_bom.id
            if pi_draft.save
                pi_data = PiInfo.find_by_id(pi_draft.pi_info_id)
                pi_data.state = "check"
                pi_data.bom_state = nil
                pi_data.save
            end
        end
        redirect_to p_viewbom_path(bom_id: up_bom.id)
    end



    def pcb_list_del
        if can? :work_baojia, :all or can? :work_admin, :all
            get_data = PcbItemInfo.find_by_id(params[:del_id])
            get_data.destroy
        end
        redirect_to :back
    end

    def pcb_list
        @all_pcb_dn = "[&quot;"
        all_s_dn = PcbSupplier.find_by_sql("SELECT DISTINCT pcb_suppliers.name FROM pcb_suppliers GROUP BY pcb_suppliers.name")
        all_s_dn.each do |dn|
            @all_pcb_dn += "&quot;,&quot;" + dn.name.to_s
        end
        @all_pcb_dn += "&quot;]"
        where_state = ""
        if params[:complete]
            where_state = " AND pcb_order_items.state = 'quotechked'"
            if not params[:key_order].blank?
                where_state = where_state + " AND pcb_order_items.pcb_order_no LIKE '%#{params[:key_order]}%'"
            else
                where_state = where_state + " AND to_days(pcb_item_infos.updated_at) = to_days(now())"
            end
            @part = PcbOrderItem.find_by_sql("SELECT pcb_item_infos.*,pcb_order_items.att,pcb_order_items.des_cn,pcb_order_items.pcb_order_no_son,pcb_order_items.pcb_order_id,pcb_item_infos.id AS pcb_item_infos_id FROM pcb_order_items RIGHT JOIN pcb_item_infos ON pcb_order_items.id = pcb_item_infos.pcb_order_item_id WHERE pcb_order_items.p_type = 'pcb' #{where_state} ORDER BY pcb_item_infos.updated_at DESC,pcb_item_infos.pcb_order_no DESC")
            render "pcb_list.html.erb" and return
        end
        if params[:undone]
            where_state = " AND pcb_order_items.state = ''"
            @part = PcbOrderItem.find_by_sql("SELECT pcb_order_items.id AS pcb_order_item_id,pcb_item_infos.id AS pcb_item_infos_id, pcb_order_items.*,pcb_item_infos.pcb_supplier,pcb_item_infos.pcb_length,pcb_item_infos.pcb_width,pcb_item_infos.pcb_thickness,pcb_item_infos.pcb_panel,pcb_item_infos.pcb_layer,pcb_item_infos.pcb_gongyi,pcb_item_infos.pcb_area,pcb_item_infos.pcb_area_price,pcb_item_infos.eng_price,pcb_item_infos.test_price,pcb_item_infos.m_price FROM pcb_order_items LEFT JOIN pcb_item_infos ON pcb_order_items.id = pcb_item_infos.pcb_order_item_id WHERE pcb_order_items.p_type = 'pcb' #{where_state} ORDER BY pcb_item_infos.pcb_order_no DESC,pcb_order_items.updated_at DESC")
        end
        if params[:key_order]
            where_state = where_state + " AND pcb_order_items.pcb_order_no LIKE '%#{params[:key_order]}%'"
            @part = PcbOrderItem.find_by_sql("SELECT pcb_order_items.id AS pcb_order_item_id,pcb_item_infos.id AS pcb_item_infos_id, pcb_order_items.*,pcb_item_infos.pcb_supplier,pcb_item_infos.pcb_length,pcb_item_infos.pcb_width,pcb_item_infos.pcb_thickness,pcb_item_infos.pcb_panel,pcb_item_infos.pcb_layer,pcb_item_infos.pcb_gongyi,pcb_item_infos.pcb_area,pcb_item_infos.pcb_area_price,pcb_item_infos.eng_price,pcb_item_infos.test_price,pcb_item_infos.m_price FROM pcb_order_items LEFT JOIN pcb_item_infos ON pcb_order_items.id = pcb_item_infos.pcb_order_item_id WHERE pcb_order_items.p_type = 'pcb' #{where_state} ORDER BY pcb_item_infos.pcb_order_no DESC,pcb_item_infos.updated_at DESC")
        end
        
    end

    def copy_pcb_item_info
        find_data = PcbItemInfo.find_by_id(params[:id])
        if not find_data.blank?
            copy_data = PcbItemInfo.new
            copy_data.pcb_order_item_id = find_data.pcb_order_item_id
            copy_data.pcb_supplier =  find_data.pcb_supplier
            copy_data.pcb_order_no = find_data.pcb_order_no
            copy_data.sell = find_data.sell
            copy_data.pcb_length = find_data.pcb_length
            copy_data.pcb_width = find_data.pcb_width
            copy_data.pcb_thickness = find_data.pcb_thickness
            copy_data.pcb_panel = find_data.pcb_panel
            copy_data.pcb_layer = find_data.pcb_layer
            copy_data.pcb_gongyi = find_data.pcb_gongyi
            copy_data.save
        end
        redirect_to :back
    end

    def pcb_info_update
        @pcb_info_id = ''
        pcb_info_find = PcbItemInfo.find_by_id(params[:pcb_item_infos_id])
        if not pcb_info_find.blank?
            @pcb_info = pcb_info_find
            
        else
            @pcb_info = PcbItemInfo.new
        end
        @pcb_info.pcb_order_item_id = params[:part_id]
        @pcb_info.pcb_supplier = params[:pcb_dn]
        @pcb_info.pcb_order_no = params[:pcb_order_no]
        @pcb_info.sell = params[:pcb_sell]
        @pcb_info.pcb_length = params[:pcb_length]  
        @pcb_info.pcb_width = params[:pcb_width]
        @pcb_info.pcb_thickness = params[:pcb_thickness]
        @pcb_info.pcb_panel = params[:pcb_panel]
        @pcb_info.pcb_layer = params[:pcb_layer]
        @pcb_info.pcb_gongyi = params[:pcb_gongyi]
        @pcb_info.qty = params[:pcb_qty]
        @pcb_info.pcb_area = BigDecimal.new(params[:pcb_length].to_i*params[:pcb_width].to_i)/1000000/params[:pcb_panel].to_i*params[:pcb_qty].to_i
        if not params[:pcb_area_price].blank?
            @pcb_info.pcb_area_price = params[:pcb_area_price]
        end
        @pcb_info.price = BigDecimal.new(params[:pcb_length].to_i*params[:pcb_width].to_i)/1000000/params[:pcb_panel].to_i*params[:pcb_area_price].to_i
        if not params[:eng_price].blank?
            @pcb_info.eng_price = params[:eng_price].to_i
        end
        if not params[:test_price].blank?
            @pcb_info.test_price = params[:test_price].to_i
        end
        if not params[:mould_price].blank?
            @pcb_info.m_price = params[:mould_price].to_i
        end
        #@pcb_info.t_p = BigDecimal.new(params[:pcb_length].to_i*params[:pcb_width].to_i)/1000000*params[:pcb_panel].to_i*params[:pcb_area_price].to_i*params[:pcb_qty].to_i + params[:eng_price].to_i + params[:test_price].to_i + params[:mould_price].to_i
        @pcb_info.t_p = @pcb_info.price*params[:pcb_qty].to_i + params[:eng_price].to_i + params[:test_price].to_i + params[:mould_price].to_i
        @pcb_info.remark = params[:pcb_remark]
        @pcb_info.save
        @pcb_info_id = @pcb_info.id
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww@pcb_info")
        Rails.logger.info(@pcb_info.pcb_area)
        Rails.logger.info(@pcb_info.price)
        Rails.logger.info(@pcb_info.t_p)
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww@pcb_info")
        @pcb_order_item_find = PcbOrderItem.find_by_id(@pcb_info.pcb_order_item_id)
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww@pcb_order_item_find.t_p")
        Rails.logger.info(@pcb_order_item_find.t_p)
        Rails.logger.info("pcb_order_no_color_" + @pcb_order_item_find.id.to_s + "_" + @pcb_info_id.to_s)
        Rails.logger.info("pcb_area_" + @pcb_order_item_find.id.to_s + "_" + @pcb_info_id.to_s)
        Rails.logger.info("pcb_price_" + @pcb_order_item_find.id.to_s + "_" + @pcb_info_id.to_s)
        Rails.logger.info("pcb_t_p_" + @pcb_order_item_find.id.to_s + "_" + @pcb_info_id.to_s)
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww@pcb_order_item_find.t_p")
        Rails.logger.info("pcb_item_infos_id_"+@pcb_info.pcb_order_item_id.to_s)
        Rails.logger.info(@pcb_info_id.to_s)
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww@pcb_order_item_find.t_p")
        @pcb_order_item_find.t_p = @pcb_info.t_p
        @pcb_order_item_find.price = @pcb_info.price
        @pcb_order_item_find.bom_id = @pcb_info.id
        @pcb_order_item_find.state = "quotechked"
        @pcb_order_item_find.save

        check_state = PcbOrderItem.where("pcb_order_id = '#{@pcb_order_item_find.pcb_order_id}' AND (state = '' OR state = 'quote')")
        if check_state.blank?
            set_erp_order_state = PcbOrder.find_by_id(@pcb_order_item_find.pcb_order_id)
            set_erp_order_state.state = "quotechk"
            set_erp_order_state.save
        end

        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        Rails.logger.info("pcb_price_"+ @pcb_order_item_find.id.to_s + "_" + @pcb_info_id.to_s)
        Rails.logger.info(@pcb_info.pcb_order_item_id)
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")

        redirect_to :back
    end

    def com_part_list
        @part = PcbOrderItem.where("p_type = 'COMPONENTS'").paginate(:page => params[:page], :per_page => 15)
    end

    def edit_com_price
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        Rails.logger.info(params["#{params[:itemid]}p"].inspect)
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        @itemid = params[:itemid]
        @pitem = PcbOrderItem.find(params[:itemid])
        if params["#{params[:itemid]}p"] != "" 
            @pitem.price = params["#{params[:itemid]}p"]         
            @pitem.p_remark = params[:p_remark]
            @pitem.state = "quotechked"
            @pitem.save
            check_state = PcbOrderItem.where(pcb_order_no: @pitem.pcb_order_no,state: nil)
            if check_state.blank?
                set_erp_order_state = PcbOrder.find_by_order_no(@pitem.pcb_order_no)
                set_erp_order_state.state = "quotechk"
                set_erp_order_state.save
            end
        end     
        #render "p_edit_supplier_dn.js.erb"
    end

    def add_dn
        add_dn = AllDn.new()
        add_dn.date = Time.new()
        add_dn.dn = params[:sd_name]
        add_dn.dn_long = params[:sd_name_long]
        add_dn.part_code = params[:part_code]
        add_dn.des = params[:des]
        add_dn.qty = params[:qty]
        add_dn.price = params[:price]
        add_dn.save
        redirect_to :back
    end

    def moko_part_data
        @all_dn = "[&quot;"
        all_s_dn = AllDn.find_by_sql("SELECT DISTINCT all_dns.dn_long FROM all_dns GROUP BY all_dns.dn_long")
        all_s_dn.each do |dn|
            @all_dn += "&quot;,&quot;" + dn.dn_long.to_s
        end
        @all_dn += "&quot;]"
        if can? :work_baojia, :all
            where_des = ""
            if not params[:des].blank? 
                @des = params[:des]
                des = params[:des].strip.split(" ")
                des.each_with_index do |de,index|
                    where_des += "all_dns.des LIKE '%#{de}%'"
                    if des.size > (index + 1)
                        where_des += " AND "
                    end
                end 
                sort_by = "all_dns.date"
                if params[:sort_by] == "qty"
                    sort_by = "all_dns.qty"
                elsif params[:sort_by] == "date"
                    sort_by = "all_dns.date"
                end
                
                if params[:order_by] == "DESC"
                    @order_by = "ASC"
                else
                    @order_by = "DESC"
                end
                @parts = AllDn.find_by_sql("SELECT * FROM `all_dns` WHERE #{where_des} ORDER BY #{sort_by} #{@order_by}").paginate(:page => params[:page], :per_page => 15)
            #else
                #where_des = "all_dns.des LIKE '%%'"
                #@parts = AllDn.find_by_sql("SELECT * FROM `all_dns` WHERE #{where_des} ORDER BY all_dns.date DESC").paginate(:page => params[:page], :per_page => 10)
            end     

            render "moko_part_data.html.erb" and return
        else
            render plain: "You don't have permission to view this page !"
        end             
    end

    def update_p_data
        ProductsUItem.all.each do |new_data|
=begin            
            old_data = Product.find_by(name: new_data.name)
            if not old_data.blank?
                Rails.logger.info("add-------------------------------------12")
                Rails.logger.info(new_data.id.inspect)
                Rails.logger.info("add-------------------------------------12")
                old_data.description = new_data.description
                old_data.save
            end

            if old_data.blank?
                Rails.logger.info("add-------------------------------------12")
                Rails.logger.info(new_data.id.inspect)
                Rails.logger.info("add-------------------------------------12")
                old_data_new = Product.new()
                old_data_new.name = new_data.name
                old_data_new.description = new_data.description
                old_data_new.part_name = new_data.part_name
                if Product.where("description LIKE '%#{new_data.value1}%'").blank?
                    old_data_new.ptype = "other"
                else
                    old_data_new.ptype = Product.where("description LIKE '%#{new_data.value1}%'").first.ptype
                end
                old_data_new.package1 = new_data.package1
                old_data_new.package2 = new_data.package2
                old_data_new.value1 = new_data.value1
                old_data_new.value2 = new_data.value2
                old_data_new.value3 = new_data.value3
                old_data_new.value4 = new_data.value4
                old_data_new.value5 = new_data.value5
                old_data_new.value6 = new_data.value6
                old_data_new.value7 = new_data.value7
                old_data_new.value8 = new_data.value8
                old_data_new.save
            end
=end
        end
        redirect_to procurement_new_path()
    end

    def other_baojia_clean
        PItem.where(user_do: '9999').update_all "user_do = 10000"
        redirect_to other_baojia_path()
    end

    def other_baojia_up
        @bom = OtherBaojiaBom.new(other_baojia_params)#使用页面传进来的文件名字作为参数创建一个bom对象
        @bom.user_id = current_user.id
        @bom.bom_eng_up = current_user.full_name
        @file = @bom.excel_file_identifier
        #如果上传成功
	if @bom.save


            if @bom.excel_file.current_path.split('.')[-1] == 'xls'
                begin
	            @xls_file = Roo::Excel.new(@bom.excel_file.current_path)
                rescue
                  
                    redirect_to other_baojia_path(),  notice: "EXCEL文件错误!!!！"
                    return false
                end
            else
                redirect_to other_baojia_path(),  notice: "EXCEL文件错误!！"
                return false

            end
            @sheet = @xls_file.sheet(0)

	    @parse_result = @sheet.parse(header_search: [/MOKO_ID/,/MPN/,/描述/,/数量/,/报价/,/备注/,/供应商简称/,/供应商全称/],clean:true)

	    #remove first row 
	    @parse_result.shift
	    @parse_result.select! {|item| !item["报价"].blank? } #选择非空行
            #行号
            row_num = 0
	    @parse_result.each do |item| #处理每一行的数据
                other_baojia = PDn.new()
                other_baojia.email = current_user.email
                other_baojia.p_item_id = item["MOKO_ID"]
                other_baojia.date = Time.new
	        #other_baojia.part_code = item["Ref"]
		#other_baojia.desc = item["描述"]
	        other_baojia.qty = item["数量"]
                other_baojia.cost = item["报价"]
                other_baojia.remark = item["备注"]
                other_baojia.dn = item["供应商简称"]
                other_baojia.dn_long = item["供应商全称"]
                other_baojia.color = "y"
		if other_baojia.save
                    other_item = PItem.find(item["MOKO_ID"])
                    other_item.user_do = 10000
                    other_item.save
                    #Rails.logger.info(bom_item.part_code.inspect) 
                    Rails.logger.info("bom item save -------------------------------------------------bom item save")
                else
                    #Rails.logger.info(bom_item.part_code.inspect) 
                    Rails.logger.info("bom item bad -------------------------------------------------bom item bad")
                end
				
	    end
			


            redirect_to other_baojia_path()
            return false
        end 
        redirect_to other_baojia_path()
    end

    def other_baojia_out
        if can? :work_g, :all
            @bom = PItem.where(user_do: '9999',supplier_tag: nil)

            file_name = "other_out.xls"
            path = Rails.root.to_s+"/public/uploads/bom/excel_file/"


                Spreadsheet.client_encoding = 'UTF-8'
		ff = Spreadsheet::Workbook.new

		sheet1 = ff.create_worksheet

		#sheet1.row(0).concat %w{No 描述 报价 技术资料}
                all_title = []
                all_title << "MOKO_ID"
                all_title << "MPN"
                all_title << "描述"
                all_title << "数量"
                all_title << "报价"
                all_title << "备注"
                all_title << "供应商简称"
                all_title << "供应商全称"
                sheet1.row(0).concat all_title
                #sheet1.column(1).width = 50
                set_color = 0  
                while set_color < all_title.size do         
                    sheet1.row(0).set_format(set_color,ColorFormat.new(:gray,:white))
                    if all_title[set_color] =~ /数量/i 
                        sheet1.column(set_color).width = 8
                    elsif all_title[set_color] =~ /报价/i
                        sheet1.column(set_color).width = 8
                    elsif all_title[set_color] =~ /描述/i
                        sheet1.column(set_color).width = 35  
                    elsif all_title[set_color] =~ /MPN/i
                        sheet1.column(set_color).width = 20                   
                    else
                        sheet1.column(set_color).width = 15
                    end
                    set_color += 1
                end
		@bom.each_with_index do |item,index| 
		    rowNum = index+1
                    title_format = Spreadsheet::Format.new({
                    :text_wrap => 1,:size => 8
                    })
		    row = sheet1.row(rowNum)
                    row.set_format(2,title_format)
                    set_f = 0  
                    while set_f < all_title.size do         
                        row.set_format(set_f,title_format)
                        set_f += 1
                    end
                    row.push(item.id)
                    row.push(item.mpn)
		    row.push(item.description)
                    row.push(item.quantity * ProcurementBom.find(item.procurement_bom_id).qty)
                    if not PDn.find_by(p_item_id: item.id,color: "y").blank?
                        row.push(PDn.where(p_item_id: item.id,color: "y",state: "").last!.cost)
                    else
                        row.push("")
                    end
                end

                #file_contents = StringIO.new
	        #ff.write (file_contents)
	        #send_data(file_contents.string.force_encoding('UTF-8'), filename: file_name)
                              
                ff.write (path+file_name)              
                send_file(path+file_name, type: "application/vnd.ms-excel") and return
        else
            render plain: "You don't have permission to view this page !"
        end
    end

    def other_baojia
        if params[:sort_date] == "mpn"
            add_orderby = "p_items.mpn DESC"
        elsif params[:sort_date] == "des"
            add_orderby = "p_items.description DESC"
        end
        if params[:complete]
            part_ctl = " AND p_items.color = 'b'" 
        else
            part_ctl = " AND (p_items.color <> 'b' OR p_items.color IS NULL)"
        end
        @pdn = PDn.new
        #@mpninfo = "SP1007-01WTG"
        #@mpninfo = Digikey.find(1)   
        Rails.logger.info("--------------------------")
        #Rails.logger.info(wcwc)
        Rails.logger.info("--------------------------")  
        @all_dn = "[&quot;"
        all_s_dn = AllDn.find_by_sql("SELECT DISTINCT all_dns.dn FROM all_dns GROUP BY all_dns.dn")
        all_s_dn.each do |dn|
            @all_dn += "&quot;,&quot;" + dn.dn.to_s
        end
        @all_dn += "&quot;]"
        #@boms = ProcurementBom.find(params[:bom_id])
        if params[:key_order]
            key = " AND procurement_boms.p_name LIKE '%#{params[:key_order]}%'"
            #key_des = " AND p_items.description LIKE '%#{params[:key_order]}%'"
            des = params[:key_order].strip.split(" ")
            key_des = ""
            des.each_with_index do |de,index|
                key_des += " AND p_items.description LIKE '%#{de}%'"
            end      
            part_ctl = ""
            @key_order = params[:key_order]
        end
        if can? :work_g, :all
            @user_do = "7"
            #@bom_item = PItem.where(user_do: "7")
            @bom_item = PItem.joins("JOIN procurement_boms ON procurement_boms.id = p_items.procurement_bom_id").where("p_items.user_do > '9998' AND quantity <> 0 AND procurement_boms.bom_team_ck = 'do' #{part_ctl} #{key}").order(add_orderby).paginate(:page => params[:page], :per_page => 15)
            if @bom_item.blank?
                @bom_item = PItem.joins("JOIN procurement_boms ON procurement_boms.id = p_items.procurement_bom_id").where("p_items.user_do > '9998' AND quantity <> 0 AND procurement_boms.bom_team_ck = 'do' #{part_ctl} #{key_des}").order(add_orderby).paginate(:page => params[:page], :per_page => 15)
            end
        
        end
    end

    def sd_flow
        @flow = SupplierDList.find(params[:sd_id])
        if @flow.state == ""
            @flow.state = "check"
            oauth = Oauth.find(1)
            company_id = oauth.company_id
            company_token = oauth.company_token
            url = 'https://openapi.b.qq.com/api/tips/send' 
            url += '?company_id='+company_id
            url += '&company_token='+company_token
            url += '&app_id=200710667'
            url += '&client_ip=120.25.151.208'
            url += '&oauth_version=2'
            url += '&to_all=0'  
            url += '&receivers=6ab2628d9a320296032f6a6f5495582b'                            
            url += '&window_title=Fastbom-PCB AND PCBA'
            url += '&tips_title='+URI.encode('供应商扣款需要审核')
            url += '&tips_content='+URI.encode('马风华 宝宝你有一个供应商扣款需要审核，点击查看。')
            url += '&tips_url=erp.fastbom.com/supplier_d_list'
            resp = Net::HTTP.get_response(URI(url)) 
        elsif @flow.state == "check"
            @flow.state = "checked"
            @flow.back = "" 
            oauth = Oauth.find(1)
            company_id = oauth.company_id
            company_token = oauth.company_token
            url = 'https://openapi.b.qq.com/api/tips/send' 
            url += '?company_id='+company_id
            url += '&company_token='+company_token
            url += '&app_id=200710667'
            url += '&client_ip=120.25.151.208'
            url += '&oauth_version=2'
            url += '&to_all=0'  
            url += '&receivers=3f524f1d9f3baa7bd7894cce35ae5f39'
            url += '&window_title=Fastbom-PCB AND PCBA'
            url += '&tips_title='+URI.encode('供应商扣款需要确认')
            url += '&tips_content='+URI.encode('王萍 宝宝你有一个供应商扣款需要确认，点击查看。')
            url += '&tips_url=erp.fastbom.com/supplier_d_list'
            resp = Net::HTTP.get_response(URI(url)) 
        elsif @flow.state == "checked"
            @flow.state = "done"
            @flow.back = "" 
        end
        @flow.save
        redirect_to :back
    end

    def sd_back
        @flow = SupplierDList.find(params[:sd_id])
        if @flow.state == "check"
            @flow.state = "" 
            @flow.back = "fail"  
        end
        @flow.save
        oauth = Oauth.find(1)
        company_id = oauth.company_id
        company_token = oauth.company_token
        url = 'https://openapi.b.qq.com/api/tips/send'
        url += '?company_id='+company_id
        url += '&company_token='+company_token
        url += '&app_id=200710667'
        url += '&client_ip=120.25.151.208'
        url += '&oauth_version=2'
        url += '&to_all=0'  
        url += '&receivers=77844aaffe24c9e4e6f1b2d851fc44cb'
        url += '&window_title=Fastbom-PCB AND PCBA'
        url += '&tips_title='+URI.encode('供应商扣款需要确认')
        url += '&tips_content='+URI.encode('邓友素 宝宝你有一个供应商扣款被马风华宝宝退回，点击查看。')
        url += '&tips_url=erp.fastbom.com/supplier_d_list'
        resp = Net::HTTP.get_response(URI(url))
        redirect_to :back
    end

    def supplier_d_list
        where_sd = "aaaaa" 
        user_id = current_user.id
        if (user_id==34)
            where_sd = "" 
        elsif (user_id==7)
            where_sd = "check" 
        elsif (user_id == 112)
            where_sd = "checked"
        end

        if (user_id == 6)
            @data_all = SupplierDList.all.paginate(:page => params[:page], :per_page => 15)
        else
            @data_all = SupplierDList.where(state: "#{where_sd}").paginate(:page => params[:page], :per_page => 15)
        end
        @all_dn = "[&quot;"
        all_s_dn = AllDn.find_by_sql("SELECT DISTINCT all_dns.dn_long FROM all_dns GROUP BY all_dns.dn_long")
        all_s_dn.each do |dn|
            @all_dn += "&quot;,&quot;" + dn.dn_long.to_s
        end
        @all_dn += "&quot;]"
    end

    def add_sd
        new_sd = SupplierDList.new
        new_sd.dn_name = AllDn.find(params[:sd_id]).dn
        new_sd.dn_all_name = AllDn.find(params[:sd_id]).dn_long
        new_sd.money = params[:sd_money]
        new_sd.remark = params[:sd_remark]
        new_sd.save
        redirect_to :back
    end

    def update_sd
        new_sd = SupplierDList.find(params[:sd_id])
        new_sd.dn_name = AllDn.find(params[:sd_dn_id]).dn
        new_sd.dn_all_name = AllDn.find(params[:sd_dn_id]).dn_long
        new_sd.money = params[:sd_money]
        new_sd.remark = params[:sd_remark]
        new_sd.save
        redirect_to :back
    end

    def find_sd
        if params[:sd_update]
            @sd_update = true
        end
        if params[:c_code] != ""
            @c_info = AllDn.find_by(dn_long: params[:c_code])
            Rails.logger.info("add-------------------------------------12")
            Rails.logger.info(@c_info.inspect)
            Rails.logger.info("add-------------------------------------12")
            if not @c_info.blank?
                 Rails.logger.info("add-------------------------------------12")
                @c_table = '<br>'
                @c_table += '<small>'
                @c_table += '<table class="table table-bordered">'
                @c_table += '<thead>'
                @c_table += '<tr class="active">'
                @c_table += '<th width="200">供应商代码</th>'
                @c_table += '<th>供应商全称</th>'             
                @c_table += '<tr>'
                @c_table += '</thead>'
                @c_table += '<tbody>'
                @c_table += '<tr>'
                @c_table += '<td>' + @c_info.dn + '</td>'
                @c_table += '<td>' + @c_info.dn_long + '</td>'
                @c_table += '</tr>'
                @c_table += '</tbody>'
                @c_table += '</table>'
                @c_table += '</small>'
                Rails.logger.info("add-------------------------------------12")
                Rails.logger.info(@c_table.inspect)
                Rails.logger.info("add-------------------------------------12")
            end
        end
    end


    def p_excel_add
        @bom = ProcurementBom.find(params[:bom_id])
        #Rails.logger.info("----------------------------------------------------------------a1")
        file_name = @bom.p_name.to_s+".xls"
        path = Rails.root.to_s+"/public/uploads/bom/excel_file/"
        col_use = @bom.all_title.split("|").size
        row_use = @bom.row_use
        #Rails.logger.info("----------------------------------------------------------------a2")
        book = Spreadsheet.open @bom.excel_file.current_path
        sheet = book.worksheet 0
        col_i = col_use
        #Rails.logger.info("----------------------------------------------------------------a3")
        sheet.rows[row_use.to_i - 1][col_i.to_i] = "MPN"
        sheet.column(col_i.to_i).width =20  
        col_i += 1
        #Rails.logger.info("----------------------------------------------------------------a4")
        sheet.rows[row_use.to_i - 1][col_i.to_i] = "MOKO物料名称"
        sheet.column(col_i.to_i).width =15
        col_i += 1
        #Rails.logger.info("----------------------------------------------------------------a5")
        sheet.rows[row_use.to_i - 1][col_i.to_i] = "MOKO物料描述"
        sheet.column(col_i.to_i).width =35 
        col_i += 1
        #Rails.logger.info("----------------------------------------------------------------a6")
        sheet.rows[row_use.to_i - 1][col_i.to_i] = "成本价￥"
        sheet.column(col_i.to_i).width =8 
        col_i += 1
        #Rails.logger.info("----------------------------------------------------------------a7")
        sheet.rows[row_use.to_i - 1][col_i.to_i] = "报价￥"
        sheet.column(col_i.to_i).width =8
        col_i += 1
        #Rails.logger.info("----------------------------------------------------------------a8")
        sheet.rows[row_use.to_i - 1][col_i.to_i] = "备注1"
        col_i += 1
        #Rails.logger.info("----------------------------------------------------------------a9")
        sheet.rows[row_use.to_i - 1][col_i.to_i] = "备注2"
        col_i += 1
        #Rails.logger.info("----------------------------------------------------------------a10")
        sheet.rows[row_use.to_i - 1][col_i.to_i] = "总数量#{@bom.qty}"
        col_i += 1
        row_i = row_use
        #Rails.logger.info("----------------------------------------------------------------a11")
        #c_i = col_use
        #PItem.where("procurement_bom_id = #{params[:bom_id]}  AND quantity <> 0").each do |item|
        PItem.where(procurement_bom_id: params[:bom_id]).each do |item|
            if item.quantity == 0
                row_i += 1
            else
                #Rails.logger.info("----------------------------------------------------------------ggga")
                c_i = col_use
                sheet.rows[row_i.to_i][c_i.to_i] = item.mpn
                c_i += 1
                if item.product_id != 0 and item.product_id != nil
                    sheet.rows[row_i.to_i][c_i.to_i] = Product.find(item.product_id).name
                    c_i += 1
                    sheet.rows[row_i.to_i][c_i.to_i] = Product.find(item.product_id).description
                    c_i += 1
                else
                    #sheet.rows[row_i.to_i][c_i.to_i] = ""
                    c_i += 1
                    #sheet.rows[row_i.to_i][c_i.to_i] = ""
                    c_i += 1
                end
                #Rails.logger.info("----------------------------------------------------------------gggb")
                sheet.rows[row_i.to_i][c_i.to_i] = item.cost
                c_i += 1
                sheet.rows[row_i.to_i][c_i.to_i] = item.price
                c_i += 1
                if item.dn_id.blank?
                    #sheet.rows[row_i.to_i][c_i.to_i] = ""
                    c_i += 1
                else
                    #Rails.logger.info("----------------------------------------------------------------gggc")
                    begin
                        if PDn.find(item.dn_id).remark.blank?
                            #sheet.rows[row_i.to_i][c_i.to_i] = ""
                            c_i += 1
                        else
                            sheet.rows[row_i.to_i][c_i.to_i] = PDn.find(item.dn_id).remark
                            c_i += 1
                        end
                    rescue
                        #sheet.rows[row_i.to_i][c_i.to_i] = ""
                        c_i += 1
                    end
                end
                #Rails.logger.info("----------------------------------------------------------------ggg1")
                if PItemRemark.where(p_item_id: item.id).blank?
                    #Rails.logger.info("----------------------------------------------------------------ggg2")
                    #sheet.rows[row_i.to_i][c_i.to_i] = ""
                    c_i += 1
                else
                    allitem_remark = ""
                    #Rails.logger.info("----------------------------------------------------------------ggg3")
                    PItemRemark.where(p_item_id: item.id).each do |remark_i|
                        allitem_remark += "【#{remark_i.user_name}】:#{remark_i.remark}\n\r"
                    end
                    sheet.rows[row_i.to_i][c_i.to_i] = allitem_remark
                    c_i += 1
                end
                #Rails.logger.info("----------------------------------------------------------------ggg4")
                if not item.dn_id.blank?
                    #Rails.logger.info("----------------------------------------------------------------ggg5")
                    begin
                        if not PDn.find(item.dn_id).info_url.blank?
                            #Rails.logger.info("----------------------------------------------------------------ggg6")
                            link_dn = request.protocol + request.host_with_port + PDn.find(item.dn_id).info_url
                            #Rails.logger.info("----------------------------------------------------------------ggg7")
                        #Rails.logger.info("----------------------------------------------------------------link_dn")
                        #Rails.logger.info(link_dn.inspect)
                        #Rails.logger.info("----------------------------------------------------------------link_dn")
                        #sheet.rows[row_i.to_i][c_i.to_i] = Spreadsheet::Link.new link_dn, '技术资料'
                        #sheet[row_i.to_i,c_i.to_i] = Spreadsheet::Link.new 'erp.fastbom.com', '技术资料'
                        #c_i += 1
                            sheet.rows[row_i.to_i][c_i.to_i] = link_dn
                            c_i += 1
                            #Rails.logger.info("----------------------------------------------------------------ggg8")
                        else
                            #sheet.rows[row_i.to_i][c_i.to_i] = ""
                            c_i += 1
                            #Rails.logger.info("----------------------------------------------------------------ggg9")
                        end
                    rescue
                        #sheet.rows[row_i.to_i][c_i.to_i] = ""
                        c_i += 1
                        #Rails.logger.info("----------------------------------------------------------------ggg10")
                    end
                else
                    #Rails.logger.info("----------------------------------------------------------------ggg11")
                    #sheet.rows[row_i.to_i][c_i.to_i] = ""
                    c_i += 1
                end		
                row_i += 1
            end
        end
        #Rails.logger.info("----------------------------------------------------------------ggg12")
        book.write path+file_name
        #Rails.logger.info("----------------------------------------------------------------ggg13")
        send_file(path+file_name, type: "application/vnd.ms-excel")

=begin


        file_name = @bom.no.to_s+"_out.xls"
        path = Rails.root.to_s+"/public/uploads/bom/excel_file/"
        #Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        #Rails.logger.info(file_name.inspect)
        #Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")

                Spreadsheet.client_encoding = 'UTF-8'
		ff = Spreadsheet::Workbook.new

		sheet1 = ff.create_worksheet

		#sheet1.row(0).concat %w{No 描述 报价 技术资料}
                all_title = @bom.all_title.split("|",-1)
                all_title << "MPN"
                all_title << "MOKO物料名称"
                all_title << "MOKO物料描述"
                all_title << "成本价"
                all_title << "报价"
                all_title << "备注"
                sheet1.row(0).concat all_title
                #sheet1.column(1).width = 50
                set_color = 0  
                while set_color < all_title.size do         
                    sheet1.row(0).set_format(set_color,ColorFormat.new(:gray,:white))
                    if all_title[set_color] =~ /Quantity/i or all_title[set_color] =~ /qty/i
                        sheet1.column(set_color).width = 8
                    elsif all_title[set_color] =~ /成本价/i or all_title[set_color] =~ /报价/i
                        sheet1.column(set_color).width = 8
                    elsif all_title[set_color] =~ /MOKO物料描述/i
                        sheet1.column(set_color).width = 35
                    elsif all_title[set_color] =~ /part/i
                        sheet1.column(set_color).width = 22
                    else
                        sheet1.column(set_color).width = 15
                    end
                    set_color += 1
                end
		@bom.p_items.each_with_index do |item,index|
		    rowNum = index+1
                    title_format = Spreadsheet::Format.new({
                    :text_wrap => 1,:size => 8
                    })
		    row = sheet1.row(rowNum)
                    row.set_format(2,title_format)
                    set_f = 0  
                    while set_f < all_title.size do         
                        row.set_format(set_f,title_format)
                        set_f += 1
                    end
                    #if item.warn
                        #[0,1,2,3,4,5,6,7].each{|col|
                        #row.set_format(2,title_format)
                        #row.default_format = color
                        #}
                    #end
                    
                    item.all_info.split("|",-1).each do |info|
                        row.push(info.to_s)
                    end
		    #row.push(rowNum)
		    #row.push(item.description)
		    #row.push(item.quantity)
                    row.push("#{item.mpn}")
                    if item.product_id != 0 and item.product_id != nil
                        row.push(Product.find(item.product_id).name)
                        row.push(Product.find(item.product_id).description)
                    else
                        row.push("")
                        row.push("")
                    end
                    if can? :work_d, :all
                        row.push(" ")
                        row.push(" ")
                    else
                        row.push("￥#{item.cost}")
                        row.push("￥#{item.price}")
                    end
                    if item.dn_id.blank?
                        row.push("")
                    else
                        begin
                            if PDn.find(item.dn_id).remark.blank?
                                row.push("")
                            else
                                row.push(PDn.find(item.dn_id).remark)
                            end
                        rescue
                            row.push("")
                        end
                    end
                    Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                    Rails.logger.info(item.all_info.inspect)
                    Rails.logger.info(item.all_info.split("|",-1).inspect)
                    Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                    if not item.dn_id.blank?
                        Rails.logger.info("111111111111111")
                        #Rails.logger.info(request.protocol)
                        #Rails.logger.info(request.host_with_port)
                        #Rails.logger.info(PDn.find(item.dn_id).info_url.inspect)
                        #Rails.logger.info("111111111111111")
                        begin
                            if not PDn.find(item.dn_id).info_url.blank?
                                #row.push(request.protocol + request.host_with_port + PDn.find(item.dn_id).info_url)
                                row.push(Spreadsheet::Link.new request.protocol + request.host_with_port + PDn.find(item.dn_id).info_url, '技术资料')
                            else
                                row.push("")
                            end
                        rescue
                            row.push("")
                        end
                    else
                        row.push("")
                    end		 
                end

                #file_contents = StringIO.new
	        #ff.write (file_contents)
	        #send_data(file_contents.string.force_encoding('UTF-8'), filename: file_name)
                              
                ff.write (path+file_name)              
                send_file(path+file_name, type: "application/vnd.ms-excel")
                #send_file(path,filename: file_name, type: "application/vnd.ms-excel")   
=end 
    end


    def p_item_remark_up
        @item_id = params[:itemp_id]
        if not params[:bom_version].blank?        
            remarkold = PVersionItemRemark.find(params[:remark_id])
        else
            remarkold = PItemRemark.find(params[:remark_id])
        end
        remarkold.state = "del"
        remarkold.save
        if not params[:bom_version].blank?
            remark = PVersionItemRemark.new
        else
            remark = PItemRemark.new
        end
        remark.p_item_id = params[:itemp_id]
        remark.user_id = current_user.id
        remark.user_name = current_user.full_name
        if can? :work_e, :all
            remark.user_team = "sell"
        elsif can? :work_d, :all
            remark.user_team = "bom"
        elsif can? :work_g, :all
            remark.user_team = "procurement"
        end
        remark.remark = params[:item_remark].chomp.gsub(/\r\n/, " ")
        remark.save
        @remark_all = ""
        if not params[:bom_version].blank?
            PVersionItemRemark.where(p_item_id: @item_id).each do |remark_item|
                @remark_all += '<div class="row" style="margin: 0px;" >'
                @remark_all += '<div class="col-md-12 " style="margin: 0px;padding: 0px;background-color: #fcf8e3;">'
                @remark_all += '<table style="margin: 0px;" >'
                @remark_all += '<tr>'
                @remark_all += '<td style="padding: 0px;margin: 0px;" >'
                @remark_all += '<p style="padding: 0px;margin: 0px;" ><small >'
                @remark_all += '<a class="glyphicon glyphicon-remove" data-method="get" data-remote="true" href="/p_item_remark_del?itemp_id=' + @item_id.to_s + '&remark_id=' + remark_item.id.to_s + '&bom_version=' + params[:bom_version].to_s + '" data-confirm="确定要删除?"> </a>'
                @remark_all += '<a type="button" class="glyphicon glyphicon-edit" data-toggle="modal" data-target="#remarkupdate" data-itempid="'+@item_id+'" data-remark_id="' + remark_item.id.to_s + '" data-remark="' + remark_item.remark.to_s + '" > </a><strong>' + remark_item.user_name.to_s + ': </strong>' 
                @remark_all += '<strong>' + remark_item.updated_at.localtime.strftime('%Y-%m-%d %H:%M:%S').to_s + '</strong>'
                if remark_item.state == "del"
                    @remark_all +=  '<del>' + remark_item.remark.to_s + '</del>'
                else
                    @remark_all +=  remark_item.remark.to_s
                end
                @remark_all += '</small></p>'
                @remark_all += '</td>'
                @remark_all += '</tr>'
                @remark_all += '</table>'
                @remark_all += '</div>'
                @remark_all += '</div>'
            end
        else
            PItemRemark.where(p_item_id: @item_id).each do |remark_item|
                @remark_all += '<div class="row" style="margin: 0px;" >'
                @remark_all += '<div class="col-md-12 " style="margin: 0px;padding: 0px;background-color: #fcf8e3;">'
                @remark_all += '<table style="margin: 0px;" >'
                @remark_all += '<tr>'
                @remark_all += '<td style="padding: 0px;margin: 0px;" >'
                @remark_all += '<p style="padding: 0px;margin: 0px;" ><small >'
                @remark_all += '<a class="glyphicon glyphicon-remove" data-method="get" data-remote="true" href="/p_item_remark_del?itemp_id=' + @item_id.to_s + '&remark_id=' + remark_item.id.to_s + '" data-confirm="确定要删除?"> </a>'
                @remark_all += '<a type="button" class="glyphicon glyphicon-edit" data-toggle="modal" data-target="#remarkupdate" data-itempid="'+@item_id+'" data-remark_id="' + remark_item.id.to_s + '" data-remark="' + remark_item.remark.to_s + '" > </a><strong>' + remark_item.user_name.to_s + ': </strong>' 
                @remark_all += '<strong>' + remark_item.updated_at.localtime.strftime('%Y-%m-%d %H:%M:%S').to_s + '</strong>'
                if remark_item.state == "del"
                    @remark_all +=  '<del>' + remark_item.remark.to_s + '</del>'
                else
                    @remark_all +=  remark_item.remark.to_s
                end
                @remark_all += '</small></p>'
                @remark_all += '</td>'
                @remark_all += '</tr>'
                @remark_all += '</table>'
                @remark_all += '</div>'
                @remark_all += '</div>'
            end
        end
        #Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        #Rails.logger.info(@remark_all.inspect)
        #Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")

    end

    def p_item_remark_del
        @item_id = params[:itemp_id]
        if not params[:bom_version].blank?
            remarkold = PVersionItemRemark.find(params[:remark_id])
        else
            remarkold = PItemRemark.find(params[:remark_id])
        end
        remarkold.state = "del"
        remarkold.save
        @remark_all = ""
        if not params[:bom_version].blank?
            PVersionItemRemark.where(p_item_id: @item_id).each do |remark_item|
                @remark_all += '<div class="row" style="margin: 0px;" >'
                @remark_all += '<div class="col-md-12 " style="margin: 0px;padding: 0px;background-color: #fcf8e3;">'
                @remark_all += '<table style="margin: 0px;" >'
                @remark_all += '<tr>'
                @remark_all += '<td style="padding: 0px;margin: 0px;" >'
                @remark_all += '<p style="padding: 0px;margin: 0px;" ><small >'
                @remark_all += '<a class="glyphicon glyphicon-remove" data-method="get" data-remote="true" href="/p_item_remark_del?itemp_id=' + @item_id.to_s + '&remark_id=' + remark_item.id.to_s + '&bom_version=' + params[:bom_version].to_s + '" data-confirm="确定要删除?"> </a>'
                @remark_all += '<a type="button" class="glyphicon glyphicon-edit" data-toggle="modal" data-target="#remarkupdate" data-itempid="'+@item_id+'" data-remark_id="' + remark_item.id.to_s + '" data-remark="' + remark_item.remark.to_s.gsub(/'/,'') + '" > </a><strong>' + remark_item.user_name.to_s + ': </strong>' 
                @remark_all += '<strong>' + remark_item.updated_at.localtime.strftime('%Y-%m-%d %H:%M:%S').to_s + '</strong>'
                if remark_item.state == "del"
                    @remark_all +=  '<del>' + remark_item.remark.to_s.gsub(/'/,'') + '</del>'
                else
                    @remark_all +=  remark_item.remark.to_s.gsub(/'/,'')
                end
                @remark_all += '</small></p>'
                @remark_all += '</td>'
                @remark_all += '</tr>'
                @remark_all += '</table>'
                @remark_all += '</div>'
                @remark_all += '</div>'
            end
        else
            PItemRemark.where(p_item_id: @item_id).each do |remark_item|
                @remark_all += '<div class="row" style="margin: 0px;" >'
                @remark_all += '<div class="col-md-12 " style="margin: 0px;padding: 0px;background-color: #fcf8e3;">'
                @remark_all += '<table style="margin: 0px;" >'
                @remark_all += '<tr>'
                @remark_all += '<td style="padding: 0px;margin: 0px;" >'
                @remark_all += '<p style="padding: 0px;margin: 0px;" ><small >'
                @remark_all += '<a class="glyphicon glyphicon-remove" data-method="get" data-remote="true" href="/p_item_remark_del?itemp_id=' + @item_id.to_s + '&remark_id=' + remark_item.id.to_s + '" data-confirm="确定要删除?"> </a>'
                @remark_all += '<a type="button" class="glyphicon glyphicon-edit" data-toggle="modal" data-target="#remarkupdate" data-itempid="'+@item_id+'" data-remark_id="' + remark_item.id.to_s + '" data-remark="' + remark_item.remark.to_s.gsub(/'/,'') + '" > </a><strong>' + remark_item.user_name.to_s + ': </strong>' 
                @remark_all += '<strong>' + remark_item.updated_at.localtime.strftime('%Y-%m-%d %H:%M:%S').to_s + '</strong>'
                if remark_item.state == "del"
                    @remark_all +=  '<del>' + remark_item.remark.to_s.gsub(/'/,'') + '</del>'
                else
                    @remark_all +=  remark_item.remark.to_s.gsub(/'/,'')
                end
                @remark_all += '</small></p>'
                @remark_all += '</td>'
                @remark_all += '</tr>'
                @remark_all += '</table>'
                @remark_all += '</div>'
                @remark_all += '</div>'
            end
        end
        #Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        #Rails.logger.info(@remark_all.inspect)
        #Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        render "p_item_remark_up.js.erb"
    end

    def p_item_remark
        @item_id = params[:itemp_id]
        if not params[:bom_version].blank?
            remark = PVersionItemRemark.new()
        else
            remark = PItemRemark.new()
        end
        remark.p_item_id = params[:itemp_id]
        remark.user_id = current_user.id
        remark.user_name = current_user.full_name
        if not params[:dn_info].blank?
            remark.update(editbn_params)
        end
        if not params[:bom_version].blank?
            p_c = PVersionItem.find(params[:itemp_id])    
        else
            p_c = PItem.find(params[:itemp_id]) 
        end   
        if can? :work_e, :all
            remark.user_team = "sell"
            
            p_c.color = ""
            p_c.sell_feed_back_tag = "eng"
        elsif can? :work_d, :all
            remark.user_team = "bom"
            p_c.sell_feed_back_tag = "sell"           
        elsif can? :work_g, :all
            remark.user_team = "procurement"
            p_c.sell_feed_back_tag = "sell" 
        end
        p_c.save
        remark.remark = params[:item_remark].chomp.gsub(/\r\n/, " ")
        remark.save
        @remark_all = ''
        if not params[:bom_version].blank?
            PVersionItemRemark.where(p_item_id: @item_id).each do |remark_item|
                @remark_all += '<div class="row" style="margin: 0px;" >'
                @remark_all += '<div class="col-md-12 " style="margin: 0px;padding: 0px;background-color: #fcf8e3;">'
                @remark_all += '<table style="margin: 0px;" >'
                @remark_all += '<tr>'
                @remark_all += '<td style="padding: 0px;margin: 0px;" >'
                if not remark_item.info.blank?
                    @remark_all += '<a class="btn btn-info btn-xs" href="<%= remark_item.info.url %>" target="_blank">下载</a>'
                end
            
                #if params[:sell_remark] != "sell_remark"
                    #@remark_all += '<p style="padding: 0px;margin: 0px;" ><small ><a type="button" class="glyphicon glyphicon-edit" data-toggle="modal" data-target="#remarkupdate" data-itempid="'+remark_item.p_item_id.to_s+'" data-remark_id="'+remark_item.id.to_s+'" data-remark="' + remark_item.remark.to_s + '" > </a><strong>' + remark_item.user_name.to_s + ': </strong>' +  remark_item.remark.to_s + '</small></p>'
                #else
                @remark_all += '<p style="padding: 0px;margin: 0px;" ><small>'
                if remark_item.user_id == current_user.id
                    @remark_all += '<a class="glyphicon glyphicon-remove" data-method="get" data-remote="true" href="/p_item_remark_del?itemp_id=' + @item_id.to_s + '&remark_id=' + remark_item.id.to_s + '&bom_version=' + params[:bom_version].to_s + '" data-confirm="确定要删除?"></a>'
                end
                @remark_all += '<strong>' + remark_item.created_at.localtime.strftime('%Y-%m-%d %H:%M:%S').to_s + '</strong>'
                @remark_all += '<strong>' + remark_item.user_name.to_s + ': </strong>' +  remark_item.remark.to_s.gsub(/'/,'') + '</small></p>'
                #end
                @remark_all += '</td>'
                @remark_all += '</tr>'
                @remark_all += '</table>'
                @remark_all += '</div>'
                @remark_all += '</div>'
            end
        else
            PItemRemark.where(p_item_id: @item_id).each do |remark_item|
                @remark_all += '<div class="row" style="margin: 0px;" >'
                @remark_all += '<div class="col-md-12 " style="margin: 0px;padding: 0px;background-color: #fcf8e3;">'
                @remark_all += '<table style="margin: 0px;" >'
                @remark_all += '<tr>'
                @remark_all += '<td style="padding: 0px;margin: 0px;" >'
                if not remark_item.info.blank?
                    @remark_all += '<a class="btn btn-info btn-xs" href="<%= remark_item.info.url %>" target="_blank">下载</a>'
                end
            
                #if params[:sell_remark] != "sell_remark"
                    #@remark_all += '<p style="padding: 0px;margin: 0px;" ><small ><a type="button" class="glyphicon glyphicon-edit" data-toggle="modal" data-target="#remarkupdate" data-itempid="'+remark_item.p_item_id.to_s+'" data-remark_id="'+remark_item.id.to_s+'" data-remark="' + remark_item.remark.to_s + '" > </a><strong>' + remark_item.user_name.to_s + ': </strong>' +  remark_item.remark.to_s + '</small></p>'
                #else
                @remark_all += '<p style="padding: 0px;margin: 0px;" ><small>'
                if remark_item.user_id == current_user.id
                    @remark_all += '<a class="glyphicon glyphicon-remove" data-method="get" data-remote="true" href="/p_item_remark_del?itemp_id=' + @item_id.to_s + '&remark_id=' + remark_item.id.to_s + '" data-confirm="确定要删除?"></a>'
                end
                @remark_all += '<strong>' + remark_item.created_at.localtime.strftime('%Y-%m-%d %H:%M:%S').to_s + '</strong>'
                @remark_all += '<strong>' + remark_item.user_name.to_s + ': </strong>' +  remark_item.remark.to_s.gsub(/'/,'') + '</small></p>'
                #end
                @remark_all += '</td>'
                @remark_all += '</tr>'
                @remark_all += '</table>'
                @remark_all += '</div>'
                @remark_all += '</div>'
            end
        end
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        Rails.logger.info(@remark_all.inspect)
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
    end

    def remark_to_sell
        p_bom = ProcurementBom.find(params[:bom_id])
        if can? :work_send_to_sell, :all
            p_bom.remark_to_sell = "mark"
            p_bom.save
=begin
            if not p_bom.erp_item_id.blank?
                upstart = PcbOrderItem.find_by_id(p_bom.erp_item_id)
                if not upstart.blank?
                    upstart.state = "quotechked"
                    upstart.save
                end
            end
            if not p_bom.erp_no.blank?
                check_state = PcbOrderItem.where(pcb_order_no: p_bom.erp_no,state: nil)
                if check_state.blank?
                    set_erp_order_state = PcbOrder.find_by_order_no(p_bom.erp_no)
                    set_erp_order_state.state = "quotechk"
                    set_erp_order_state.save
                end
            end
=end
#设置所有使用相同bom的order为已报价
            find_order = PcbOrderItem.where(bom_id: p_bom.id)
            if not find_order.blank?
                find_order.each do |order_item|
                    order_item.state = "quotechked"
                    order_item.save
                    check_state = PcbOrderItem.where("pcb_order_id = '#{order_item.pcb_order_id}' AND (state = '' OR state = 'quote')")
                    if check_state.blank?
                        set_erp_order_state = PcbOrder.find_by_id(order_item.pcb_order_id)
                        set_erp_order_state.state = "quotechk"
                        set_erp_order_state.save
                    end
                end
            end
        end
        redirect_to :back
    end

    def part_list
        part_ctl = ""
        add_orderby = "procurement_boms.id"
        if params[:sort_date] == "mpn"
            add_orderby = "p_items.mpn DESC"
        elsif params[:sort_date] == "des"
            add_orderby = "p_items.description DESC"
        end
        if params[:complete]
            part_ctl = " AND p_items.color = 'b'" 
        else
            part_ctl = " AND (p_items.color <> 'b' OR p_items.color IS NULL)"
        end
        if params[:p_type] == "COM"
            part_ctl += " AND p_items.p_type = 'COMPONENTS'" 
        else
            part_ctl += ""
        end
        @pdn = PDn.new
        #@mpninfo = "SP1007-01WTG"
        #@mpninfo = Digikey.find(1)   
        Rails.logger.info("--------------------------")
        #Rails.logger.info(wcwc)
        Rails.logger.info("--------------------------")  
        @all_dn = "[&quot;"
        all_s_dn = AllDn.find_by_sql("SELECT DISTINCT all_dns.dn FROM all_dns GROUP BY all_dns.dn")
        all_s_dn.each do |dn|
            @all_dn += "&quot;,&quot;" + dn.dn.to_s
        end
        @all_dn += "&quot;]"
        #@boms = ProcurementBom.find(params[:bom_id])
        if params[:key_order]
            key = "procurement_boms.p_name LIKE '%#{params[:key_order]}%' OR p_items.mpn LIKE '%#{params[:key_order]}%'"
            #key_des = " AND p_items.description LIKE '%#{params[:key_order]}%'"
            des = params[:key_order].strip.split(" ")
            key_des = ""
            des.each_with_index do |de,index|
                key_des += "p_items.description LIKE '%#{de}%'"
                if des.size > (index + 1)
                    key_des += " AND "
                end
            end      

            @key_order = params[:key_order]
            where_data = " AND (#{key} OR (#{key_des}))"
        else
            where_data = ""
        end
        if can? :work_g_all, :all and can? :work_a, :all
            @user_do = "7"
            #@bom_item = PItem.where(user_do: "7")
            @bom_item = PItem.joins("JOIN procurement_boms ON procurement_boms.id = p_items.procurement_bom_id").where("quantity <> 0 AND procurement_boms.bom_team_ck = 'do' #{part_ctl} #{where_data}").order(add_orderby).paginate(:page => params[:page], :per_page => 15)
        elsif can? :work_g_all, :all
            @user_do = "7"
            #@bom_item = PItem.where(user_do: "7")
            @bom_item = PItem.joins("JOIN procurement_boms ON procurement_boms.id = p_items.procurement_bom_id").where("p_items.user_do = '7'  AND quantity <> 0 AND procurement_boms.bom_team_ck = 'do' #{part_ctl} #{where_data}").order(add_orderby).paginate(:page => params[:page], :per_page => 15)
=begin
            if @bom_item.blank?
                @bom_item = PItem.joins("JOIN procurement_boms ON procurement_boms.id = p_items.procurement_bom_id").where("p_items.user_do = '7' OR AND quantity <> 0 AND procurement_boms.bom_team_ck = 'do' #{part_ctl} #{key_des}").order(add_orderby).paginate(:page => params[:page], :per_page => 15)
            end
=end
        elsif can? :work_g_a, :all
            @user_do = "77"
            @bom_item = PItem.joins("JOIN procurement_boms ON procurement_boms.id = p_items.procurement_bom_id").where("(p_items.user_do = '77') AND quantity <> 0 AND procurement_boms.bom_team_ck = 'do' #{part_ctl} #{where_data}").order(add_orderby).paginate(:page => params[:page], :per_page => 15)
=begin
            if @bom_item.blank?
                @bom_item = PItem.joins("JOIN procurement_boms ON procurement_boms.id = p_items.procurement_bom_id").where("(p_items.user_do = '77' OR p_items.user_do = '9999') AND quantity <> 0 AND procurement_boms.bom_team_ck = 'do' #{part_ctl} #{key_des}").order(add_orderby).paginate(:page => params[:page], :per_page => 15)
            end
=end
        elsif can? :work_g_b, :all
            @user_do = "75"
            @bom_item = PItem.joins("JOIN procurement_boms ON procurement_boms.id = p_items.procurement_bom_id").where("(p_items.user_do = '75' ) AND quantity <> 0 AND procurement_boms.bom_team_ck = 'do' #{part_ctl} #{where_data}").order(add_orderby).paginate(:page => params[:page], :per_page => 15)
        elsif can? :work_g_c, :all
            @user_do = "9999"
            @bom_item = PItem.joins("JOIN procurement_boms ON procurement_boms.id = p_items.procurement_bom_id").where("(p_items.user_do = '9999' ) AND quantity <> 0 AND procurement_boms.bom_team_ck = 'do' #{part_ctl} #{where_data}").order(add_orderby).paginate(:page => params[:page], :per_page => 15)
=begin
            if @bom_item.blank?
                @bom_item = PItem.joins("JOIN procurement_boms ON procurement_boms.id = p_items.procurement_bom_id").where("(p_items.user_do = '75' OR p_items.user_do = '9999') AND quantity <> 0 AND procurement_boms.bom_team_ck = 'do' #{part_ctl} #{key_des}").order(add_orderby).paginate(:page => params[:page], :per_page => 15)
            end
=end
        elsif can? :work_d, :all
            @user_do = "7"
            @bom_item = PItem.joins("JOIN procurement_boms ON procurement_boms.id = p_items.procurement_bom_id").where("(p_items.user_do = '7' OR p_items.user_do = '9999') AND quantity <> 0 AND procurement_boms.bom_team_ck = 'do' #{part_ctl} #{where_data}").order(add_orderby).paginate(:page => params[:page], :per_page => 15)
=begin
            if @bom_item.blank?
                @bom_item = PItem.joins("JOIN procurement_boms ON procurement_boms.id = p_items.procurement_bom_id").where("(p_items.user_do = '7' OR p_items.user_do = '9999') AND quantity <> 0 AND procurement_boms.bom_team_ck = 'do' #{part_ctl} #{key_des}").order(add_orderby).paginate(:page => params[:page], :per_page => 15)
            end
=end
        end
        #@bom_item = @bom_item.select {|item| item.quantity != 0 }
        #if  params[:ajax]
            #@bomitem = PItem.find_by_sql("SELECT id,mpn,part_code,quantity,price,(price*quantity) AS total,mf,dn FROM bom_items WHERE bom_items.id = '#{params[:ajax]}'").first
            #render "viewbom.js.erb"
            #return false
        #end  
        #Rails.logger.info(@bom_item.inspect)        
    end    

    def send_order_to_p
        check = ProcurementBom.find(params[:bom_id])
        check.bom_team_ck = "do"
        check.bom_team_ck_at = Time.new()
        check.bom_eng = current_user.full_name
        if check.save
            q_order = PcbOrder.find_by_order_no(check.erp_no)
            if not q_order.blank?
                q_order.state = "quote"
                q_order.save
            end
        end
        redirect_to p_bomlist_path() 
    end

    def supplier_offer
        if can? :work_suppliers, :all
            
            if params[:complete]
                @part = PItem.where(user_do: '999',supplier_tag: 'done').order("mpn","created_at").paginate(:page => params[:page], :per_page => 10)             
                #@part = PItem.joins("JOIN p_dns ON p_items.id = p_dns.p_item_id").where("p_items.user_do = '999' AND p_dns.color = 'y'").group("p_items.id").paginate(:page => params[:page], :per_page => 10)
                #@part = PItem.find_by_sql("﻿SELECT p_items.* FROM p_items INNER JOIN p_dns ON p_items.id = p_dns.p_item_id WHERE p_items.user_do = '999' AND p_dns.color = 'y' GROUP BY p_items.id").paginate(:page => params[:page], :per_page => 10)
            elsif params[:undone]
                @part = PItem.where(user_do: '999',supplier_tag: nil).order("mpn","created_at").paginate(:page => params[:page], :per_page => 10)
            elsif params[:key_mpn]
                @part = PItem.where("(mpn LIKE '%#{params[:key_mpn]}%' OR description LIKE '%#{params[:key_mpn]}%') AND user_do = '999' AND supplier_tag = 'done'").order("mpn","created_at").paginate(:page => params[:page], :per_page => 10)
            else
                @part = PItem.where(user_do: '999').order("mpn","created_at").paginate(:page => params[:page], :per_page => 10)
            end
            Rails.logger.info("-------------------------@part")
            #Rails.logger.info(@part.inspect)   
            Rails.logger.info("----------------------------------@part")   
            render "supplier_offer.html.erb" and return
        else
            render plain: "You don't have permission to view this page !"
        end
    end

    def supplier_dn_excel
        if can? :work_suppliers, :all
            if params[:out_tag]
                @bom = PItem.where(user_do: '999',supplier_tag: nil,supplier_out_tag: nil).order("mpn","created_at")
            else
                @bom = PItem.where(user_do: '999',supplier_tag: nil).order("mpn","created_at")
            end
            file_name = "supplier_out.xls"
            path = Rails.root.to_s+"/public/uploads/bom/excel_file/"
            #Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
            #Rails.logger.info(file_name.inspect)
            #Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")

                Spreadsheet.client_encoding = 'UTF-8'
		ff = Spreadsheet::Workbook.new

		sheet1 = ff.create_worksheet

		#sheet1.row(0).concat %w{No 描述 报价 技术资料}
                all_title = []
                all_title << "日期"
                all_title << "MPN"
                all_title << "描述"
                all_title << "数量"
                all_title << "报价"
                sheet1.row(0).concat all_title
                #sheet1.column(1).width = 50
                set_color = 0  
                while set_color < all_title.size do         
                    sheet1.row(0).set_format(set_color,ColorFormat.new(:gray,:white))
                    if all_title[set_color] =~ /数量/i 
                        sheet1.column(set_color).width = 8
                    elsif all_title[set_color] =~ /报价/i
                        sheet1.column(set_color).width = 8
                    elsif all_title[set_color] =~ /描述/i
                        sheet1.column(set_color).width = 35  
                    elsif all_title[set_color] =~ /MPN/i
                        sheet1.column(set_color).width = 20 
                    elsif all_title[set_color] =~ /日期/i
                        sheet1.column(set_color).width = 20                    
                    else
                        sheet1.column(set_color).width = 15
                    end
                    set_color += 1
                end
		@bom.each_with_index do |item,index|
                    if params[:out_tag]
                        item.supplier_out_tag = "do"
                        item.save
                    end
		    rowNum = index+1
                    title_format = Spreadsheet::Format.new({
                    :text_wrap => 1,:size => 8
                    })
		    row = sheet1.row(rowNum)
                    row.set_format(2,title_format)
                    set_f = 0  
                    while set_f < all_title.size do         
                        row.set_format(set_f,title_format)
                        set_f += 1
                    end
                    row.push(item.created_at.localtime.strftime('%Y-%m-%d %H:%M:%S').to_s)
                    row.push(item.mpn)
		    row.push(item.description)
                    row.push(item.quantity * ProcurementBom.find(item.procurement_bom_id).qty)
                    if not PDn.find_by(p_item_id: item.id,color: "y").blank?
                        row.push(PDn.where(p_item_id: item.id,color: "y",state: "").last!.cost)
                    else
                        row.push("")
                    end
                end

                #file_contents = StringIO.new
	        #ff.write (file_contents)
	        #send_data(file_contents.string.force_encoding('UTF-8'), filename: file_name)
                              
                ff.write (path+file_name)              
                send_file(path+file_name, type: "application/vnd.ms-excel") and return
        else
            render plain: "You don't have permission to view this page !"
        end
                #send_file(path,filename: file_name, type: "application/vnd.ms-excel")    
    end

    def p_edit_supplier_dn 
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        Rails.logger.info(params["#{params[:dn_itemid]}p"].inspect)
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        @itemid = params[:dn_itemid]
        @pitem = PItem.find(params[:dn_itemid])
        if params["#{params[:dn_itemid]}p"] != "" 
            @dn = PDn.new
            @dn.email = current_user.email
            @dn.cost = params["#{params[:dn_itemid]}p"]
            @dn.p_item_id = @pitem.id
            @dn.remark = params[:dn_remark]
            @dn.qty = @pitem.quantity * ProcurementBom.find(@pitem.procurement_bom_id).qty
            @dn.color = "y"
            @dn.tag = "a"
            @dn.date = Time.new
            @dn.save
            @pitem.supplier_tag = "done"
            @pitem.save
=begin

            @dn = PDn.find_by(item_id: params[:dn_itemid],color: "y") 
            if not @dn.blank?
                @dn.cost = params["#{params[:dn_itemid]}p"]
                @dn.save
            else
                @dn = PDn.new
                @dn.cost = params["#{params[:dn_itemid]}p"]
                @dn.item_id = @pitem.id
                @dn.qty = @pitem.quantity * ProcurementBom.find(@pitem.procurement_bom_id).qty
                @dn.color = "y"
                @dn.tag = "a"
                @dn.date = Time.new
                @dn.save
            end
=end
=begin
    
            @pitem = PItem.find(params[:dn_itemid])
            @pitem.cost = params["#{params[:dn_itemid]}p"]
            @pitem.color = "b"
            @pitem.save
            @itemid = params[:dn_itemid]
            @dnid = @pitem.dn_id
            if not @dnid.blank?
                dn = PDn.find(@dnid)  
                if not params["#{params[:dn_itemid]}p"].blank?
                    dn.cost = params["#{params[:dn_itemid]}p"]
                    dn.color = "y"
                end
                dn.save      
            else
                dn = PDn.new
                dn.cost = params["#{params[:dn_itemid]}p"]
                dn.item_id = @pitem.id
                dn.qty = @pitem.quantity * ProcurementBom.find(@pitem.procurement_bom_id).qty
                dn.color = "y"
                dn.tag = "a"
                dn.date = Time.new
                dn.save
                @dnid = dn.id
                @pitem.dn_id = dn.id
                @pitem.save 
            end
=end


        end
        #redirect_to :back
        #return false     
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        Rails.logger.info(@pitem.inspect)
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        render "p_edit_supplier_dn.js.erb"
    end

    def p_history
        if can? :work_baojia, :all or can? :work_sw_hw, :all
            where_des = ""
            where_moko_des = ""
            where_remark = ""
            if not params[:part_name].blank? 
                des = params[:part_name].strip.split(" ")
                des.each_with_index do |de,index|
                    where_des += "p_items.description LIKE '%#{de}%'"
                    where_moko_des += "p_items.moko_des LIKE '%#{de}%'"
                    where_remark  += "p_dns.remark LIKE '%#{de}%'"
                    if des.size > (index + 1)
                        where_des += " AND "
                        where_moko_des += " AND "
                        where_remark += " AND "
                    end
                end 
                @p_history = PItem.find_by_sql("SELECT *,p_items.description AS des, p_items.moko_des, p_items.created_at AS c_time FROM `p_items` LEFT JOIN `p_dns` ON `p_items`.`dn_id` = `p_dns`.`id` WHERE `p_items`.`mpn` LIKE '%#{params[:part_name].strip}%' or (#{where_des}) or (#{where_moko_des}) or (#{where_remark}) ORDER BY p_items.updated_at DESC").paginate(:page => params[:page], :per_page => 10)
=begin
            else
                where_des = "p_items.description LIKE '%%'"
                where_des = "p_items.moko_des LIKE '%%'"
                @p_history = PItem.find_by_sql("SELECT *,p_items.description AS des, p_items.moko_des, p_items.created_at AS c_time FROM `p_items` LEFT JOIN `p_dns` ON `p_items`.`dn_id` = `p_dns`.`id`  ORDER BY p_items.updated_at DESC").paginate(:page => params[:page], :per_page => 10)
=end
            end     
            render "p_history.html.erb" and return
        else
            render plain: "You don't have permission to view this page !"
        end     
    end

    def pj_edit
        bom = ProcurementBom.find(params[:bom_id])             
        bom.p_name = params[:pj_name]
        bom.p_name_mom = params[:pj_name_mom]
        bom.qty = params[:pj_qty]
        bom.remark = params[:pj_remark]
        if not bom.att.blank?
            bom.att = params[:att]
        end
        if bom.save
            bom_item = PItem.where(procurement_bom_id: bom.id)
            if not bom_item.blank?
            t_p = 0
                bom_item.each do |item|
                    item.pmc_qty = bom.qty*item.quantity
                    if not item.cost.blank?
                        t_p = t_p + bom.qty*item.quantity*item.cost
                    end
                    item.save
                end
            end
            bom.t_p = t_p
            bom.save
        end
        redirect_to :back  
    end

    def select_with_ajax    
        #@data = Product.find_by_sql("select part_name as name, part_name_en as value from products GROUP BY products.part_name")  
        #Rails.logger.info("-------------------------212121")
        #Rails.logger.info(@data.inspect)   
        #Rails.logger.info("----------------------------------000000")   
        #@fengzhuang = Product.find_by_sql("SELECT products.part_name, products.package2 FROM products GROUP BY products.package2 HAVING products.part_name = '"+ params[:id] + "'").collect { |product| [product.package2, product.package2] } 
        kind = Kind.find_by_sql("SELECT * FROM kinds WHERE kinds.des = '"+params[:id]+"'").first
        if kind.blank?
            @code_a = ""
            @code_b = ""
            kind_attr = ""
        else
            @code_a = kind.code_a
            @code_b = kind.code_b
            kind_attr = kind.attr
        end
        
        @options = ""
        city = Product.find_by_sql("SELECT DISTINCT products.package2, products.part_name,products.ptype,products.part_name_en FROM products WHERE products.part_name = '"+ params[:id] + "'")
        city.each do |s|
            @options << "<option value=#{s.package2}>#{s.package2}</option>"
        end
        Rails.logger.info("-------------------------@code_a")
        Rails.logger.info(@code_a.inspect)  
        Rails.logger.info(@code_b.inspect)
        Rails.logger.info(@options.inspect)   
        Rails.logger.info("----------------------------------@code_a")  
        @all_attr = '<label class="control-label">产品描述:</label>'
        @all_attr += '<div class="form-inline" style="padding-bottom: 5px;padding-left: 15px;">'  
        @all_attr += '<label for="keyptype" class="control-label">Ptype:</label>'  
        @all_attr += '<input type="text" name="keyptype" id="keyptype" class="form-control" value="'+city.first.ptype+'">'  
        @all_attr += '</div>'
        @all_attr += '<div class="form-inline" style="padding-bottom: 5px;padding-left: 15px;">'  
        @all_attr += '<label for="key1en" class="control-label">英文名称:</label>'  
        @all_attr += '<input type="text" name="key1en" id="key1en" class="form-control" value="'+city.first.part_name_en+'">'  
        @all_attr += '</div>'
        if kind_attr != nil and kind_attr != ""
            kind_attr.split(",").each_with_index do |item,index|                                           
                @all_attr += '<div class="form-inline" style="padding-bottom: 5px;padding-left: 15px;">'  
                @all_attr += '<label for="key'+(index+1).to_s+'" class="control-label">'+item.to_s+':</label>'  
                if index == 0                
                    @all_attr += '<input type="text" name="key'+(index+1).to_s+'" id="key'+(index+1).to_s+'" class="form-control" value="'+params[:id]+'">'  
                else
                    @all_attr += '<input type="text" name="key'+(index+1).to_s+'" id="key'+(index+1).to_s+'" class="form-control">'
                end         
                @all_attr += '</div>'
            end
        end

        #render "select_with_ajax.js.erb" and return
        #render :text => @options
    end
    
    def add_moko_part
        Rails.logger.info("add-------------------------------------add")
        Rails.logger.info(params.inspect)
        Rails.logger.info("add-------------------------------------add")
        @item_id = params[:item_id]
        if params[:part_a] == "" or params[:part_c] == "" or params[:abc] == ""
            #flash[:error] = "Part information can not be empty!!!"
            redirect_to :back
            #render "add_moko_part.js.erb" and return
        else
            name_a = "A." + params[:part_a].upcase
            if params[:part_b] != ""
                name_a += "." + params[:part_b].upcase
            end
            name_a += ".F."
            part_name_find = Product.find_by_sql("SELECT LPAD((MAX(SUBSTRING_INDEX(SUBSTRING_INDEX(products.`name`, '.' ,-1) , '-' ,1))+1 ) ,4,'0') AS part_n   FROM products WHERE `name` LIKE '%"+ name_a +"%'")
            if part_name_find.first.part_n.blank?
               part_name_find = "0001"
            else
               part_name_find = part_name_find.first.part_n.to_s
            end
            @new_part = Product.new
            @new_part.name = name_a + part_name_find.to_s + "-" + params[:package2]
            #@new_part.description = params[:part_c]
            @new_part.part_name = params[:key1]
            @new_part.part_name_en = params[:key1en]
            @new_part.ptype = params[:keyptype]
            @new_part.package1 = params[:part_b].upcase
            @new_part.package2 = params[:package2]
            des = ""
            if not params[:key1].blank?
                @new_part.value1 = params[:key1].strip
                des += params[:key1].strip + " "
            end
            if not params[:key2].blank?
                @new_part.value2 = params[:key2].strip
                des += " " + params[:key2].strip
            end
            if not params[:key3].blank?
                @new_part.value3 = params[:key3].strip
                des += " " + params[:key3].strip
            end
            if not params[:key4].blank?
                @new_part.value4 = params[:key4].strip
                des += " " + params[:key4].strip
            end
            if not params[:key5].blank?
                @new_part.value5 = params[:key5].strip
                des += " " + params[:key5].strip
            end
            if not params[:key6].blank?
                @new_part.value6 = params[:key6].strip
                des += " " + params[:key6].strip
            end
            if not params[:key7].blank?
                @new_part.value7 = params[:key7].strip
                des += " " + params[:key7].strip
            end
            if not params[:key8].blank?
                @new_part.value8 = params[:key8].strip
                des += " " + params[:key8].strip
            end
            @new_part.description = des
            if @new_part.save
                if params[:item_tag] == "edit"
                    p_item = PcbOrderItem.find(@item_id)
                    p_item.moko_code = @new_part.name
                    p_item.moko_des = @new_part.description
                    p_item.save
                    redirect_to :back and return
                else
                    p_item = PItem.find(@item_id)
                    p_item.product_id = @new_part.id
                    p_item.moko_part = @new_part.name
                    p_item.moko_des = @new_part.description
                    p_item.save
                #flash[:success] = "New part success"
                
                    render "add_moko_part.js.erb" and return
                end
            end
        end
    end

    def p_create_bom
        Rails.logger.info("-------------------------")
        Rails.logger.info(request.original_fullpath.inspect)   
        Rails.logger.info("----------------------------------") 
        
        @bom = ProcurementBom.new
        #@mpn_show = MpnItem.find_by_sql("SELECT * FROM `mpn_items` LIMIT 0, 30")
        @mpn_show = MpnItem.find_by_sql("SELECT * FROM mpn_items WHERE mpn IS NOT NULL AND id >= ((SELECT MAX(id) FROM mpn_items)-(SELECT MIN(id) FROM mpn_items)) * RAND() + (SELECT MIN(id) FROM mpn_items) LIMIT 100")
        @des_show = Product.find_by_sql("SELECT * FROM products WHERE id >= ((SELECT MAX(id) FROM products)-(SELECT MIN(id) FROM products)) * RAND() + (SELECT MIN(id) FROM products) LIMIT 100")
    end

    def p_upbom        
        if params[:bom_id] and params[:bak_bom].blank?
            old_bom = PItem.where(procurement_bom_id: params[:bom_id]) 
            old_bom.each do |old_item|
                old_item.destroy
            end
            @bom = ProcurementBom.find(params[:bom_id]) 

            @bom.p_name = params[:p_name]
            @bom.p_name_mom = params[:p_name_mom]
            @bom.qty = params[:qty]
            @bom.d_day = params[:day]  
            #@bom.save   
            Rails.logger.info("------------------------------------------------------------0")
            Rails.logger.info(params[:partCol].inspect)
            Rails.logger.info("------------------------------------------------------------0") 
            Rails.logger.info("------------------------------------------------------------1")
            Rails.logger.info(params[:bom_id].inspect)
            Rails.logger.info(params[:noselect].inspect)
            Rails.logger.info("------------------------------------------------------------1")
            #Rails.logger.info("------------------------------------------------------------2")
            #Rails.logger.info(params[:select_quantity].inspect)
            #Rails.logger.info("------------------------------------------------------------2")
            Rails.logger.info("------------------------------------------------------------3")
            Rails.logger.info(params[:desCol].inspect)
            Rails.logger.info("------------------------------------------------------------3")
            #Rails.logger.info("------------------------------------------------------------4")
            #Rails.logger.info(params[:select_description].inspect)
            #Rails.logger.info("------------------------------------------------------------4")
            @file = params[:bom_file]
            
            if params[:bom_file].split('.')[-1] == 'xls'
                begin
	            @xls_file = Roo::Excel.new(params[:bom_path])
                rescue
                    #@xls_file = Roo::Excelx.new(params[:bom_path])
                #else
                    redirect_to procurement_new_path(),  notice: "EXCEL文件错误!!!！"
                    return false
                end
            else
                redirect_to procurement_new_path(),  notice: "EXCEL文件错误!！"
                return false
=begin
                begin
	            @xls_file = Roo::Excelx.new(params[:bom_path])
                rescue
                    #@xls_file = Roo::Excel.new(params[:bom_path])
                #else
                    redirect_to procurement_new_path(),  notice: "EXCEL文件错误!！"
                    return false
                end
=end                
            end
            @sheet = @xls_file.sheet(0)
            row_n = 0
            row_use = 1
            @sheet.each do |row_i|
                row_n += 1
                #Rails.logger.info("quantityCol------------------------------------------------------------quantityCol")
                #Rails.logger.info(row_i[params[:quantityCol].strip.to_i].inspect)
                #Rails.logger.info("quantityCol------------------------------------------------------------quantityCol")
                if row_i[params[:quantityCol].strip.to_i].is_a?(Numeric)
                    row_use = row_n - 1
                    break
                end
            end
            @bom.row_use = row_use 
            all_item = []
            @sheet.row(row_use).each do |item|
                if not item =~ /\n/
                    if not item.blank? 
                        Rails.logger.info("item------------------------------------------------------------item")
                        Rails.logger.info(item.inspect)
                        Rails.logger.info("item------------------------------------------------------------item")
                        all_item << '"'+item+'":'+'"'+item+'"'
                    end
                end

            end
            all_title = @sheet.row(row_use).join("|")
            @bom.all_title = all_title  
            @bom.save
            
            if not @bom.moko_bom_info_id.blank?
                @moko_bom = MokoBomInfo.find(@bom.moko_bom_info_id)
                @moko_bom.p_name = params[:p_name]
                @moko_bom.p_name_mom = params[:p_name_mom]
                @moko_bom.qty = params[:qty]
                @moko_bom.d_day = params[:day] 
                @moko_bom.row_use = @bom.row_use
                @moko_bom.all_title = @bom.all_title  
                @moko_bom.save
                old_moko_bom_item = MokoBomItem.where(moko_bom_info_id: @bom.moko_bom_info_id)
                old_moko_bom_item.each do |old_item|
                    old_item.destroy
                end
            end

            all_item = "{"+all_item.join(",")+"}"
            Rails.logger.info("------------------------------------------------------------qq1")
            Rails.logger.info(row_use.inspect)
            Rails.logger.info("------------------------------------------------------------qq000")
            Rails.logger.info(all_item.inspect)
            Rails.logger.info("------------------------------------------------------------qq2")
            #@parse_result = @sheet.parse(:Qty => "Qty",clean:true)
	    @parse_result = @sheet.parse(JSON.parse(all_item))  
	    #remove first row 
	    @parse_result.shift
            #render "select_column.html.erb" 
            #return false 
            Rails.logger.info("------------------------------------------------------------qq1----------------------")
            #Rails.logger.info(@sheet.row(row_use)[params[:partCol].to_i].split("").inspect)
            Rails.logger.info(@sheet.row(row_use)[params[:quantityCol].to_i].split("").inspect)
            Rails.logger.info(@sheet.row(row_use)[params[:refdesCol].to_i].split("").inspect)
            Rails.logger.info(@sheet.row(row_use)[params[:refdesCol].to_i].inspect)
            Rails.logger.info("------------------------------------------------------------qq2-----------------------") 
            all_use = @sheet.row(row_use)[params[:partCol].to_i].split("")+@sheet.row(row_use)[params[:quantityCol].to_i].split("")+@sheet.row(row_use)[params[:refdesCol].to_i].split("")
            #params[:select_part].each do |use|
	    #@parse_result.select! {|item| !item["#{@sheet.row(row_use)[params[:quantityCol].to_i]}"].blank? } #选择非空行
            #end
            Rails.logger.info("------------------------------------------------------------qq1")
            Rails.logger.info(all_item.inspect)
            Rails.logger.info("------------------------------------------------------------qq2")
            Rails.logger.info(@parse_result.inspect)
            Rails.logger.info(@sheet.row(row_use)[params[:partCol].to_i].inspect)
            Rails.logger.info("------------------------------------------------------------qq3")
            #行号
            row_num = 0
           # all_m_bom = []
            #one_m_bom = []
            #other_all = @sheet.row(1)-@sheet.row(1)[params[:partCol].to_i].split("")-@sheet.row(1)[params[:quantityCol].to_i].split("")-@sheet.row(1)[params[:refdesCol].to_i].split("")
            other_all = @sheet.row(row_use)
            other_all.delete(@sheet.row(row_use)[params[:partCol].to_i])
            other_all.delete(@sheet.row(row_use)[params[:quantityCol].to_i])
            other_all.delete(@sheet.row(row_use)[params[:refdesCol].to_i])
            if params[:linkCol]
                other_all.delete(@sheet.row(row_use)[params[:linkCol].to_i])
            end
            params[:desCol].strip.split(" ").sort!.each do |des|
                other_all.delete(@sheet.row(row_use)[des.to_i])
            end
            Rails.logger.info("------------------------------------------------------------aaaa")
            Rails.logger.info(other_all.inspect)
            Rails.logger.info(params[:desCol].strip.split(" ").inspect)
            Rails.logger.info("------------------------------------------------------------aaaa")
	    @parse_result.each do |item| #处理每一行的数据 
                mpna = ""
                if item["#{@sheet.row(row_use)[params[:partCol].to_i]}"].blank? or params[:partCol].blank?
                    mpna += ""
                else
                    mpna += item["#{@sheet.row(row_use)[params[:partCol].to_i]}"].to_s + " " 
                end
                qtya = ""
                if item["#{@sheet.row(row_use)[params[:quantityCol].to_i]}"].blank? or params[:quantityCol].blank?
                    qtya += ""
                else
                    qtya += item["#{@sheet.row(row_use)[params[:quantityCol].to_i]}"].to_s + " "             
                end
                refa = ""
                if item["#{@sheet.row(row_use)[params[:refdesCol].to_i]}"].blank? or params[:refdesCol].blank?
                    refa += ""
                else
                    refa += item["#{@sheet.row(row_use)[params[:refdesCol].to_i]}"].to_s + " "
                end
                fengzhuang = ""
                if item["#{@sheet.row(row_use)[params[:packageCol].to_i]}"].blank? or params[:packageCol].blank?
                    fengzhuang += ""
                else
                    fengzhuang += item["#{@sheet.row(row_use)[params[:packageCol].to_i]}"].to_s + " "
                end
                link = ""
                if item["#{@sheet.row(row_use)[params[:linkCol].to_i]}"].blank? or params[:linkCol].blank?
                    link += ""
                else
                    link += item["#{@sheet.row(row_use)[params[:linkCol].to_i]}"].to_s + " "
                end
                desa = ""
                #Rails.logger.info("------------------------------------------------------------des----")
                #Rails.logger.info(params[:desCol].strip.split(" ").sort!.inspect)
                #Rails.logger.info(item.inspect)
                #Rails.logger.info(item[2].inspect)
                #Rails.logger.info(item[3].inspect)
                #Rails.logger.info("------------------------------------------------------------des----")
                params[:desCol].strip.split(" ").sort!.each do |des|                    
                    if item["#{@sheet.row(row_use)[des.to_i]}"].blank?
                        desa += ""
                    else
                        if item["#{@sheet.row(row_use)[des.to_i]}"].to_s.strip[-2..-1] == ".0"
                            desa += item["#{@sheet.row(row_use)[des.to_i]}"].to_s.strip.chop.chop + " "
                        else
                            desa += item["#{@sheet.row(row_use)[des.to_i]}"].to_s + " "
                        end
                    end
                end
                othera = ""
                other_all.each do |other|                    
                    if item["#{other}"].blank?
                        othera += ""
                    else
                        othera += item["#{other}"].to_s + " "
                    end
                end
                all_info_n = @sheet.row(row_use)
	        all_info = ""
                all_info_n.each do |info|                    
                    #if item["#{info}"].blank?
                        #all_info += " "+ "|"
                    #else
                    if item["#{info}"].to_s[-2..-1] == ".0"
                        all_info += item["#{info}"].to_s.chop.chop + "|"
                    else
                        all_info += item["#{info}"].to_s + "|"
                    end
                    #end
                end
		Rails.logger.info("------------------------------------------------------------des")
                Rails.logger.info(mpna.inspect)
                Rails.logger.info(qtya.inspect)
                Rails.logger.info(refa.inspect)
                Rails.logger.info(desa.inspect)
                Rails.logger.info(othera.inspect)
                Rails.logger.info("------------------------------------------------------------des")
                #find_mpn = PItem.where(procurement_bom_id: params[:bom_id],mpn: mpna)
                #if find_mpn.blank?
                    bom_item = @bom.p_items.build() #创建bom_items对象
                    bom_item.part_code = refa
                    if refa.blank? 
                        bom_item.user_do = 7
                    else
                        if refa =~ /r/i or refa =~ /c/i or refa =~ /d/i or refa =~ /v/i or refa =~ /q/i or refa =~ /lcd/i or refa =~ /led/i or  refa =~ /z/i
                            bom_item.user_do = 77
                            #bom_item.user_do = 7
                        elsif refa =~ /l/i or refa =~ /x/i or refa =~ /sw/i or refa =~ /s/i or refa =~ /vr/i or refa =~ /w/i or refa =~ /k/i or refa =~ /rl/i or refa =~ /fb/i or refa =~ /fr/i or refa =~ /y/i or refa =~ /f/i or refa =~ /pf/i or refa =~ /j/i or refa =~ /con/i or refa =~ /jp/i or refa =~ /bz/i or refa =~ /p/i
                            bom_item.user_do = 75
                        elsif refa =~ /ic/i or refa =~ /u/i
                            bom_item.user_do = 7
                        end
                    end
		    bom_item.description = desa
                    bom_item.quantity = qtya.to_i
                    bom_item.pmc_qty = qtya.to_i*@bom.qty.to_i
                    #bom_item.mpn = mpna.gsub(/.0/, "")
                    if mpna.to_s.strip[-2..-1] == ".0"
                        bom_item.mpn = mpna.to_s.strip.chop.chop
                    else
                        bom_item.mpn = mpna
                    end
                    bom_item.fengzhuang = fengzhuang
                    bom_item.link = link
                    bom_item.other = othera
                    bom_item.all_info = all_info.chop
                    bom_item.user_id = current_user.id
                    bom_item.erp_id = @bom.erp_id
                    bom_item.erp_no = @bom.erp_no
                    bom_item.save
=begin
                    if not @bom.moko_bom_info_id.blank?
                        moko_bom_item = @moko_bom.moko_bom_items.build() #创建moko_bom_items对象
                        moko_bom_item.part_code = bom_item.part_code
                        moko_bom_item.user_do = bom_item.user_do
                        

                        moko_bom_item.description = bom_item.description
                        moko_bom_item.quantity = bom_item.quantity
                        moko_bom_item.pmc_qty = bom_item.pmc_qty


                        moko_bom_item.mpn = bom_item.mpn


                        moko_bom_item.fengzhuang = bom_item.fengzhuang
                        moko_bom_item.link = bom_item.link
                        moko_bom_item.other = bom_item.other
                        moko_bom_item.all_info = bom_item.all_info
                        moko_bom_item.user_id = bom_item.user_id
                        moko_bom_item.erp_id = bom_item.erp_id
                        moko_bom_item.erp_no = bom_item.erp_no
                        moko_bom_item.save
                    end
=end
                #end
            end
            
            #render "select_column.html.erb" 
            #redirect_to search_part_path(:bom_id => params[:bom_id])
            #return false
            @bom_item = PItem.where(procurement_bom_id: params[:bom_id])
            render "p_search_part.html.erb"
            return false
        end
                
        if not params[:bak_bom].blank? 
            @bom = ProcurementBom.find(params[:bom_id])
            #if @bom.excel_file_identifier.split('.')[-1] == 'xls'
	        #@xls_file = Roo::Excel.new(@bom.excel_file.current_path)
            #else
                #@xls_file = Roo::Excelx.new(@bom.excel_file.current_path)
            #end
            #@sheet = @xls_file.sheet(0)
            #render "select_column.html.erb"
            redirect_to p_select_column_path(bom: @bom)
            return false
        end


=begin
        @moko_bom = MokoBomInfo.new(bom_params)#使用页面传进来的文件名字作为参数创建一个bom对象
        @moko_bom.user_id = current_user.id
        @moko_bom.bom_eng_up = current_user.full_name
        if params[:erp_item_id] != ""
            @moko_bom.erp_item_id = params[:erp_item_id]   
            @moko_bom.att = PcbOrderItem.find_by_id(params[:erp_item_id]).att
        end
        if params[:erp_no] != ""
            @moko_bom.erp_no = params[:erp_no]
        end
        if params[:erp_no_son] != ""
            @moko_bom.erp_no_son = params[:erp_no_son]
        end
        if params[:erp_qty] != ""
            @moko_bom.erp_qty = params[:erp_qty]
        end
        if @moko_bom.save
            @moko_bom.bom_id = "moko#{@moko_bom.id}"
            @moko_bom.save
        end
=end


        @bom = ProcurementBom.new(bom_params)#使用页面传进来的文件名字作为参数创建一个bom对象
        @bom.user_id = current_user.id
        @bom.bom_eng_up = current_user.full_name
       # if params[:erp_id] != ""
           # @bom.erp_id = params[:erp_id]
       # end
        if params[:erp_item_id] != ""
            @bom.erp_item_id = params[:erp_item_id]
            #if not PcbOrderItem.find_by_id(params[:erp_item_id]).blank?
            @bom.att = PcbOrderItem.find_by_id(params[:erp_item_id]).att
            #end
            #upstart = PcbOrderItem.find_by_id(params[:erp_item_id])
            #upstart.state = "quote"
            #upstart.save
        end
        if params[:erp_no] != ""
            @bom.erp_no = params[:erp_no]
        end
        if params[:erp_no_son] != ""
            @bom.erp_no_son = params[:erp_no_son]
        end
        if params[:erp_qty] != ""
            @bom.erp_qty = params[:erp_qty]
        end
        @file = @bom.excel_file_identifier
        if ProcurementBom.find_by_sql('SELECT no FROM procurement_boms WHERE to_days(procurement_boms.created_at) = to_days(NOW())').blank?
            order_n =1
        else
             #Rails.logger.info("qqqqqq-----------------------order_n-------------qqqqqq")
             #Rails.logger.info(ProcurementBom.find_by_sql('SELECT no FROM procurement_boms WHERE to_days(procurement_boms.created_at) = to_days(NOW())').last.no.split("B")[-1].inspect)
             #Rails.logger.info("qqqqqq------------------------order_n--------------qqqqqq")
            order_n = ProcurementBom.find_by_sql('SELECT no FROM procurement_boms WHERE to_days(procurement_boms.created_at) = to_days(NOW())').last.no.split("B")[-1].to_i + 1
        end
        @bom.no = "MB" + Time.new.strftime('%Y').to_s[-1] + Time.new.strftime('%m%d').to_s + "B" + order_n.to_s + "B"
        #如果上传成功
=begin
        @bom.bom_id = "moko#{@moko_bom.id}"
        @bom.moko_bom_info_id = @moko_bom.id
=end
	if @bom.save
            @bom.bom_id = @bom.id
            @bom.save
            if params[:erp_item_id] != ""
                upstart = PcbOrderItem.find_by_id(params[:erp_item_id])
                upstart.state = "quote"
                upstart.p_type = "PCBA"
                upstart.bom_id = @bom.id
                upstart.save
            end
            #if @bom.excel_file_identifier.split('.')[-1] == 'xls'
	        #@xls_file = Roo::Excel.new(@bom.excel_file.current_path)
            #else
                #@xls_file = Roo::Excelx.new(@bom.excel_file.current_path)
            #end
            #@sheet = @xls_file.sheet(0)
            #render "select_column.html.erb"
            redirect_to p_select_column_path(bom: @bom)  
            return false
        end 
    end

    def p_select_column
        @sheet = params[:sheet]
        @bom = ProcurementBom.find(params[:bom])
        
        if @bom.excel_file_identifier.split('.')[-1] == 'xls'
            #begin
	        @xls_file = Roo::Excel.new(@bom.excel_file.current_path)
            #rescue
                #@xls_file = Roo::Excelx.new(@bom.excel_file.current_path)
            #else
                #redirect_to procurement_new_path(),  notice: "EXCEL文件错误！"
                #return false
            #end
        else
            @bom.destroy
            redirect_to procurement_new_path(),  notice: "EXCEL文件错误!!！"
            return false
            #begin
	        #@xls_file = Roo::Excelx.new(@bom.excel_file.current_path)
                #Rails.logger.info("------------------------------------------------------------2222")
            #rescue
                #Rails.logger.info("------------------------------------------------------------000000")
                #@xls_file = Roo::Excel.new(@bom.excel_file.current_path)
            #else
                #Rails.logger.info("------------------------------------------------------------111111")
                #redirect_to procurement_new_path(),  notice: "EXCEL文件错误!!！1"
                #return false
            #end
                
        end
        @sheet = @xls_file.sheet(0)
    end

    def p_search_part
        if params[:bom_id]
            @bom_item = PItem.where(procurement_bom_id: params[:bom_id])
            @bom_item.each do |item|
                if item.product_id.blank? and item.mpn_id.blank?
#0如果有描述 
                    if not item.description.blank?
    #0.1如果有mpn
                        if item.mpn != ""
        #0.1.1先从自有物料中匹配mpn
                            use_mpn = Product.find_by_sql("SELECT * FROM products WHERE products.mpn LIKE '%#{item.mpn.strip}%'")
                            if not use_mpn.blank?
                                item.product_id = use_mpn.id
                                item.moko_part = use_mpn.name
                                item.moko_des = use_mpn.description
                                @item = item
                                part_code = Product.find(item.product_id).name
                                all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{part_code}' AND all_dns.qty >= 100 ORDER BY all_dns.date DESC").first
                                if all_dns.blank?
                                    all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{part_code}' ORDER BY all_dns.date DESC").first
                                end
                                #all_dns.each do |dns|
                                if not all_dns.blank?
                                    add_dns = PDn.new
                                    if not can? :work_d, :all
                                        add_dns.email = current_user.email
                                    end
                                    add_dns.p_item_id = @item.id
                                    add_dns.date = all_dns.date
                                    add_dns.part_code = all_dns.part_code
                                    add_dns.dn = all_dns.dn
                                    add_dns.dn_long = all_dns.dn_long
                                    add_dns.cost = all_dns.price
                                    #add_dns.qty = all_dns.qty
                                    add_dns.qty = item.quantity * ProcurementBom.find(item.procurement_bom_id).qty
                                    add_dns.color = "g"
                                    add_dns.save
                                    item.cost = add_dns.cost
                                    item.color = "g"
                                    item.dn_id = add_dns.id
                                    item.dn = add_dns.dn
                                    item.dn_long = add_dns.dn_long
                                    item.save
                                else
                                    item.save
                                end
                                #item.save
                                render "p_search_part.js.erb" and return
                            else
        #0.1.2如果自有物料不能匹配 
                                Rails.logger.info("qqqqqq-----------------------根据历史记录查询产品-----------------------qqqqqq")
                                match_product_old = search_bom_use(item.description,item.mpn) #根据历史记录查询产品
                                Rails.logger.info("qqqqqq-----------------------根据历史记录查询产品-------------qqqqqq")
                                Rails.logger.info(match_product_old.inspect)
                                Rails.logger.info("qqqqqq------------------------根据历史记录查询产品--------------qqqqqq")
                                if match_product_old.blank?
                                    Rails.logger.info("qqqqqq-----------------------111111111111----------------------qqqqqq")
                                    match_product = search_bom(item.description,item.part_code) #根据关键字和位号查询产品
                                elsif not match_product_old.dn_id.blank?
                                    #begin
                                    match_dn = PDn.find_by_id(match_product_old.dn_id)
                                    if not match_dn.blank?
                                        Rails.logger.info("qqqqqq-----------------------222222222222----------------------qqqqqq")
                                        add_dns = PDn.new
                                        add_dns.email = match_dn.email
                                        add_dns.p_item_id = item.id
                                        add_dns.date = match_dn.date
                                        add_dns.part_code = match_dn.part_code
                                        add_dns.dn = match_dn.dn
                                        add_dns.dn_long = match_dn.dn_long
                                        add_dns.cost = match_dn.cost
                                        add_dns.qty = match_dn.qty
                                        add_dns.qty = item.quantity * ProcurementBom.find(item.procurement_bom_id).qty
                                        add_dns.info = match_dn.info
                                        add_dns.remark = match_dn.remark
                                        add_dns.color = "g"
                                        add_dns.save
                                        item.cost = add_dns.cost
                                        item.color = "g"
                                        item.product_id = match_product_old.product_id
                                        if match_product_old.product_id != 0
                                            if not Product.find(match_product_old.product_id).blank? 
                                                item.moko_part = Product.find(match_product_old.product_id).name
                                                item.moko_des = Product.find(match_product_old.product_id).description
                                            end
                                        end
                                        item.dn_id = add_dns.id
                                        item.dn = add_dns.dn
                                        item.dn_long = add_dns.dn_long
                                        item.save
                                        @item = item
                                        render "p_search_part.js.erb" and return
                                    #rescue
                                    end
                                end
                                if not match_product.blank?
                                    Rails.logger.info("qqqqqq-----------------------3333333333333----------------------qqqqqq")
                                    item.product_id = match_product.first.id if match_product.count > 0
                                    item.moko_part = match_product.first.name if match_product.count > 0
                                    item.moko_des = match_product.first.description if match_product.count > 0
                                    @item = item
                                    part_code = Product.find(item.product_id).name
                                    all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{part_code}' AND all_dns.qty >= 100 ORDER BY all_dns.date DESC").first
                                #all_dns.each do |dns|
                                    if all_dns.blank?
                                        all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{part_code}' ORDER BY all_dns.date DESC").first
                                    end
                                    if not all_dns.blank?
                                        add_dns = PDn.new
                                        #add_dns.email = current_user.email
                                        add_dns.p_item_id = @item.id
                                        add_dns.date = all_dns.date
                                        add_dns.part_code = all_dns.part_code
                                        add_dns.dn = all_dns.dn
                                        add_dns.dn_long = all_dns.dn_long
                                        add_dns.cost = all_dns.price
                                        #add_dns.qty = all_dns.qty
                                        add_dns.qty = item.quantity * ProcurementBom.find(item.procurement_bom_id).qty
                                        add_dns.color = "g"
                                        add_dns.save
                                        item.cost = add_dns.cost
                                        item.color = "g"
                                        item.dn_id = add_dns.id
                                        item.dn = add_dns.dn
                                        item.dn_long = add_dns.dn_long
                                        item.save
                                    else
                                        item.save
                                    end
                                #item.save
                                else
                                    item.product_id = 0
                                    item.save
                                    @item = item
                                end
                                
                                #Rails.logger.info(match_product.inspect)
                                Rails.logger.info("11-------------------------------------------------------11")
                                #item.product_id = match_product.first.id if match_product.count > 0
                                #item.save
                                #@item = item
                                render "p_search_part.js.erb" and return        
                                end
                        else
    #0.2如果没有mpn只有描述
                            Rails.logger.info("22555-------------------------------------------------------22")
                            match_product_old = search_bom_use(item.description,nil) #根据历史记录查询产品
                            Rails.logger.info("qqqqqq-------------------------------------------------------qqqqqq")
                            Rails.logger.info(match_product_old.inspect)
                            Rails.logger.info("qqqqqq-------------------------------------------------------qqqqqq")
                            if match_product_old.blank?
                                match_product = search_bom(item.description,item.part_code) #根据关键字和位号查询产品
=begin
                                if not match_product.blank?
                                    item.product_id = match_product.first.id if match_product.count > 0
                                    Rails.logger.info("product_id-------------------------------------------------------product_id1")
                                    item.moko_part = match_product.first.name if match_product.count > 0
                                    item.moko_des = match_product.first.description if match_product.count > 0
                                    @item = item
                                    part_code = Product.find(item.product_id).name
                                    all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{part_code}' AND all_dns.qty >= 100 ORDER BY all_dns.date DESC").first
                                    if all_dns.blank?
                                        all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{part_code}' ORDER BY all_dns.date DESC").first
                                    end
                                #all_dns.each do |dns|
                                    if not all_dns.blank?
                                        add_dns = PDn.new
                                        add_dns.item_id = @item.id
                                        add_dns.date = all_dns.date
                                        add_dns.part_code = all_dns.part_code
                                        add_dns.dn = all_dns.dn
                                        add_dns.dn_long = all_dns.dn_long
                                        add_dns.cost = all_dns.price
                                        add_dns.qty = all_dns.qty
                                        add_dns.color = "g"
                                        add_dns.save
                                        item.cost = add_dns.cost
                                        item.color = "g"
                                        item.dn_id = add_dns.id
                                        item.dn = add_dns.dn
                                        item.dn_long = add_dns.dn_long
                                        item.save
                                    else
                                        item.save
                                    end
                                #item.save
                                else
                                    item.product_id = 0
                                    Rails.logger.info("product_id-------------------------------------------------------product_id2")
                                    item.save
                                    @item = item
                                end
=end
                            elsif not match_product_old.dn_id.blank?
                                Rails.logger.info("1111-------------------------------------------------------111")
                                #begin
                                match_dn = PDn.find_by_id(match_product_old.dn_id)
                                if not match_dn.blank?
                                    Rails.logger.info("1111-------------------------------------------------------222")
                                    add_dns = PDn.new
                                    add_dns.email = match_dn.email
                                    add_dns.p_item_id = item.id
                                    add_dns.date = match_dn.date
                                    add_dns.part_code = match_dn.part_code
                                    add_dns.dn = match_dn.dn
                                    add_dns.dn_long = match_dn.dn_long
                                    add_dns.cost = match_dn.cost
                                    #add_dns.qty = match_dn.qty
                                    add_dns.qty = item.quantity * ProcurementBom.find(item.procurement_bom_id).qty
                                    add_dns.info = match_dn.info
                                    add_dns.remark = match_dn.remark
                                    add_dns.color = "g"
                                    add_dns.save
                                    item.cost = add_dns.cost
                                    item.color = "g"
                                    item.product_id = match_product_old.product_id
                                    Rails.logger.info("product_id-------------------------------------------------------product_id0")
                                    Rails.logger.info(match_product_old.product_id.inspect)
                                    Rails.logger.info("match_product_old.product_id-------------------------------------------------------match_product_old.product_id")
                                    if match_product_old.product_id != 0
                                        if not Product.find(match_product_old.product_id).blank?
                                            item.moko_part = Product.find(match_product_old.product_id).name
                                            item.moko_des = Product.find(match_product_old.product_id).description
                                        end  
                                    end                                 
                                    item.dn_id = add_dns.id
                                    item.dn = add_dns.dn
                                    item.dn_long = add_dns.dn_long
                                    item.save
                                    @item = item
                                    render "p_search_part.js.erb" and return 
                                else
                                    add_dns = PDn.new
                                    #add_dns.email = current_user.email
                                    add_dns.p_item_id = item.id
                                    add_dns.date = Time.new
                                    add_dns.part_code = match_product_old.moko_part
                                    add_dns.dn = match_product_old.dn
                                    add_dns.dn_long = match_product_old.dn_long
                                    add_dns.cost = match_product_old.cost
                                    #add_dns.qty = match_dn.qty
                                    add_dns.qty = match_product_old.quantity * ProcurementBom.find(match_product_old.procurement_bom_id).qty
                                    #add_dns.info = match_dn.info
                                    #add_dns.remark = match_dn.remark
                                    add_dns.color = "g"
                                    add_dns.save
                                    item.cost = add_dns.cost
                                    item.color = "g"
                                    item.product_id = match_product_old.product_id
                                    Rails.logger.info("product_id-------------------------------------------------------product_id0")
                                    Rails.logger.info(match_product_old.product_id.inspect)
                                    Rails.logger.info("match_product_old.product_id-------------------------------------------------------match_product_old.product_id")
                                    if match_product_old.product_id != 0
                                        if not Product.find(match_product_old.product_id).blank?
                                            item.moko_part = Product.find(match_product_old.product_id).name
                                            item.moko_des = Product.find(match_product_old.product_id).description
                                        end  
                                    end                                 
                                    item.dn_id = add_dns.id
                                    item.dn = add_dns.dn
                                    item.dn_long = add_dns.dn_long
                                    item.save
                                    @item = item
                                    render "p_search_part.js.erb" and return 

                                end
                            end

                            if not match_product.blank?
                                item.product_id = match_product.first.id if match_product.count > 0
                                Rails.logger.info("product_id-------------------------------------------------------product_id1")
                                item.moko_part = match_product.first.name if match_product.count > 0
                                item.moko_des = match_product.first.description if match_product.count > 0
                                @item = item
                                part_code = Product.find(item.product_id).name
                                all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{part_code}' AND all_dns.qty >= 100 ORDER BY all_dns.date DESC").first
                                if all_dns.blank?
                                    all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{part_code}' ORDER BY all_dns.date DESC").first
                                end
                                #all_dns.each do |dns|
                                if not all_dns.blank?
                                    add_dns = PDn.new
                                    #add_dns.email = current_user.email
                                    add_dns.p_item_id = @item.id
                                    add_dns.date = all_dns.date
                                    add_dns.part_code = all_dns.part_code
                                    add_dns.dn = all_dns.dn
                                    add_dns.dn_long = all_dns.dn_long
                                    add_dns.cost = all_dns.price
                                    #add_dns.qty = all_dns.qty
                                    add_dns.qty = item.quantity * ProcurementBom.find(item.procurement_bom_id).qty
                                    add_dns.color = "g"
                                    add_dns.save
                                    item.cost = add_dns.cost
                                    item.color = "g"
                                    item.dn_id = add_dns.id
                                    item.dn = add_dns.dn
                                    item.dn_long = add_dns.dn_long
                                    item.save
                                else
                                    item.save
                                end
                                #item.save
                            else
                                if match_product_old.blank?
                                    item.product_id = 0
                                    Rails.logger.info("product_id-------------------------------------------------------product_id2")
                                    #item.save  
                                end
                                item.save
                                @item = item
                            end
                            


                            #item.product_id = match_product.first.id if match_product.count > 0
                            #item.save
                            #@item = item
                            Rails.logger.info("1111-------------------------------------------------------333")
                            render "p_search_part.js.erb" and return
                        end
                    end
                end



=begin

                if item.mpn_id.blank? 
                    mpn = item.mpn.strip
                    url = URI('http://api.findchips.com/v1/search?apiKey=RDQCwiQN4yhvRYKulcgw&part='+CGI::escape(mpn))
                    begin
                        Rails.logger.info("url--------------------------------------------------------------------------11")
                        Rails.logger.info(url.inspect)
                        resp = Net::HTTP.get(url)
                        #Rails.logger.info(resp.inspect)
                        server_response = JSON.parse(resp)
                        #Rails.logger.info(server_response.inspect)
                    rescue
                        retry
                    end




   
                    info_mpn = InfoPart.new
                    info_mpn.mpn = mpn
                    #info_mpn.info = resp.body
                    info_mpn.info = resp
                    info_mpn.save
                    item.mpn_id = info_mpn.id
                    item.save
                    @item = item
                    render "p_search_part.js.erb" and return
                end   

=end


            end


 
            @bom = ProcurementBom.find(params[:bom_id])      
            if not @bom.qty.blank?
                @total_p = 0   
                all_c = 0           
                @bom_item.each do |bomitem|
                    if not bomitem.cost.blank?
                        @total_p += bomitem.cost*bomitem.pmc_qty
                    end
                    all_c += bomitem.quantity                    
                end
                #@total_p = @total_p*@bom.qty.to_i
                @bom.t_p = @total_p
                @bom.t_c = all_c*@bom.qty.to_i
                c_p = all_c*@bom.qty.to_i*0.06
                if c_p < 200
                    c_p = 200
                end
                @bom.c_p = c_p
                @bom.save

                render inline: "window.location='/p_viewbom?bom_id=#{params[:bom_id]}';" 
            end           
        end      
    end

    def moko_view_bom
        @pdn = PDn.new
        @all_dn = "[&quot;"
        all_s_dn = AllDn.find_by_sql("SELECT DISTINCT all_dns.dn FROM all_dns GROUP BY all_dns.dn")
        all_s_dn.each do |dn|
            @all_dn += "&quot;,&quot;" + dn.dn.to_s
        end
        @all_dn += "&quot;]"

        @boms = MokoBomInfo.find_by_id(params[:bom_id])
        @q_order = PcbOrder.find_by(order_no: @boms.p_name_mom)
        @q_order_item = PcbOrderItem.find_by_id(@boms.erp_item_id)
        if not @q_order_item.blank?
            @q_order_sell_item = PcbOrderSellItem.find_by_id(@q_order_item.pcb_order_sell_item_id)
        end

        @user_do = "7"
        @bom_item = MokoBomItem.where(moko_bom_info_id: params[:bom_id])
        


        if  params[:ajax]
            @bomitem = MokoBomItem.find_by_sql("SELECT id,mpn,part_code,quantity,price,(price*quantity) AS total,mf,dn FROM bom_items WHERE bom_items.id = '#{params[:ajax]}'").first
            render "viewbom.js.erb"
            return false
        end
=begin
        if @boms.p_name.blank?
            @bom = Bom.find(params[:bom_id])
            redirect_to select_column_path(bom: @bom)
            return false
        elsif @boms.pcb_file.blank? or params[:bak] or params[:add_bom]
            if not params[:add_bom].blank?
                if not params[:state_flow].blank?
                    @type_b = "[&quot;"
                    all_type_b = MokoPartsType.find_by_sql("SELECT moko_parts_types.part_name_type_b_name,moko_parts_types.part_name_type_b_sname FROM moko_parts_types GROUP BY moko_parts_types.part_name_type_b_name")
                    all_type_b.each do |type_b|
                        @type_b += "&quot;,&quot;" + type_b.part_name_type_b_name.to_s
                    end
        @type_b += "&quot;]"
                    @pi_info = PiInfo.find_by_id(params[:pi_info_id])
                    render "bom_viewbom_order_center.html.erb" and return
                else
                    render "bom_viewbom.html.erb" and return
                end
            else
                if not @bom_item.blank?
                    @bom_item = @bom_item.select {|item| item.quantity != 0 }
                end
                render "p_viewbom.html.erb"  and return
            end
            return false  
        else
            @shipping_info = ShippingInfo.where(user_id: current_user.id)
            render "submit_order.html.erb" and return
            return false
        end
=end
    end


    def p_viewbom 
        #if DigikeysStock.find_by(manufacturer_part_number: '798-ZX80-B-5SA').blank?
            #Rails.logger.info("--------------------------hahahahah")
        #end
        #wcwc=(DigikeysStock.find_by(manufacturer_part_number: '798-ZX80-B-5SA').others.include?'<name>Tolerance</name><value>')? (DigikeysStock.find_by(manufacturer_part_number: '798-ZX80-B-5SA').others.split('<name>Tolerance</name><value>')[-1].split('</value>')[0].to_s):'bb'
        #wcwc=(DigikeysStock.find_by(manufacturer_part_number: 'ft230xs-r').others.include?"<name>Tolerance</name><value>")? "cc":"bb"
        @pdn = PDn.new
        @mpninfo = "SP1007-01WTG"
        #@mpninfo = Digikey.find(1)   
        Rails.logger.info("--------------------------")
        #Rails.logger.info(wcwc)
        Rails.logger.info("--------------------------")  
        @all_dn = "[&quot;"
        all_s_dn = AllDn.find_by_sql("SELECT DISTINCT all_dns.dn FROM all_dns GROUP BY all_dns.dn")
        all_s_dn.each do |dn|
            @all_dn += "&quot;,&quot;" + dn.dn.to_s
        end
        @all_dn += "&quot;]"
=begin
        @bom_version = nil
        if not params[:bom_version].blank?
            @bom_version = params[:bom_version]
            @boms = ProcurementVersionBom.find_by_id(params[:bom_id])
            if can? :work_g_all, :all
                @user_do = "7"
                @bom_item = PVersionItem.where(procurement_version_bom_id: params[:bom_id])
            elsif can? :work_g_a, :all
                @user_do = "77"
                @bom_item = PVersionItem.where(procurement_version_bom_id: params[:bom_id])            
            elsif can? :work_g_b, :all
                @user_do = "75"
                @bom_item = PVersionItem.where("procurement_version_id = #{params[:bom_id]} AND (user_do = '75' OR user_do = '9999')")
            elsif can? :work_g_c, :all
                @user_do = "9999"
                @bom_item = PVersionItem.where("procurement_version_id = #{params[:bom_id]} AND user_do = '9999'")
            elsif can? :work_d, :all
                @user_do = "7"
                @bom_item = PVersionItem.where(procurement_version_bom_id: params[:bom_id])
            end
        else
=end
        @boms = ProcurementBom.find_by_id(params[:bom_id])
        @bom_item_new = PItem.where(procurement_bom_id: params[:bom_id],add_state: "new")
        @q_order = PcbOrder.find_by(order_no: @boms.p_name_mom)
        @q_order_item = PcbOrderItem.find_by_id(@boms.erp_item_id)
        if not @q_order_item.blank?
            @q_order_sell_item = PcbOrderSellItem.find_by_id(@q_order_item.pcb_order_sell_item_id)
        end
        if can? :work_g_all, :all
            @user_do = "7"
            @bom_item = PItem.where(procurement_bom_id: params[:bom_id],add_state: "")
        elsif can? :work_g_a, :all
            @user_do = "77"
            @bom_item = PItem.where(procurement_bom_id: params[:bom_id],add_state: "")
            #@bom_item = PItem.where("procurement_bom_id = #{params[:bom_id]} AND (user_do = '77' OR user_do = '9999')")
        elsif can? :work_g_b, :all
            @user_do = "75"
            @bom_item = PItem.where("procurement_bom_id = #{params[:bom_id]} AND add_state = '' AND (user_do = '75' OR user_do = '9999')")
        elsif can? :work_g_c, :all
            @user_do = "9999"
            @bom_item = PItem.where("procurement_bom_id = #{params[:bom_id]} AND add_state = '' AND user_do = '9999'")
        elsif can? :work_d, :all
            @user_do = "7"
            @bom_item = PItem.where(procurement_bom_id: params[:bom_id],add_state: "")
            
                #Rails.logger.info("--------------------------1")
                #Rails.logger.info(@bom_item.inspect)
                #Rails.logger.info("--------------------------1")
        end

        #@user_do = "7"
        #@bom_item = PItem.where(procurement_bom_id: params[:bom_id])
        if  params[:ajax]
            @bomitem = PItem.find_by_sql("SELECT id,mpn,part_code,quantity,price,(price*quantity) AS total,mf,dn FROM bom_items WHERE bom_items.id = '#{params[:ajax]}'").first
            render "viewbom.js.erb"
            return false
        end
        if @boms.p_name.blank?
            @bom = Bom.find(params[:bom_id])
            #if @bom.excel_file_identifier.split('.')[-1] == 'xls'
	        #@xls_file = Roo::Excel.new(@bom.excel_file.current_path)
            #else
                #@xls_file = Roo::Excelx.new(@bom.excel_file.current_path)
            #end
            #@sheet = @xls_file.sheet(0)
            #render "select_column.html.erb"
            redirect_to select_column_path(bom: @bom)
            return false
        elsif @boms.pcb_file.blank? or params[:bak] or params[:add_bom]
            
            #if can? :work_d, :all
            if not params[:add_bom].blank?
                if not params[:state_flow].blank?
                    @type_b = "[&quot;"
                    all_type_b = MokoPartsType.find_by_sql("SELECT moko_parts_types.part_name_type_b_name,moko_parts_types.part_name_type_b_sname FROM moko_parts_types GROUP BY moko_parts_types.part_name_type_b_name")
                    all_type_b.each do |type_b|
                        @type_b += "&quot;,&quot;" + type_b.part_name_type_b_name.to_s
                    end
        @type_b += "&quot;]"
                    @pi_info = PiInfo.find_by_id(params[:pi_info_id])
                    render "bom_viewbom_order_center.html.erb" and return
                else
                    render "bom_viewbom.html.erb" and return
                end
            else
                if not @bom_item.blank?
                    @bom_item = @bom_item.select {|item| item.quantity != 0 }
                end
                render "p_viewbom.html.erb"  and return
            end
            return false  
        else
            @shipping_info = ShippingInfo.where(user_id: current_user.id)
            render "submit_order.html.erb" and return
            return false
        end
    end

    def moko_bom_list
        if can? :work_d, :all
            order_ctl = ",`created_at` DESC"
        else
            order_ctl = ",`bom_team_ck_at` DESC"
        end  
        @boms = MokoBomInfo.find_by_sql("SELECT * FROM `moko_bom_infos` WHERE `moko_state` = 'active' ORDER BY `created_at` DESC ").paginate(:page => params[:page], :per_page => 25)
    end

    def p_bomlist  
=begin
        bomall = ProcurementBom.all
        bomall.each do |abc|
            check_blue = PItem.where("procurement_bom_id='#{abc.id}' AND color<>'b' AND quantity > 0")
            if check_blue.blank?
                abc.state = "done"
                abc.save
            end
        end
=end
        if can? :work_d, :all
            order_ctl = ",`created_at` DESC"
        else
            order_ctl = ",`bom_team_ck_at` DESC"
        end  
        if params[:order_list]
            @boms = ProcurementBom.find_by_sql("SELECT * FROM `procurement_boms` WHERE `name` IS NULL AND `order_do` = 'do' ORDER BY `check` DESC #{order_ctl} ").paginate(:page => params[:page], :per_page => 12)
            render "p_order_list.html.erb"
        else
            if params[:key_order]
                @key_order = params[:key_order].strip
                @boms = ProcurementBom.find_by_sql("SELECT * FROM `procurement_boms` WHERE (`p_name` LIKE '%#{params[:key_order].strip}%' OR `excel_file` LIKE '%#{params[:key_order].strip}%') AND `name` IS NULL AND `order_do` IS NULL ORDER BY `check` DESC #{order_ctl} ").paginate(:page => params[:page], :per_page => 15)
            else
                if params[:complete]
                    #boms = ProcurementBom.find_by_sql("SELECT * FROM `procurement_boms` WHERE no IS NOT NULL AND p_name IS NOT NULL AND  remark_to_sell IS NULL ORDER BY `check` DESC #{order_ctl} ").select{|item| PItem.where("procurement_bom_id = #{item.id} AND quantity <> 0 AND (color <> 'b' OR color IS NULL)").blank? }
                    #@boms = boms.paginate(:page => params[:page], :per_page => 15)
                    @boms = ProcurementBom.find_by_sql("SELECT * FROM `procurement_boms` WHERE `name` IS NULL AND `order_do` IS NULL AND `bom_team_ck` = 'do'AND state = 'done' AND  remark_to_sell IS NULL ORDER BY `check` DESC #{order_ctl} ").paginate(:page => params[:page], :per_page => 15)
                elsif params[:undone]
                    #boms = ProcurementBom.find_by_sql("SELECT * FROM `procurement_boms` WHERE `name` IS NULL AND `order_do` IS NULL AND `bom_team_ck` = 'do' ORDER BY `check` DESC #{order_ctl} ").select{|item| not PItem.where("procurement_bom_id = #{item.id} AND quantity <> 0 AND (color <> 'b' OR color IS NULL)").blank?  }
                    @boms = ProcurementBom.find_by_sql("SELECT * FROM `procurement_boms` WHERE `name` IS NULL AND `order_do` IS NULL AND `bom_team_ck` = 'do'AND state = '' ORDER BY `check` DESC #{order_ctl} ").paginate(:page => params[:page], :per_page => 15)
                elsif params[:sent_to_sell]
                    @boms = ProcurementBom.find_by_sql("SELECT * FROM `procurement_boms` WHERE `remark_to_sell` = 'mark' ORDER BY `check` DESC #{order_ctl} ").paginate(:page => params[:page], :per_page => 15)
                else
                    @boms = ProcurementBom.find_by_sql("SELECT * FROM `procurement_boms` WHERE `name` IS NULL AND `order_do` IS NULL ORDER BY `check` DESC #{order_ctl} ").paginate(:page => params[:page], :per_page => 15)
                end
            end
        end
    end

    def search_m
        if cookies.permanent[:educator_locale].to_s == "zh"
            part_name_locale = "part_name"
        elsif cookies.permanent[:educator_locale].to_s == "en"
            part_name_locale = "part_name_en"
        end
        @bom_item = PItem.find(params[:id])
        
        #params[:q]=@bom_item.description
	params[:p]=@bom_item.part_code
        if not params[:q].blank?
            des = params[:q].strip.split(" ")
            where_des = ""
            des.each_with_index do |de,index|
                where_des += "products.description LIKE '%#{de}%'"
                if des.size > (index + 1)
                    where_des += " AND "
                end
            end      
        end
        if params[:part_name].nil? and params[:package2].nil?
	    @ptype = ""
            @package2 = ""
	elsif params[:package2].nil?
	    @ptype = params[:part_name]
                #@ptype = ""
	    @package2 = ""
	elsif params[:part_name].nil?
	    @ptype = ""
	    @package2 = params[:package2]
	else
	    @ptype = params[:part_name]
                #@ptype = ""
	    @package2 = params[:package2]
	end
        Rails.logger.info("--------------------------")
        #Rails.logger.info(@package2.inspect)
        Rails.logger.info("--------------------------")
        if  @package2 != ""
            find_bom = " AND `package2` = '"+@package2+"' "
        else
            find_bom = " "
        end
        if  @ptype != ""
            find_ptype = " AND "+part_name_locale+" = '"+@ptype+"' "
        else
            find_ptype = " "
        end
        #@match_products = Product.find_by_sql("SELECT * FROM `products` WHERE `description` LIKE '%#{des}%' " + find_ptype +  find_bom).to_ary
        @match_products = Product.find_by_sql("SELECT DISTINCT products.name,products.* FROM products LEFT JOIN all_dns ON products.`name` = all_dns.part_code WHERE #{where_des} #{find_ptype} #{find_bom} ").to_ary
        @counted = Hash.new(0)
        @match_products.each { |h| @counted[h[part_name_locale]] += 1 }
        @counted = Hash[@counted.map {|k,v| [k,v.to_s] }]	
        
        @counted1 = Hash.new(0)
        @match_products.each { |h| @counted1[h["package2"]] += 1 }
        @counted1 = Hash[@counted1.map {|k,v| [k,v.to_s] }]	
        if user_signed_in?
            if current_user.email == "web@mokotechnology.com"
                @bom_html = ""
                unless @match_products.nil?
                    #@match_products[0..19].each do |item|
                    @match_products.each do |item|
                        @bom_html = @bom_html + "<tr>"

                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>#{item.name.to_s}</div></a>"
                        
                        @bom_html = @bom_html + "</td>"

                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>#{item.description.to_s}</div></a>"
                        
                        @bom_html = @bom_html + "</td>"
=begin
                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>#{ActionController::Base.helpers.number_with_precision(item.min_price, precision: 4).to_s}</div></a>"
                        @bom_html = @bom_html + "</td>"
=end                       
                        #part_code = Product.find(params[:product_id]).name
                        #all_dns = AllDn.where(part_code: part_code).order('date DESC')
                        all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{item.name}' AND all_dns.qty >= 100 ORDER BY all_dns.date DESC").first
                        if all_dns.blank?
                            all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{item.name}' ORDER BY all_dns.date DESC").first
                            if all_dns.blank?
                                @bom_html += "<td width='50'>无</td>"
                                @bom_html += "<td width='100'>无</td>"
                                @bom_html += "<td width='50'>无</td>"
                                @bom_html += "<td width='80'>无</td>"
                            else
                                @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>" + all_dns.date.localtime.strftime("%y-%m").to_s + "</div></a></small></td>"                
                                @bom_html += "<td width='100' title='"+all_dns.dn_long.to_s+"'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>" + all_dns.dn.to_s + "</div></a></small></td>"
                                @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>"+all_dns.qty.to_s+"</div></a></small></td>"
                                @bom_html += "<td width='80'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>￥"+all_dns.price.to_s+"</div></a></small></td>"                     
                            end
                        else
                            @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>" + all_dns.date.localtime.strftime("%y-%m").to_s + "</div></a></small></td>"
                            @bom_html += "<td width='100' title='"+all_dns.dn_long.to_s+"'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>" + all_dns.dn.to_s + "</div></a></small></td>"
                            @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>"+all_dns.qty.to_s+"</div></a></small></td>"
                            @bom_html += "<td width='80'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>￥"+all_dns.price.to_s+"</div></a></small></td>"

                        end
                        

                        
                        
                        
                        

                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>OK</div></a>"
                        @bom_html = @bom_html + "</td>"

                        @bom_html = @bom_html + "</tr>"
                    end           
                end
            else
                @bom_html = ""
                unless @match_products.nil?
                    #@match_products[0..19].each do |item|
                    @match_products.each do |item|
                        @bom_html = @bom_html + "<tr>"
                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>#{item.name.to_s}</div></a>"
                       
                        @bom_html = @bom_html + "</td>"
                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>#{item.description.to_s}</div></a>"
                       
                        @bom_html = @bom_html + "</td>"
=begin
                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>#{ActionController::Base.helpers.number_with_precision(item.min_price, precision: 4).to_s}</div></a>"
                        @bom_html = @bom_html + "</td>"
=end
                        all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{item.name}' AND all_dns.qty >= 100 ORDER BY all_dns.date DESC").first
                        if all_dns.blank?
                            all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{item.name}' ORDER BY all_dns.date DESC").first

                            if all_dns.blank?
                                @bom_html += "<td width='50'>无</td>"
                                @bom_html += "<td width='100'>无</td>"
                                @bom_html += "<td width='50'>无</td>"
                                @bom_html += "<td width='80'>无</td>"
                            else
                                @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>" + all_dns.date.localtime.strftime("%y-%m").to_s + "</div></a></small></td>"
                                @bom_html += "<td width='100' title='"+all_dns.dn_long.to_s+"'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>" + all_dns.dn.to_s + "</div></a></small></td>"
                                @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>"+all_dns.qty.to_s+"</div></a></small></td>"
                                @bom_html += "<td width='80'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>￥"+all_dns.price.to_s+"</div></a></small></td>"                             
                            end
                        else
                            @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>" + all_dns.date.localtime.strftime("%y-%m").to_s + "</div></a></small></td>"
                            @bom_html += "<td width='100' title='"+all_dns.dn_long.to_s+"'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>" + all_dns.dn.to_s + "</div></a></small></td>"
                            @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>"+all_dns.qty.to_s+"</div></a></small></td>"
                            @bom_html += "<td width='80'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>￥"+all_dns.price.to_s+"</div></a></small></td>"
                        end
                        

                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>OK</div></a>"
                        @bom_html = @bom_html + "</td>"
                        @bom_html = @bom_html + "</tr>"
                    end           
                end
            end
        end
        
        
        @bom_lab = '<table class="table table-bordered"><thead><tr><td><strong>' + t(:current_search) + '：</strong></td></tr></thead><tbody>'
        unless @package2 and @ptype
            Rails.logger.info("--------------------------aaaa")
            @bom_lab = @bom_lab + "<tr><td>" + t(:category) + "：" 
            unless @counted.nil?
                Rails.logger.info("--------------------------bbbb")
                @counted.each do |key, value|
                    #<%= link_to "#{key}",  edit_bom_item_path(@bom_item, :part_name =>key, :q =>params[:q], :p =>params[:p]) %>
                    Rails.logger.info("--------------------------")
                    Rails.logger.info(params[:q].inspect)
                    Rails.logger.info(params[:p].inspect)
                    Rails.logger.info(key.inspect)
                    Rails.logger.info("--------------------------")
                    @bom_lab = @bom_lab + '<a data-remote="true" href="/search_m' + "?id=" + @bom_item.id.to_s + "&amp;p=" + params[:p].to_s + "&amp;part_name=" + key + "&amp;q=" + params[:q].to_s + "&amp;bomsuse=bomsuse" + '">' + key.to_s + "</a>"
                    @bom_lab = @bom_lab + '<span class="badge">' + value.to_s + '</span>'
                end
            end 
            @bom_lab = @bom_lab + "</td></tr>"
        
            @bom_lab = @bom_lab + "<tr><td>" + t(:packaging) + "： "
            unless @counted1.nil?
                Rails.logger.info("--------------------------ccccc")
                @counted1.each do |key, value| 
                    #<%= link_to "#{key}",  edit_bom_item_path(@bom_item, :package2 =>key, :q =>params[:q], :p =>params[:p]) %>
                    #<a href="/bom_item/8315/edit?p=C6-1%2CC7-1%2CC67-1%2CC68-1&amp;package2=0402&amp;q=CAP+CER+10PF+16V+NP0+0402">0402</a>
                    @bom_lab = @bom_lab + '<a data-remote="true" href="/search_m' + "?id=" + @bom_item.id.to_s + "&amp;p=" + params[:p].to_s + "&amp;package2=" + key.to_s + "&amp;q=" + params[:q].to_s + "&amp;bomsuse=bomsuse" + '">' + key.to_s + "</a>"
                    @bom_lab = @bom_lab + '<span class="badge">' + value.to_s + '</span>'
                end
            end
            @bom_lab = @bom_lab + "</td></tr>"
        else
            Rails.logger.info("--------------------------dddddd")
            @bom_lab = @bom_lab + "<tr><td>" + t(:category) + "： "
            unless @counted.nil? 
                Rails.logger.info("--------------------------eeeee")
                @counted.each do |key, value| 
                    #<%= link_to "#{key}",  edit_bom_item_path(@bom_item, :part_name =>key, :q =>params[:q], :p =>params[:p]) %> 
                    Rails.logger.info("--------------------------")
                    Rails.logger.info(key.inspect)
                    Rails.logger.info(value.inspect)
                    Rails.logger.info("--------------------------")
                    @bom_lab = @bom_lab + '<a data-remote="true" href="/search_m' + "?id=" + @bom_item.id.to_s + "&amp;part_name=" + key.to_s + "&amp;q=" + params[:q].to_s + "&amp;bomsuse=bomsuse" + '">' + key + "</a>"
                    @bom_lab = @bom_lab + '<span class="badge">' + value.to_s + '</span>'
                end
            end
            @bom_lab = @bom_lab + "</td></tr>"
            @bom_lab = @bom_lab + "<tr><td>" + t(:packaging) + "："
            unless @counted1.nil?
                Rails.logger.info("--------------------------fffff")
                @counted1.each do |key, value|
                    #<%= link_to "#{key}",  edit_bom_item_path(@bom_item, :package2 =>key, :part_name =>@ptype, :q =>params[:q], :p =>params[:p]) %>
                    @bom_lab = @bom_lab + '<a data-remote="true" href="/search_m' + "?id=" + @bom_item.id.to_s + "&amp;package2=" + key.to_s + "&amp;q=" + params[:q].to_s + "&amp;part_name=" + @ptype + "&amp;bomsuse=bomsuse" + '">' + key.to_s + "</a>"
                    @bom_lab = @bom_lab + '<span class="badge">' + value.to_s + '</span>'
                end
            end
            @bom_lab = @bom_lab + "</td></tr>"
        end
        @bom_lab = @bom_lab + "</tbody></table>"
        Rails.logger.info("--------------------------1111")
        Rails.logger.info(@bom_lab.inspect)
        #Rails.logger.info(@bom_html.inspect)
        Rails.logger.info("--------------------------2222")
    end

    def search_m_ecn
        if cookies.permanent[:educator_locale].to_s == "zh"
            part_name_locale = "part_name"
        elsif cookies.permanent[:educator_locale].to_s == "en"
            part_name_locale = "part_name_en"
        end
        #@bom_item = PItem.find(params[:id])
        
	#params[:p]=@bom_item.part_code

        if not params[:q].blank?
            des = params[:q].strip.split(" ")
            where_des = ""
            des.each_with_index do |de,index|
                where_des += "products.description LIKE '%#{de}%'"
                if des.size > (index + 1)
                    where_des += " AND "
                end
            end      
        end
        if params[:part_name].nil? and params[:package2].nil?
	    @ptype = ""
            @package2 = ""
	elsif params[:package2].nil?
	    @ptype = params[:part_name]
                #@ptype = ""
	    @package2 = ""
	elsif params[:part_name].nil?
	    @ptype = ""
	    @package2 = params[:package2]
	else
	    @ptype = params[:part_name]
                #@ptype = ""
	    @package2 = params[:package2]
	end
        Rails.logger.info("--------------------------")
        #Rails.logger.info(@package2.inspect)
        Rails.logger.info("--------------------------")
        if  @package2 != ""
            find_bom = " AND `package2` = '"+@package2+"' "
        else
            find_bom = " "
        end
        if  @ptype != ""
            find_ptype = " AND "+part_name_locale+" = '"+@ptype+"' "
        else
            find_ptype = " "
        end
        #@match_products = Product.find_by_sql("SELECT * FROM `products` WHERE `description` LIKE '%#{des}%' " + find_ptype +  find_bom).to_ary
        @match_products = Product.find_by_sql("SELECT DISTINCT products.name,products.* FROM products LEFT JOIN all_dns ON products.`name` = all_dns.part_code WHERE #{where_des} #{find_ptype} #{find_bom} ").to_ary
        @counted = Hash.new(0)
        @match_products.each { |h| @counted[h[part_name_locale]] += 1 }
        @counted = Hash[@counted.map {|k,v| [k,v.to_s] }]	
        
        @counted1 = Hash.new(0)
        @match_products.each { |h| @counted1[h["package2"]] += 1 }
        @counted1 = Hash[@counted1.map {|k,v| [k,v.to_s] }]	
        if user_signed_in?
            if current_user.email == "web@mokotechnology.com"
                @bom_html = ""
                unless @match_products.nil?
                    #@match_products[0..19].each do |item|
                    @match_products.each do |item|
                        @bom_html = @bom_html + "<tr>"

                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/set_ecn?product_id="+ item.id.to_s + "'><div>#{item.name.to_s}</div></a>"
                        
                        @bom_html = @bom_html + "</td>"

                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/set_ecn?product_id="+ item.id.to_s + "'><div>#{item.description.to_s}</div></a>"
                        
                        @bom_html = @bom_html + "</td>"
=begin
                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>#{ActionController::Base.helpers.number_with_precision(item.min_price, precision: 4).to_s}</div></a>"
                        @bom_html = @bom_html + "</td>"
=end                       
                        #part_code = Product.find(params[:product_id]).name
                        #all_dns = AllDn.where(part_code: part_code).order('date DESC')
                        all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{item.name}' AND all_dns.qty >= 100 ORDER BY all_dns.date DESC").first
                        if all_dns.blank?
                            all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{item.name}' ORDER BY all_dns.date DESC").first
                            if all_dns.blank?
                                @bom_html += "<td width='50'>无</td>"
                                @bom_html += "<td width='100'>无</td>"
                                @bom_html += "<td width='50'>无</td>"
                                @bom_html += "<td width='80'>无</td>"
                            else
                                @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/set_ecn?product_id="+ item.id.to_s + "' ><div>" + all_dns.date.localtime.strftime("%y-%m").to_s + "</div></a></small></td>"                
                                @bom_html += "<td width='100' title='"+all_dns.dn_long.to_s+"'><small><a rel='nofollow' data-method='get' data-remote='true' href='/set_ecn?product_id="+ item.id.to_s + "' ><div>" + all_dns.dn.to_s + "</div></a></small></td>"
                                @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/set_ecn?product_id="+ item.id.to_s + "' ><div>"+all_dns.qty.to_s+"</div></a></small></td>"
                                @bom_html += "<td width='80'><small><a rel='nofollow' data-method='get' data-remote='true' href='/set_ecn?product_id="+ item.id.to_s + "' ><div>￥"+all_dns.price.to_s+"</div></a></small></td>"                     
                            end
                        else
                            @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/set_ecn?product_id="+ item.id.to_s + "' ><div>" + all_dns.date.localtime.strftime("%y-%m").to_s + "</div></a></small></td>"
                            @bom_html += "<td width='100' title='"+all_dns.dn_long.to_s+"'><small><a rel='nofollow' data-method='get' data-remote='true' href='/set_ecn?product_id="+ item.id.to_s + "' ><div>" + all_dns.dn.to_s + "</div></a></small></td>"
                            @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/set_ecn?product_id="+ item.id.to_s + "' ><div>"+all_dns.qty.to_s+"</div></a></small></td>"
                            @bom_html += "<td width='80'><small><a rel='nofollow' data-method='get' data-remote='true' href='/set_ecn?product_id="+ item.id.to_s + "' ><div>￥"+all_dns.price.to_s+"</div></a></small></td>"

                        end
                        

                        
                        
                        
                        

                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/set_ecn?product_id="+ item.id.to_s + "'><div>OK</div></a>"
                        @bom_html = @bom_html + "</td>"

                        @bom_html = @bom_html + "</tr>"
                    end           
                end
            else
                @bom_html = ""
                unless @match_products.nil?
                    #@match_products[0..19].each do |item|
                    @match_products.each do |item|
                        @bom_html = @bom_html + "<tr>"
                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/set_ecn?product_id="+ item.id.to_s + "'><div>#{item.name.to_s}</div></a>"
                       
                        @bom_html = @bom_html + "</td>"
                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/set_ecn?product_id="+ item.id.to_s + "'><div>#{item.description.to_s}</div></a>"
                       
                        @bom_html = @bom_html + "</td>"
=begin
                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>#{ActionController::Base.helpers.number_with_precision(item.min_price, precision: 4).to_s}</div></a>"
                        @bom_html = @bom_html + "</td>"
=end
                        all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{item.name}' AND all_dns.qty >= 100 ORDER BY all_dns.date DESC").first
                        if all_dns.blank?
                            all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{item.name}' ORDER BY all_dns.date DESC").first

                            if all_dns.blank?
                                @bom_html += "<td width='50'>无</td>"
                                @bom_html += "<td width='100'>无</td>"
                                @bom_html += "<td width='50'>无</td>"
                                @bom_html += "<td width='80'>无</td>"
                            else
                                @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/set_ecn?product_id="+ item.id.to_s + "' ><div>" + all_dns.date.localtime.strftime("%y-%m").to_s + "</div></a></small></td>"
                                @bom_html += "<td width='100' title='"+all_dns.dn_long.to_s+"'><small><a rel='nofollow' data-method='get' data-remote='true' href='/set_ecn?product_id="+ item.id.to_s + "' ><div>" + all_dns.dn.to_s + "</div></a></small></td>"
                                @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/set_ecn?product_id="+ item.id.to_s + "' ><div>"+all_dns.qty.to_s+"</div></a></small></td>"
                                @bom_html += "<td width='80'><small><a rel='nofollow' data-method='get' data-remote='true' href='/set_ecn?product_id="+ item.id.to_s + "' ><div>￥"+all_dns.price.to_s+"</div></a></small></td>"                             
                            end
                        else
                            @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/set_ecn?product_id="+ item.id.to_s + "' ><div>" + all_dns.date.localtime.strftime("%y-%m").to_s + "</div></a></small></td>"
                            @bom_html += "<td width='100' title='"+all_dns.dn_long.to_s+"'><small><a rel='nofollow' data-method='get' data-remote='true' href='/set_ecn?product_id="+ item.id.to_s + "' ><div>" + all_dns.dn.to_s + "</div></a></small></td>"
                            @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/set_ecn?product_id="+ item.id.to_s + "' ><div>"+all_dns.qty.to_s+"</div></a></small></td>"
                            @bom_html += "<td width='80'><small><a rel='nofollow' data-method='get' data-remote='true' href='/set_ecn?product_id="+ item.id.to_s + "' ><div>￥"+all_dns.price.to_s+"</div></a></small></td>"
                        end
                        

                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/set_ecn?product_id="+ item.id.to_s + "'><div>OK</div></a>"
                        @bom_html = @bom_html + "</td>"
                        @bom_html = @bom_html + "</tr>"
                    end           
                end
            end
        end
        
        
        @bom_lab = '<table class="table table-bordered"><thead><tr><td><strong>' + t(:current_search) + '：</strong></td></tr></thead><tbody>'
        unless @package2 and @ptype
            Rails.logger.info("--------------------------aaaa")
            @bom_lab = @bom_lab + "<tr><td>" + t(:category) + "：" 
            unless @counted.nil?
                Rails.logger.info("--------------------------bbbb")
                @counted.each do |key, value|
                    #<%= link_to "#{key}",  edit_bom_item_path(@bom_item, :part_name =>key, :q =>params[:q], :p =>params[:p]) %>
                    Rails.logger.info("--------------------------")
                    Rails.logger.info(params[:q].inspect)
                    Rails.logger.info(params[:p].inspect)
                    Rails.logger.info(key.inspect)
                    Rails.logger.info("--------------------------")
                    @bom_lab = @bom_lab + '<a data-remote="true" href="/search_m_ecn' + "?p=" + params[:p].to_s + "&amp;part_name=" + key + "&amp;q=" + params[:q].to_s + "&amp;bomsuse=bomsuse" + '">' + key.to_s + "</a>"
                    @bom_lab = @bom_lab + '<span class="badge">' + value.to_s + '</span>'
                end
            end 
            @bom_lab = @bom_lab + "</td></tr>"
        
            @bom_lab = @bom_lab + "<tr><td>" + t(:packaging) + "： "
            unless @counted1.nil?
                Rails.logger.info("--------------------------ccccc")
                @counted1.each do |key, value| 
                    #<%= link_to "#{key}",  edit_bom_item_path(@bom_item, :package2 =>key, :q =>params[:q], :p =>params[:p]) %>
                    #<a href="/bom_item/8315/edit?p=C6-1%2CC7-1%2CC67-1%2CC68-1&amp;package2=0402&amp;q=CAP+CER+10PF+16V+NP0+0402">0402</a>
                    @bom_lab = @bom_lab + '<a data-remote="true" href="/search_m_ecn' + "?p=" + params[:p].to_s + "&amp;package2=" + key.to_s + "&amp;q=" + params[:q].to_s + "&amp;bomsuse=bomsuse" + '">' + key.to_s + "</a>"
                    @bom_lab = @bom_lab + '<span class="badge">' + value.to_s + '</span>'
                end
            end
            @bom_lab = @bom_lab + "</td></tr>"
        else
            Rails.logger.info("--------------------------dddddd")
            @bom_lab = @bom_lab + "<tr><td>" + t(:category) + "： "
            unless @counted.nil? 
                Rails.logger.info("--------------------------eeeee")
                @counted.each do |key, value| 
                    #<%= link_to "#{key}",  edit_bom_item_path(@bom_item, :part_name =>key, :q =>params[:q], :p =>params[:p]) %> 
                    Rails.logger.info("--------------------------")
                    Rails.logger.info(key.inspect)
                    Rails.logger.info(value.inspect)
                    Rails.logger.info("--------------------------")
                    @bom_lab = @bom_lab + '<a data-remote="true" href="/search_m_ecn' + "?part_name=" + key.to_s + "&amp;q=" + params[:q].to_s + "&amp;bomsuse=bomsuse" + '">' + key + "</a>"
                    @bom_lab = @bom_lab + '<span class="badge">' + value.to_s + '</span>'
                end
            end
            @bom_lab = @bom_lab + "</td></tr>"
            @bom_lab = @bom_lab + "<tr><td>" + t(:packaging) + "："
            unless @counted1.nil?
                Rails.logger.info("--------------------------fffff")
                @counted1.each do |key, value|
                    #<%= link_to "#{key}",  edit_bom_item_path(@bom_item, :package2 =>key, :part_name =>@ptype, :q =>params[:q], :p =>params[:p]) %>
                    @bom_lab = @bom_lab + '<a data-remote="true" href="/search_m_ecn' + "?package2=" + key.to_s + "&amp;q=" + params[:q].to_s + "&amp;part_name=" + @ptype + "&amp;bomsuse=bomsuse" + '">' + key.to_s + "</a>"
                    @bom_lab = @bom_lab + '<span class="badge">' + value.to_s + '</span>'
                end
            end
            @bom_lab = @bom_lab + "</td></tr>"
        end
        @bom_lab = @bom_lab + "</tbody></table>"
        Rails.logger.info("--------------------------1111")
        Rails.logger.info(@bom_lab.inspect)
        #Rails.logger.info(@bom_html.inspect)
        Rails.logger.info("--------------------------2222")
    end

    def set_ecn
        if not params[:product_id].blank?
            @get_data = Product.find_by_id(params[:product_id])
        end  
    end

    def search_m_moko
        if cookies.permanent[:educator_locale].to_s == "zh"
            part_name_locale = "part_name"
        elsif cookies.permanent[:educator_locale].to_s == "en"
            part_name_locale = "part_name_en"
        end
        @bom_item = MokoBomItem.find(params[:id])
        
        #params[:q]=@bom_item.description
	params[:p]=@bom_item.part_code
        if not params[:q].blank?
            des = params[:q].strip.split(" ")
            where_des = ""
            des.each_with_index do |de,index|
                where_des += "products.description LIKE '%#{de}%'"
                if des.size > (index + 1)
                    where_des += " AND "
                end
            end      
        end
        if params[:part_name].nil? and params[:package2].nil?
	    @ptype = ""
            @package2 = ""
	elsif params[:package2].nil?
	    @ptype = params[:part_name]
                #@ptype = ""
	    @package2 = ""
	elsif params[:part_name].nil?
	    @ptype = ""
	    @package2 = params[:package2]
	else
	    @ptype = params[:part_name]
                #@ptype = ""
	    @package2 = params[:package2]
	end
        Rails.logger.info("--------------------------")
        #Rails.logger.info(@package2.inspect)
        Rails.logger.info("--------------------------")
        if  @package2 != ""
            find_bom = " AND `package2` = '"+@package2+"' "
        else
            find_bom = " "
        end
        if  @ptype != ""
            find_ptype = " AND "+part_name_locale+" = '"+@ptype+"' "
        else
            find_ptype = " "
        end
        #@match_products = Product.find_by_sql("SELECT * FROM `products` WHERE `description` LIKE '%#{des}%' " + find_ptype +  find_bom).to_ary
        @match_products = Product.find_by_sql("SELECT DISTINCT products.name,products.* FROM products LEFT JOIN all_dns ON products.`name` = all_dns.part_code WHERE #{where_des} #{find_ptype} #{find_bom} ").to_ary
        @counted = Hash.new(0)
        @match_products.each { |h| @counted[h[part_name_locale]] += 1 }
        @counted = Hash[@counted.map {|k,v| [k,v.to_s] }]	
        
        @counted1 = Hash.new(0)
        @match_products.each { |h| @counted1[h["package2"]] += 1 }
        @counted1 = Hash[@counted1.map {|k,v| [k,v.to_s] }]	
        if user_signed_in?
            if current_user.email == "web@mokotechnology.com"
                @bom_html = ""
                unless @match_products.nil?
                    #@match_products[0..19].each do |item|
                    @match_products.each do |item|
                        @bom_html = @bom_html + "<tr>"

                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update_moko?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>#{item.name.to_s}</div></a>"
                        
                        @bom_html = @bom_html + "</td>"

                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update_moko?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>#{item.description.to_s}</div></a>"
                        
                        @bom_html = @bom_html + "</td>"
=begin
                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>#{ActionController::Base.helpers.number_with_precision(item.min_price, precision: 4).to_s}</div></a>"
                        @bom_html = @bom_html + "</td>"
=end                       
                        #part_code = Product.find(params[:product_id]).name
                        #all_dns = AllDn.where(part_code: part_code).order('date DESC')
                        all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{item.name}' AND all_dns.qty >= 100 ORDER BY all_dns.date DESC").first
                        if all_dns.blank?
                            all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{item.name}' ORDER BY all_dns.date DESC").first
                            if all_dns.blank?
                                @bom_html += "<td width='50'>无</td>"
                                @bom_html += "<td width='100'>无</td>"
                                @bom_html += "<td width='50'>无</td>"
                                @bom_html += "<td width='80'>无</td>"
                            else
                                @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update_moko?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>" + all_dns.date.localtime.strftime("%y-%m").to_s + "</div></a></small></td>"                
                                @bom_html += "<td width='100' title='"+all_dns.dn_long.to_s+"'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update_moko?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>" + all_dns.dn.to_s + "</div></a></small></td>"
                                @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update_moko?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>"+all_dns.qty.to_s+"</div></a></small></td>"
                                @bom_html += "<td width='80'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update_moko?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>￥"+all_dns.price.to_s+"</div></a></small></td>"                     
                            end
                        else
                            @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update_moko?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>" + all_dns.date.localtime.strftime("%y-%m").to_s + "</div></a></small></td>"
                            @bom_html += "<td width='100' title='"+all_dns.dn_long.to_s+"'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update_moko?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>" + all_dns.dn.to_s + "</div></a></small></td>"
                            @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update_moko?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>"+all_dns.qty.to_s+"</div></a></small></td>"
                            @bom_html += "<td width='80'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update_moko?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>￥"+all_dns.price.to_s+"</div></a></small></td>"

                        end
                        

                        
                        
                        
                        

                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update_moko?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>OK</div></a>"
                        @bom_html = @bom_html + "</td>"

                        @bom_html = @bom_html + "</tr>"
                    end           
                end
            else
                @bom_html = ""
                unless @match_products.nil?
                    #@match_products[0..19].each do |item|
                    @match_products.each do |item|
                        @bom_html = @bom_html + "<tr>"
                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update_moko?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>#{item.name.to_s}</div></a>"
                       
                        @bom_html = @bom_html + "</td>"
                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update_moko?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>#{item.description.to_s}</div></a>"
                       
                        @bom_html = @bom_html + "</td>"
=begin
                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>#{ActionController::Base.helpers.number_with_precision(item.min_price, precision: 4).to_s}</div></a>"
                        @bom_html = @bom_html + "</td>"
=end
                        all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{item.name}' AND all_dns.qty >= 100 ORDER BY all_dns.date DESC").first
                        if all_dns.blank?
                            all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{item.name}' ORDER BY all_dns.date DESC").first

                            if all_dns.blank?
                                @bom_html += "<td width='50'>无</td>"
                                @bom_html += "<td width='100'>无</td>"
                                @bom_html += "<td width='50'>无</td>"
                                @bom_html += "<td width='80'>无</td>"
                            else
                                @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update_moko?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>" + all_dns.date.localtime.strftime("%y-%m").to_s + "</div></a></small></td>"
                                @bom_html += "<td width='100' title='"+all_dns.dn_long.to_s+"'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update_moko?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>" + all_dns.dn.to_s + "</div></a></small></td>"
                                @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update_moko?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>"+all_dns.qty.to_s+"</div></a></small></td>"
                                @bom_html += "<td width='80'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update_moko?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>￥"+all_dns.price.to_s+"</div></a></small></td>"                             
                            end
                        else
                            @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update_moko?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>" + all_dns.date.localtime.strftime("%y-%m").to_s + "</div></a></small></td>"
                            @bom_html += "<td width='100' title='"+all_dns.dn_long.to_s+"'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update_moko?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>" + all_dns.dn.to_s + "</div></a></small></td>"
                            @bom_html += "<td width='50'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update_moko?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>"+all_dns.qty.to_s+"</div></a></small></td>"
                            @bom_html += "<td width='80'><small><a rel='nofollow' data-method='get' data-remote='true' href='/p_update_moko?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse' ><div>￥"+all_dns.price.to_s+"</div></a></small></td>"
                        end
                        

                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update_moko?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>OK</div></a>"
                        @bom_html = @bom_html + "</td>"
                        @bom_html = @bom_html + "</tr>"
                    end           
                end
            end
        end
        
        
        @bom_lab = '<table class="table table-bordered"><thead><tr><td><strong>' + t(:current_search) + '：</strong></td></tr></thead><tbody>'
        unless @package2 and @ptype
            Rails.logger.info("--------------------------aaaa")
            @bom_lab = @bom_lab + "<tr><td>" + t(:category) + "：" 
            unless @counted.nil?
                Rails.logger.info("--------------------------bbbb")
                @counted.each do |key, value|
                    #<%= link_to "#{key}",  edit_bom_item_path(@bom_item, :part_name =>key, :q =>params[:q], :p =>params[:p]) %>
                    Rails.logger.info("--------------------------")
                    Rails.logger.info(params[:q].inspect)
                    Rails.logger.info(params[:p].inspect)
                    Rails.logger.info(key.inspect)
                    Rails.logger.info("--------------------------")
                    @bom_lab = @bom_lab + '<a data-remote="true" href="/search_m_moko' + "?id=" + @bom_item.id.to_s + "&amp;p=" + params[:p].to_s + "&amp;part_name=" + key + "&amp;q=" + params[:q].to_s + "&amp;bomsuse=bomsuse" + '">' + key.to_s + "</a>"
                    @bom_lab = @bom_lab + '<span class="badge">' + value.to_s + '</span>'
                end
            end 
            @bom_lab = @bom_lab + "</td></tr>"
        
            @bom_lab = @bom_lab + "<tr><td>" + t(:packaging) + "： "
            unless @counted1.nil?
                Rails.logger.info("--------------------------ccccc")
                @counted1.each do |key, value| 
                    #<%= link_to "#{key}",  edit_bom_item_path(@bom_item, :package2 =>key, :q =>params[:q], :p =>params[:p]) %>
                    #<a href="/bom_item/8315/edit?p=C6-1%2CC7-1%2CC67-1%2CC68-1&amp;package2=0402&amp;q=CAP+CER+10PF+16V+NP0+0402">0402</a>
                    @bom_lab = @bom_lab + '<a data-remote="true" href="/search_m_moko' + "?id=" + @bom_item.id.to_s + "&amp;p=" + params[:p].to_s + "&amp;package2=" + key.to_s + "&amp;q=" + params[:q].to_s + "&amp;bomsuse=bomsuse" + '">' + key.to_s + "</a>"
                    @bom_lab = @bom_lab + '<span class="badge">' + value.to_s + '</span>'
                end
            end
            @bom_lab = @bom_lab + "</td></tr>"
        else
            Rails.logger.info("--------------------------dddddd")
            @bom_lab = @bom_lab + "<tr><td>" + t(:category) + "： "
            unless @counted.nil? 
                Rails.logger.info("--------------------------eeeee")
                @counted.each do |key, value| 
                    #<%= link_to "#{key}",  edit_bom_item_path(@bom_item, :part_name =>key, :q =>params[:q], :p =>params[:p]) %> 
                    Rails.logger.info("--------------------------")
                    Rails.logger.info(key.inspect)
                    Rails.logger.info(value.inspect)
                    Rails.logger.info("--------------------------")
                    @bom_lab = @bom_lab + '<a data-remote="true" href="/search_m_moko' + "?id=" + @bom_item.id.to_s + "&amp;part_name=" + key.to_s + "&amp;q=" + params[:q].to_s + "&amp;bomsuse=bomsuse" + '">' + key + "</a>"
                    @bom_lab = @bom_lab + '<span class="badge">' + value.to_s + '</span>'
                end
            end
            @bom_lab = @bom_lab + "</td></tr>"
            @bom_lab = @bom_lab + "<tr><td>" + t(:packaging) + "："
            unless @counted1.nil?
                Rails.logger.info("--------------------------fffff")
                @counted1.each do |key, value|
                    #<%= link_to "#{key}",  edit_bom_item_path(@bom_item, :package2 =>key, :part_name =>@ptype, :q =>params[:q], :p =>params[:p]) %>
                    @bom_lab = @bom_lab + '<a data-remote="true" href="/search_m_moko' + "?id=" + @bom_item.id.to_s + "&amp;package2=" + key.to_s + "&amp;q=" + params[:q].to_s + "&amp;part_name=" + @ptype + "&amp;bomsuse=bomsuse" + '">' + key.to_s + "</a>"
                    @bom_lab = @bom_lab + '<span class="badge">' + value.to_s + '</span>'
                end
            end
            @bom_lab = @bom_lab + "</td></tr>"
        end
        @bom_lab = @bom_lab + "</tbody></table>"
        Rails.logger.info("--------------------------1111")
        Rails.logger.info(@bom_lab.inspect)
        #Rails.logger.info(@bom_html.inspect)
        Rails.logger.info("--------------------------2222")
        render "search_m.js.erb"
    end



    def p_update_moko
        if not params[:product_id].blank?

            part_code = Product.find(params[:product_id]).name
            #all_dns = AllDn.where(part_code: part_code).order('date DESC')
            all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{part_code}' AND all_dns.qty >= 100 ORDER BY all_dns.date DESC").first
            if all_dns.blank?
                Rails.logger.info("ttttttttttttt--------------------------1111")
                all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{part_code}' ORDER BY all_dns.date DESC").first
            end
            #all_dns.each do |dns|

            
            @bom_item = MokoBomItem.find(params[:id]) #取回p_items表bomitem记录，在解析bom是存入，可能没有匹配到product
            @bom = MokoBomInfo.find(@bom_item.moko_bom_info_id)
            


            @bom_item = MokoBomItem.find(params[:id]) #取回p_items表bomitem记录，在解析bom是存入，可能没有匹配到product
            @bom = MokoBomInfo.find(@bom_item.moko_bom_info_id)
           
            if @bom_item.update_attribute("product_id", params[:product_id])
                if @bom_item.product_id
	            bom_item_product = Product.find(@bom_item.product_id)
                    @bom_item.moko_part = bom_item_product.name
                    @bom_item.moko_des = bom_item_product.description
                    @bom_item.warn = false

                    @bom_item.mark = false
                    @bom_item.manual = true
                    @bom_item.mpn_id = nil
                    #@bom_item.mpn = nil
                    
                    @bom_item.user_do_change = nil
	            @bom_item.save!
  
   
                    #累加产品被选择的次数
                    prefer = (Product.find(@bom_item.product_id)).prefer + 1
                    Product.find(@bom_item.product_id).update(prefer: prefer) 
                    if params[:bomsuse].blank?
                        flash[:success] = t('success_a')
                        redirect_to bom_path(@bom_item.bom, :anchor => "Comment", :bomitem => @bom_item.id );
                    else
                        @match_str_nn = "#{@bom.moko_bom_items.count('product_id')+@bom.moko_bom_items.count('mpn_id')} / #{@bom.moko_bom_items.count}"
                        @matched_items_nn = Product.find_by_sql("
SELECT
	moko_bom_items.id,
	moko_bom_items.quantity,
	moko_bom_items.description,
	moko_bom_items.part_code,
	moko_bom_items.moko_bom_info_id,
	moko_bom_items.product_id,
	moko_bom_items.created_at,
	moko_bom_items.updated_at,
	moko_bom_items.warn,
	moko_bom_items.user_id,
	moko_bom_items.danger,
	moko_bom_items.manual,
	moko_bom_items.mark,
	moko_bom_items.mpn,
	moko_bom_items.mpn_id,

IF (
	moko_bom_items.mpn_id > 0,
	mpn_items.price,
	products.price
) AS price,

IF (
	moko_bom_items.mpn_id > 0,
	mpn_items.description,
	products.description
) AS description_p
FROM
	moko_bom_items
LEFT JOIN products ON moko_bom_items.product_id = products.id
LEFT JOIN mpn_items ON moko_bom_items.mpn_id = mpn_items.id
WHERE
	moko_bom_items.moko_bom_info_id = "+@bom_item.moko_bom_info_id.to_s)
                               
                        @total_price_nn = 0.00               
	                unless @matched_items_nn.empty?
                            @bom_api_all = []
		            @matched_items_nn.each do |item|
                                if not item.price.blank?
                                    @total_price_nn += item.price * item.quantity * @bom.qty.to_i 
                                end                      
		            end
                        end
                        @bom.t_p = @total_price_nn.to_f.round(4)
                        @bom.save
                        #if can? :work_d, :all
                           # render "bom_update.js.erb"
                        #else
                            render "p_update_moko.js.erb"
                        #end
                    end
                else
	            flash[:error] = t('error_d')
	  	    redirect_to bom_path(@bom_item.bom, :anchor => "Comment", :bomitem => @bom_item.id );
	        end
            end  
            #Rails.logger.info(@bom_item.id.to_s + '_dns')
        end
    end





    def p_update
        if not params[:product_id].blank?
            if not params[:bom_version].blank?
                del_dn = PVersionDn.find_by_sql("SELECT * FROM p_version_dns WHERE p_version_dns.p_version_item_id = '#{params[:id]}' AND p_version_dns.tag IS NULL")
            else
                del_dn = PDn.find_by_sql("SELECT * FROM p_dns WHERE p_dns.p_item_id = '#{params[:id]}' AND p_dns.tag IS NULL")
            end
            #del_dn = PDn.find_by(item_id: params[:id], tag: nil)
            if not del_dn.blank?
                #del_dn.delete 
                #del_dn.save
                del_dn.each do |del_a|
                    del_a.destroy 
                end
            end
            part_code = Product.find(params[:product_id]).name
            #all_dns = AllDn.where(part_code: part_code).order('date DESC')
            all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{part_code}' AND all_dns.qty >= 100 ORDER BY all_dns.date DESC").first
            if all_dns.blank?
                Rails.logger.info("ttttttttttttt--------------------------1111")
                all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{part_code}' ORDER BY all_dns.date DESC").first
            end
            #all_dns.each do |dns|
            if not params[:bom_version].blank?
                PVersionDn.where(p_version_item_id: params[:id]).update_all "color=NULL"
            else
                PDn.where(p_item_id: params[:id],state: "").update_all "color=NULL"
            end
            if not params[:bom_version].blank?
                @bom_item = PVersionItem.find(params[:id]) #取回p_items表bomitem记录，在解析bom是存入，可能没有匹配到product
                @bom = ProcurementVersionBom.find(@bom_item.procurement_bom_id)
            else
                @bom_item = PItem.find(params[:id]) #取回p_items表bomitem记录，在解析bom是存入，可能没有匹配到product
                @bom = ProcurementBom.find(@bom_item.procurement_bom_id)
            end
            if not all_dns.blank?
                Rails.logger.info("ttttttttttttt--------------------------22222222222")
                if not params[:bom_version].blank?
                    add_dns = PVersionDn.new
                    add_dns.email = current_user.email
                    add_dns.p_version_item_id = params[:id]
                else
                    add_dns = PDn.new
                    add_dns.email = current_user.email
                    add_dns.p_item_id = params[:id]
                end
                 
                
                add_dns.dn = all_dns.dn
                add_dns.dn_long = all_dns.dn_long
                add_dns.date = all_dns.date
                add_dns.part_code = all_dns.part_code
                add_dns.qty = all_dns.qty
                #add_dns.qty = @bom_item.quantity * @bom.qty
                #add_dns.remark = dns.remark
                add_dns.cost = all_dns.price
                add_dns.color = "b"
                add_dns.save
            end
            @view_dns = ''
            @view_dns += '<table class="table table-hover table-bordered" style="padding: 0px;margin: 0px;">'
=begin            
            @view_dns += '<thead >'
            @view_dns += '<tr > '
            @view_dns += '<th width="30"></th>'
            @view_dns += '<th width="90">日期</th>'
            @view_dns += '<th width="100">供应商</th>' 
            @view_dns += '<th width="80">数量</th>'
            @view_dns += '<th width="80">成本价</th>'
            @view_dns += '<th width="80">技术资料</th>'
            @view_dns += '<th>备注</th>'
            @view_dns += '<th width="30"></th>'
            
            @view_dns += '</tr>'
            @view_dns += '</thead>'
=end
            @view_dns += '<tbody >'
            if not params[:bom_version].blank?
                PVersionDn.where(p_version_item_id: params[:id]).each do |dn|
                    @view_dns += '<tr id="' + params[:id].to_s + '_' + dn.id.to_s + '" '
                    if dn.color == "b"
                        @view_dns += ' class="bg-info">'
                    elsif dn.color == "g" 
                        @view_dns += ' class="bg-success">' 
                    else
                        @view_dns += ' >'
                    end
                #@view_dns += '<td width="25"><small><a class="glyphicon glyphicon-edit" data-method="get" data-remote="true" href=""></a></small></td>'
                    @view_dns += '<td style="padding: 0px;margin: 0px;" width="55"><small><a type="button" class="glyphicon glyphicon-edit" data-toggle="modal" data-target="#editModal" data-whatever="' + dn.id.to_s + '" data-dn="' + dn.dn.to_s + '" data-dnlong="' + dn.dn_long.to_s + '" data-qty="' + dn.qty.to_s + '" data-cost="' + dn.cost.to_s + '" data-remark="' + dn.remark.to_s + '" data-itemid="' + params[:id].to_s + '" > '
                    if not dn.info.blank?                
                        @view_dns += ' <a href="'+dn.info.to_s+'">下载</a></small></td>'
                    else
                        @view_dns += ' </small></td>'
                    end
                    @view_dns += '<td style="padding: 0px;margin: 0px;" width="70"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s + '&bom_version=' + params[:bom_version].to_s + '&bomsuse=bomsuse" ><div>' + dn.date.localtime.strftime('%y-%m').to_s + '</div></a></small></td>'             
                    @view_dns += '<td style="padding: 0px;margin: 0px;" width="200" title="'+dn.dn_long.to_s+'"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s + '&bom_version=' + params[:bom_version].to_s + '&bomsuse=bomsuse" ><div>' + dn.dn.to_s+ ' '  + dn.qty.to_s+ ' ￥'+ dn.cost.to_s+'</div></a></small></td>'
                    @view_dns += '<td style="padding: 0px;margin: 0px;" ><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s + '&bom_version=' + params[:bom_version].to_s + '&bomsuse=bomsuse" ><div>' + dn.remark.to_s + '</div></a></small></td>'                
                    @view_dns += '<td style="padding: 0px;margin: 0px;" width="15"><small><a class="glyphicon glyphicon-trash" data-method="get" data-remote="true" href="/del_dn?id='+dn.id.to_s+'&item_id='+params[:id].to_s+ '&bom_version=' + params[:bom_version].to_s + '" data-confirm="确定要删除?"></a></small></td>'
                    @view_dns += '</tr>'
                end
            else
                PDn.where(p_item_id: params[:id],state: "").each do |dn|
                    @view_dns += '<tr id="' + params[:id].to_s + '_' + dn.id.to_s + '" '
                    if dn.color == "b"
                        @view_dns += ' class="bg-info">'
                    elsif dn.color == "g" 
                        @view_dns += ' class="bg-success">' 
                    else
                        @view_dns += ' >'
                    end
                #@view_dns += '<td width="25"><small><a class="glyphicon glyphicon-edit" data-method="get" data-remote="true" href=""></a></small></td>'
                    @view_dns += '<td style="padding: 0px;margin: 0px;" width="55"><small><a type="button" class="glyphicon glyphicon-edit" data-toggle="modal" data-target="#editModal" data-whatever="' + dn.id.to_s + '" data-dn="' + dn.dn.to_s + '" data-dnlong="' + dn.dn_long.to_s + '" data-qty="' + dn.qty.to_s + '" data-cost="' + dn.cost.to_s + '" data-remark="' + dn.remark.to_s + '" data-itemid="' + params[:id].to_s + '" > '
                    if not dn.info.blank?                
                        @view_dns += ' <a href="'+dn.info.to_s+'">下载</a></small></td>'
                    else
                        @view_dns += ' </small></td>'
                    end
                    @view_dns += '<td style="padding: 0px;margin: 0px;" width="70"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s + '&bomsuse=bomsuse" ><div>' + dn.date.localtime.strftime('%y-%m').to_s + '</div></a></small></td>'             
                    @view_dns += '<td style="padding: 0px;margin: 0px;" width="200" title="'+dn.dn_long.to_s+'"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s +  '&bomsuse=bomsuse" ><div>' + dn.dn.to_s+ ' '  + dn.qty.to_s+ ' ￥'+ dn.cost.to_s+'</div></a></small></td>'
                    @view_dns += '<td style="padding: 0px;margin: 0px;" ><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s +  '&bomsuse=bomsuse" ><div>' + dn.remark.to_s + '</div></a></small></td>'                
                    @view_dns += '<td style="padding: 0px;margin: 0px;" width="15"><small><a class="glyphicon glyphicon-trash" data-method="get" data-remote="true" href="/del_dn?id='+dn.id.to_s+'&item_id='+params[:id].to_s+'" data-confirm="确定要删除?"></a></small></td>'
                    @view_dns += '</tr>'
                end
            end

            @view_dns += '</tbody>'
            @view_dns += '</table>'
            Rails.logger.info("----------------------111")
            Rails.logger.info(@view_dns)
            Rails.logger.info("----------------------999")
            #@view_dns = "wwwww"
            if not params[:bom_version].blank?
                @bom_item = PVersionItem.find(params[:id]) #取回p_items表bomitem记录，在解析bom是存入，可能没有匹配到product
                @bom = ProcurementVersionBom.find(@bom_item.procurement_bom_id)
            else
                @bom_item = PItem.find(params[:id]) #取回p_items表bomitem记录，在解析bom是存入，可能没有匹配到product
                @bom = ProcurementBom.find(@bom_item.procurement_bom_id)
            end
            if @bom_item.update_attribute("product_id", params[:product_id])
                if @bom_item.product_id
	            bom_item_product = Product.find(@bom_item.product_id)
                    @bom_item.moko_part = bom_item_product.name
                    @bom_item.moko_des = bom_item_product.description
                    @bom_item.warn = false
                    if not all_dns.blank?
                        @bom_item.cost = add_dns.cost
                        @bom_item.dn_id = add_dns.id
                        @bom_item.dn = add_dns.dn
                        @bom_item.dn_long = add_dns.dn_long
                        @bom_item.color = "b"
                    end
                    @bom_item.mark = false
                    @bom_item.manual = true
                    @bom_item.mpn_id = nil
                    #@bom_item.mpn = nil
                    
                    @bom_item.user_do_change = nil
	            @bom_item.save!
  
   
                    #累加产品被选择的次数
                    prefer = (Product.find(@bom_item.product_id)).prefer + 1
                    Product.find(@bom_item.product_id).update(prefer: prefer) 
                    if params[:bomsuse].blank?
                        flash[:success] = t('success_a')
                        redirect_to bom_path(@bom_item.bom, :anchor => "Comment", :bomitem => @bom_item.id );
                    else
                        @match_str_nn = "#{@bom.p_items.count('product_id')+@bom.p_items.count('mpn_id')} / #{@bom.p_items.count}"
                        if not params[:bom_version].blank?
                            @matched_items_nn = Product.find_by_sql("
SELECT
	p_version_items.id,
	p_version_items.quantity,
	p_version_items.description,
	p_version_items.part_code,
	p_version_items.procurement_bom_id,
	p_version_items.product_id,
	p_version_items.created_at,
	p_version_items.updated_at,
	p_version_items.warn,
	p_version_items.user_id,
	p_version_items.danger,
	p_version_items.manual,
	p_version_items.mark,
	p_version_items.mpn,
	p_version_items.mpn_id,

IF (
	p_version_items.mpn_id > 0,
	mpn_items.price,
	products.price
) AS price,

IF (
	p_version_items.mpn_id > 0,
	mpn_items.description,
	products.description
) AS description_p
FROM
	p_version_items
LEFT JOIN products ON p_version_items.product_id = products.id
LEFT JOIN mpn_items ON p_version_items.mpn_id = mpn_items.id
WHERE
	p_version_items.procurement_version_bom_id = "+@bom_item.procurement_version_bom_id.to_s)   
                        else
                            @matched_items_nn = Product.find_by_sql("
SELECT
	p_items.id,
	p_items.quantity,
	p_items.description,
	p_items.part_code,
	p_items.procurement_bom_id,
	p_items.product_id,
	p_items.created_at,
	p_items.updated_at,
	p_items.warn,
	p_items.user_id,
	p_items.danger,
	p_items.manual,
	p_items.mark,
	p_items.mpn,
	p_items.mpn_id,

IF (
	p_items.mpn_id > 0,
	mpn_items.price,
	products.price
) AS price,

IF (
	p_items.mpn_id > 0,
	mpn_items.description,
	products.description
) AS description_p
FROM
	p_items
LEFT JOIN products ON p_items.product_id = products.id
LEFT JOIN mpn_items ON p_items.mpn_id = mpn_items.id
WHERE
	p_items.procurement_bom_id = "+@bom_item.procurement_bom_id.to_s)
                        end          
                        @total_price_nn = 0.00               
	                unless @matched_items_nn.empty?
                            @bom_api_all = []
		            @matched_items_nn.each do |item|
                                if not item.price.blank?
                                    @total_price_nn += item.price * item.quantity * @bom.qty.to_i 
                                end                      
		            end
                        end
                        @bom.t_p = @total_price_nn.to_f.round(4)
                        @bom.save
                        #if can? :work_d, :all
                           # render "bom_update.js.erb"
                        #else
                            render "p_update.js.erb"
                        #end
                    end
                else
	            flash[:error] = t('error_d')
	  	    redirect_to bom_path(@bom_item.bom, :anchor => "Comment", :bomitem => @bom_item.id );
	        end
            end  
            #Rails.logger.info(@bom_item.id.to_s + '_dns')
        end
    end

    def p_updateii
        dell_dns_color = PDn.where(p_item_id: params[:id],state: "")
        c_color = ""
        dell_dns_color = PDn.where("p_item_id = ? AND color <> ?",params[:id],"Y").update_all "color = '#{c_color}'"
        if params[:product_name] != ""
            @add_dns = PDn.find(params[:dn_id])
            @add_dns.email = current_user.email
            
            if @add_dns.color == "y"
                @add_dns.color = "y"
            else
                @add_dns.color = "b"
            end
            @add_dns.save
            @bom_item = PItem.find(params[:id]) #取回p_items表bomitem记录，在解析bom是存入，可能没有匹配到product
            @bom = ProcurementBom.find(@bom_item.procurement_bom_id)
           
            if @bom_item.update_attribute("product_id", Product.find_by(name: params[:product_name]).id)
                if @bom_item.product_id
	            #@bom_item.product = Product.find(@bom_item.product_id)
                    @bom_item.warn = false
                    @bom_item.cost = @add_dns.cost
                    @bom_item.dn_id = @add_dns.id
                    @bom_item.dn = @add_dns.dn
                    @bom_item.dn_long = @add_dns.dn_long
                    @bom_item.mark = false
                    @bom_item.manual = true
                    @bom_item.mpn_id = nil
                    #@bom_item.mpn = nil
                    @bom_item.color = "b"
                    if @add_dns.remark != nil or @add_dns.remark != ""
                        if @add_dns.color != "y"
                            @bom_item.sell_feed_back_tag = "sell"
                        else
                            @bom_item.sell_feed_back_tag = ""
                        end
                    else
                        @bom_item.sell_feed_back_tag = ""
                    end
                    @bom_item.user_do_change = nil
	            #@bom_item.save!
                    bom_state = ""
                    if @bom_item.save!
                        check_blue = PItem.where("procurement_bom_id='#{@bom_item.procurement_bom_id}' AND color<>'b' AND quantity>0")
                        if check_blue.blank?
                            bom_state = "done"
                        end
                    end
   
                    #累加产品被选择的次数
                    prefer = (Product.find(@bom_item.product_id)).prefer + 1
                    Product.find(@bom_item.product_id).update(prefer: prefer) 
                    if params[:bomsuse].blank?
                        flash[:success] = t('success_a')
                        redirect_to bom_path(@bom_item.bom, :anchor => "Comment", :bomitem => @bom_item.id );
                    else
                        @match_str_nn = "#{@bom.p_items.count('product_id')+@bom.p_items.count('mpn_id')} / #{@bom.p_items.count}"
                        @matched_items_nn = PItem.where(procurement_bom_id: @bom.id)            
                        @total_price_nn = 0.00               
	                unless @matched_items_nn.empty?
                            @bom_api_all = []
		            @matched_items_nn.each do |item|
                                if not item.cost.blank?
                                    if not item.pmc_qty.blank?
                                        @total_price_nn += item.cost * item.pmc_qty 
                                    else
                                        @total_price_nn += item.cost * @bom.qty * item.quantity
                                    end
                                end   
		            end
                        end
                        @bom.t_p = @total_price_nn.to_f.round(4)
                        @bom.state = bom_state
                        @bom.save
                        render "p_updateii.js.erb"
                    end
                else
	            flash[:error] = t('error_d')
	  	    redirect_to bom_path(@bom_item.bom, :anchor => "Comment", :bomitem => @bom_item.id );
	        end
            end  
            

            
            
            #Rails.logger.info(@bom_item.id.to_s + '_dns')
        else
            @add_dns = PDn.find(params[:dn_id])
            @add_dns.email = current_user.email
            
            if @add_dns.color == "y"
                @add_dns.color = "y"
            else
                @add_dns.color = "b"
            end
            #@add_dns.color = "b"
            @add_dns.save
            @bom_item = PItem.find(params[:id]) 
            
            @bom_item.cost = @add_dns.cost
            @bom_item.dn_id = @add_dns.id
            @bom_item.dn = @add_dns.dn
            @bom_item.dn_long = @add_dns.dn_long
            #@bom_item.product_id = 0
            @bom_item.color = "b"
            if @add_dns.remark != nil or @add_dns.remark != ""
                @bom_item.sell_feed_back_tag = "sell"
            else
                @bom_item.sell_feed_back_tag = ""
            end
            @bom_item.user_do_change = nil
            bom_state = ""
            if @bom_item.save
                check_blue = PItem.where("procurement_bom_id='#{@bom_item.procurement_bom_id}' AND color<>'b' AND quantity>0")
                if check_blue.blank?
                    bom_state = "done"
                end
            end
            @bom = ProcurementBom.find(@bom_item.procurement_bom_id)
            @bom.state = bom_state
            @match_str_nn = "#{@bom.p_items.count('product_id')+@bom.p_items.count('mpn_id')} / #{@bom.p_items.count}"
            @matched_items_nn = PItem.where(procurement_bom_id: @bom.id)   
            
            @total_price_nn = 0.00               
	    if not @matched_items_nn.blank?
                @bom_api_all = []
		@matched_items_nn.each do |item|
                    if not item.cost.blank?
                        if not item.pmc_qty.blank?
                            @total_price_nn += item.cost * item.pmc_qty 
                        else
                            @total_price_nn += item.cost * @bom.qty * item.quantity
                        end
                    end                      
		end
            end
            @bom.t_p = @total_price_nn.to_f.round(4)
            @bom.save

            render "p_updateii.js.erb"    
        end
    end

    def p_edit
=begin
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        Rails.logger.info(@pdn.inspect)
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        respond_to do |format|
            if @pdn.save
                format.js
            end
        end
=end
        if not params[:bom_version].blank?
            @bom_item = PVersionItem.find(params[:item_id])
        else
            @bom_item = PItem.find(params[:item_id])
        end
        if not @bom_item.blank?
            if not params[:bom_version].blank?
                if not params[:info].blank?
                    p_dn = PVersionDn.new(bn_params)
                else
                    p_dn = PVersionDn.new()
                end
            else
                if not params[:info].blank?
                    p_dn = PDn.new(bn_params)
                else
                    p_dn = PDn.new()
                end
                p_dn.email = current_user.email
            end
            #Rails.logger.info("--------------------------")
            #Rails.logger.info(p_dn.info.current_path.inspect)
            #Rails.logger.info("--------------------------")
            p_dn.p_item_id = params[:item_id]
            p_dn.cost = params[:cost]
            p_dn.part_code = @bom_item.moko_part
=begin
            if not params[:part_code].blank?
                p_dn.part_code = params[:part_code]
            else
                if not @bom_item.moko_part.blank?
                    p_dn.part_code = @bom_item.moko_part
                else
                    if @bom_item.product_id != 0
                        find_moko_part = Product.find_by_id(@bom_item.product_id)
                        if not find_moko_part.blank?
                            p_dn.part_code = find_moko_part.name
                        end
                    end
                end
            end
=end
            p_dn.dn = params[:dn]
            if params[:dn_long] == "" and params[:dn] != ""
                p_dn.dn_long = AllDn.find_by(dn: params[:dn].strip).dn_long
            else
                p_dn.dn_long = params[:dn_long]
            end
            #p_dn.qty = params[:qty]
            if not params[:bom_version].blank?
                p_dn.qty = PVersionItem.find_by_id(params[:item_id]).quantity*ProcurementVersionBom.find_by_id(PVersionItem.find_by_id(params[:item_id]).procurement_bom_id).qty
            else
                p_dn.qty = PItem.find_by_id(params[:item_id]).quantity*ProcurementBom.find_by_id(PItem.find_by_id(params[:item_id]).procurement_bom_id).qty
            end
            p_dn.date = Time.new
            p_dn.remark = params[:remark]
            #if params[:remark] != ""
                #@bom_item.sell_feed_back_tag = "sell"
                #@bom_item.save
           # end 
            p_dn.tag = "a"
            p_dn.save
            #Rails.logger.info("--------------------------")
            #Rails.logger.info(p_dn.info.current_path)
            #Rails.logger.info("--------------------------")
        end
            @view_dns = ''
            @view_dns += '<table class="table table-hover table-bordered" style="padding: 0px;margin: 0px;">'
            @view_dns += '<tbody >'
            PDn.where(p_item_id: params[:item_id],state: "").each do |dn|
                @view_dns += '<tr id="' + params[:item_id].to_s + '_' + dn.id.to_s + '" '
                if dn.color == "b"
                    @view_dns += ' class="bg-info">'
                elsif dn.color == "g" 
                    @view_dns += ' class="bg-success">' 
                else
                    @view_dns += ' class="">'
                end
                #@view_dns += '<td width="25"><small><a class="glyphicon glyphicon-edit" data-method="get" data-remote="true" href=""></a></small></td>'
                @view_dns += '<td style="padding: 0px;margin: 0px;" width="55"><small><a type="button" class="glyphicon glyphicon-edit" data-toggle="modal" data-target="#editModal" data-whatever="' + dn.id.to_s + '" data-dn="' + dn.dn.to_s + '" data-dnlong="' + dn.dn_long.to_s + '" data-qty="' + dn.qty.to_s + '" data-cost="' + dn.cost.to_s + '" data-remark="' + dn.remark.to_s + '" data-itemid="' + params[:item_id].to_s + '" ></small></a> '
                if not dn.info.blank?                
                    @view_dns += ' <a href="'+dn.info.to_s+'">下载</a></small></td>'
                else
                    @view_dns += ' </td>'
                end 

                if not params[:bom_version].blank?
                    @view_dns += '<td style="padding: 0px;margin: 0px;" width="70"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:item_id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s + '&bom_version=' + params[:bom_version].to_s + '&bomsuse=bomsuse" ><div>' + dn.date.localtime.strftime('%y-%m').to_s + '</div></a></small></td>'


                
                    @view_dns += '<td style="padding: 0px;margin: 0px;" width="200" title="'+dn.dn_long.to_s+'"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:item_id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s + '&bom_version=' + params[:bom_version].to_s + '&bomsuse=bomsuse" ><div>' + dn.dn.to_s + ' ' + dn.qty.to_s + ' ￥'+dn.cost.to_s+'</div></a></small></td>'

                
                    @view_dns += '<td style="padding: 0px;margin: 0px;" ><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:item_id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s + '&bom_version=' + params[:bom_version].to_s + '&bomsuse=bomsuse" data-toggle="popover" tabindex="0"  data-trigger="hover" data-placement="top" data-content="' + dn.remark.to_s + '"><div>' 
                else
                    @view_dns += '<td style="padding: 0px;margin: 0px;" width="70"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:item_id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s + '&bomsuse=bomsuse" ><div>' + dn.date.localtime.strftime('%y-%m').to_s + '</div></a></small></td>'


                
                    @view_dns += '<td style="padding: 0px;margin: 0px;" width="200" title="'+dn.dn_long.to_s+'"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:item_id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s +  '&bomsuse=bomsuse" ><div>' + dn.dn.to_s + ' ' + dn.qty.to_s + ' ￥'+dn.cost.to_s+'</div></a></small></td>'

                
                    @view_dns += '<td style="padding: 0px;margin: 0px;" ><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:item_id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s +  '&bomsuse=bomsuse" data-toggle="popover" tabindex="0"  data-trigger="hover" data-placement="top" data-content="' + dn.remark.to_s + '"><div>' 
                end
                Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                #@view_dns += dn.remark ? dn.remark[0]:''
                if dn.remark
                    @view_dns += dn.remark
                else
                    @view_dns += ''
                end
                @view_dns += '</div></a></small></td>' 
                if not params[:bom_version].blank?            
                    @view_dns += '<td style="padding: 0px;margin: 0px;" width="15"><small><a class="glyphicon glyphicon-trash" data-method="get" data-remote="true" href="/del_dn?id='+dn.id.to_s+'&item_id='+params[:item_id].to_s+'&bom_version=' + params[:bom_version].to_s + '" data-confirm="确定要删除?"></a></small></td>'
                else
                    @view_dns += '<td style="padding: 0px;margin: 0px;" width="15"><small><a class="glyphicon glyphicon-trash" data-method="get" data-remote="true" href="/del_dn?id='+dn.id.to_s+'&item_id='+params[:item_id].to_s+'" data-confirm="确定要删除?"></a></small></td>'
                end
                @view_dns += '</tr>'
            end
            @view_dns += '</tbody>'
            @view_dns += '</table>'
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        Rails.logger.info(@view_dns.inspect)
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        #redirect_to :back
        #render :nothing => true

    end

    def p_edit_dn    
        dn = PDn.find(params[:dn_id])
        if not params[:dn_info].blank?
            dn.update(editbn_params)
        end
        
        if not params[:dn_dn].blank?
            dn.dn = params[:dn_dn]
        end
        if not params[:dnlong].blank?
            dn.dn_long = params[:dnlong]
        end
        if not params[:dn_qty].blank?
            dn.qty = params[:dn_qty]
        end
        if not params[:dn_cost].blank?
            dn.cost = params[:dn_cost]
        end
        
        if not params[:dn_remark].blank?
            dn.remark = params[:dn_remark].gsub(/\r\n/, " ")
            @bom_item = PItem.find(dn.p_item_id)
            
            #@bom_item.sell_feed_back_tag = "sell"
            #@bom_item.save
        end
        dn.email = current_user.email
        dn.save
        @itemid = params[:dn_item_id]
        @dnid = params[:dn_id]
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        Rails.logger.info(@itemid.inspect)
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        @view_dns = ""
        @view_dns += '<td style="padding: 0px;margin: 0px;" width="55"><small><a type="button" class="glyphicon glyphicon-edit" data-toggle="modal" data-target="#editModal" data-whatever="' + dn.id.to_s + '" data-dn="' + dn.dn.to_s + '" data-dnlong="' + dn.dn_long.to_s + '" data-qty="' + dn.qty.to_s + '" data-cost="' + dn.cost.to_s + '" data-remark="' + dn.remark.to_s + '" data-itemid="' + params[:dn_item_id].to_s + '" ></small></a>'
        if not dn.info.blank?                
            @view_dns += ' <a href="'+dn.info.to_s+'">下载</a></small></td>'
        else
            @view_dns += ' </td>'
        end 


        if not params[:bom_version].blank?
            @view_dns += '<td style="padding: 0px;margin: 0px;" width="70"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ @itemid.to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s + '&bom_version=' + params[:bom_version].to_s + '&bomsuse=bomsuse" ><div>' + dn.date.localtime.strftime('%y-%m').to_s + '</div></a></small></td>'    


            @view_dns += '<td style="padding: 0px;margin: 0px;" width="200" title="'+dn.dn_long.to_s+'"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ @itemid.to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s + ' &bom_version=' + params[:bom_version].to_s + '&bomsuse=bomsuse" ><div>' + dn.dn.to_s + ' ' + dn.qty.to_s + ' ￥'+dn.cost.to_s + '</div></a></small></td>'

       
            #@view_dns += '<td><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s +  '&bomsuse=bomsuse" ><div>' + dn.remark.to_s + '</div></a></small></td>'                


            @view_dns += '<td style="padding: 0px;margin: 0px;" ><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ @itemid.to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s + '&bom_version=' + params[:bom_version].to_s + '&bomsuse=bomsuse" data-toggle="popover" tabindex="0"  data-trigger="hover" data-placement="top" data-content="' + dn.remark.to_s + '"><div>' 
                
        else
            @view_dns += '<td style="padding: 0px;margin: 0px;" width="70"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ @itemid.to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s + '&bomsuse=bomsuse" ><div>' + dn.date.localtime.strftime('%y-%m').to_s + '</div></a></small></td>'    


            @view_dns += '<td style="padding: 0px;margin: 0px;" width="200" title="'+dn.dn_long.to_s+'"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ @itemid.to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s +  '&bomsuse=bomsuse" ><div>' + dn.dn.to_s + ' ' + dn.qty.to_s + ' ￥'+dn.cost.to_s+'</div></a></small></td>'

       
            #@view_dns += '<td><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s +  '&bomsuse=bomsuse" ><div>' + dn.remark.to_s + '</div></a></small></td>'                


            @view_dns += '<td style="padding: 0px;margin: 0px;" ><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ @itemid.to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s +  '&bomsuse=bomsuse" data-toggle="popover" tabindex="0"  data-trigger="hover" data-placement="top" data-content="' + dn.remark.to_s + '"><div>'
        end



        if not dn.remark.blank?
            @view_dns += dn.remark
        else
            @view_dns += ''
        end
        @view_dns += '</div></a></small></td>'  


        @view_dns += '<td style="padding: 0px;margin: 0px;" width="15"><small><a class="glyphicon glyphicon-trash" data-method="get" data-remote="true" href="/del_dn?id='+dn.id.to_s+'&item_id='+@itemid.to_s+'" data-confirm="确定要删除?"></a></small></td>'

        #redirect_to :back
        #return false    
        
        #Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        #Rails.logger.info(@view_dns.inspect)
        #Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        render "p_edit_dn.js.erb"
    end

    def p_edit_cost_dn 
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        Rails.logger.info(params["#{params[:dn_itemid]}p"].inspect)
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        if params["#{params[:dn_itemid]}p"] != ""     
            part_cost = params["#{params[:dn_itemid]}p"]
            dn_cost = params["#{params[:dn_itemid]}p"]
            @tr_color = "bg-info"
        else
            part_cost = nil
            dn_cost = 0
            @tr_color = "bg-danger"
        end

        @pitem = PItem.find(params[:dn_itemid])
        @pitem.cost = part_cost
        if params["#{params[:dn_itemid]}p"] != "" 
            @pitem.color = "b"
        else
            @pitem.color = ""
        end
        @pitem.save
        if @pitem.color.blank?
            get_bom_data = ProcurementBom.find_by_id(@pitem.procurement_bom_id)
            get_bom_data.state = ""
            get_bom_data.save
        end
        @itemid = params[:dn_itemid]
        @dnid = @pitem.dn_id
        dn_old = PDn.find_by_id(@dnid) 
        if not @dnid.blank? 
=begin
            if not params["#{params[:dn_itemid]}p"].blank?
                dn.cost = params["#{params[:dn_itemid]}p"]
                dn.qty = @pitem.quantity * ProcurementBom.find(@pitem.procurement_bom_id).qty
                dn.color = "b"
            end
            dn.email = current_user.email
            dn.save
=end
            dn = PDn.new
            if not can? :work_d, :all
                dn.email = current_user.email
            end
            dn.p_item_id = @pitem.id
            dn.part_code = Product.find_by_id(@pitem.product_id).name
            dn.date = Time.new
            dn.dn = dn_old.dn
            dn.dn_long = dn_old.dn_long
            dn.cost = params["#{params[:dn_itemid]}p"]
            dn.qty = @pitem.quantity * ProcurementBom.find(@pitem.procurement_bom_id).qty
            dn.info = dn_old.info
            dn.remark = dn_old.remark
            dn.tag = dn_old.tag
            dn.color = "b"

            dn.save
            @view_dn = ""
            @view_dn += '<td style="padding: 0px;margin: 0px;" width="55"><small><a type="button" class="glyphicon glyphicon-edit" data-toggle="modal" data-target="#editModal" data-whatever="' + dn.id.to_s + '" data-dn="' + dn.dn.to_s + '" data-dnlong="' + dn.dn_long.to_s + '" data-qty="' + dn.qty.to_s + '" data-cost="' + dn.cost.to_s + '" data-remark="' + dn.remark.to_s + '" data-itemid="' + params[:dn_itemid].to_s + '" ></small></a>'
            if not dn.info.blank?                
                @view_dn += ' <a href="'+dn.info.to_s+'">下载</a></small></td>'
            else
                @view_dn += ' </td>'
            end 



            @view_dn += '<td style="padding: 0px;margin: 0px;" width="70"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ @itemid.to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s + '&bomsuse=bomsuse" ><div>' + dn.date.localtime.strftime('%y-%m').to_s + '</div></a></small></td>'    


            @view_dn += '<td style="padding: 0px;margin: 0px;" width="200" title="'+dn.dn_long.to_s+'"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ @itemid.to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s +  '&bomsuse=bomsuse" ><div>' + dn.dn.to_s + ' ' + dn.qty.to_s + ' ￥'+dn.cost.to_s+'</div></a></small></td>'

       
        #@view_dns += '<td><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s +  '&bomsuse=bomsuse" ><div>' + dn.remark.to_s + '</div></a></small></td>'                


            @view_dn += '<td style="padding: 0px;margin: 0px;" ><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ @itemid.to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s +  '&bomsuse=bomsuse" data-toggle="popover" tabindex="0"  data-trigger="hover" data-placement="top" data-content="' + dn.remark.to_s + '"><div>' 
                
            if not dn.remark.blank?
                @view_dn += dn.remark
            else
                @view_dn += ''
            end
            @view_dn += '</div></a></small></td>'  


            @view_dn += '<td style="padding: 0px;margin: 0px;" width="15"><small><a class="glyphicon glyphicon-trash" data-method="get" data-remote="true" href="/del_dn?id='+dn.id.to_s+'&item_id='+@itemid.to_s+'" data-confirm="确定要删除?"></a></small></td>'
            #else
        else
            dn = PDn.new
            if not can? :work_d, :all
                dn.email = current_user.email
            end
            dn.part_code = Product.find_by_id(@pitem.product_id).name
            dn.cost = params["#{params[:dn_itemid]}p"]
            dn.p_item_id = @pitem.id
            dn.qty = @pitem.quantity * ProcurementBom.find(@pitem.procurement_bom_id).qty
            dn.color = "b"
            dn.tag = "a"
            dn.date = Time.new
            dn.save
            @dnid = dn.id
            @pitem.dn_id = dn.id
            @pitem.save
            @view_dns = ''
            @view_dns += '<table class="table table-hover table-bordered" style="padding: 0px;margin: 0px;">'
            @view_dns += '<tbody >'
            PDn.where(p_item_id: @itemid,state: "").each do |dn|
                @view_dns += '<tr id="' + @itemid.to_s + '_' + dn.id.to_s + '" '
                if dn.color == "b"
                    @view_dns += ' class="bg-info">'
                elsif dn.color == "g" 
                    @view_dns += ' class="bg-success">' 
                else
                    @view_dns += ' >'
                end
                #@view_dns += '<td width="25"><small><a class="glyphicon glyphicon-edit" data-method="get" data-remote="true" href=""></a></small></td>'
                @view_dns += '<td style="padding: 0px;margin: 0px;" width="55"><small><a type="button" class="glyphicon glyphicon-edit" data-toggle="modal" data-target="#editModal" data-whatever="' + dn.id.to_s + '" data-dn="' + dn.dn.to_s + '" data-dnlong="' + dn.dn_long.to_s + '" data-qty="' + dn.qty.to_s + '" data-cost="' + dn.cost.to_s + '" data-remark="' + dn.remark.to_s + '" data-itemid="' + @itemid.to_s + '" ></small></a> '
                if not dn.info.blank?                
                    @view_dns += ' <a href="'+dn.info.to_s+'">下载</a></small></td>'
                else
                    @view_dns += ' </td>'
                end 


                @view_dns += '<td style="padding: 0px;margin: 0px;" width="70"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ @itemid.to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s + '&bomsuse=bomsuse" ><div>' + dn.date.localtime.strftime('%y-%m').to_s + '</div></a></small></td>'


                
                @view_dns += '<td style="padding: 0px;margin: 0px;" width="200" title="'+dn.dn_long.to_s+'"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ @itemid.to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s +  '&bomsuse=bomsuse" ><div>' + dn.dn.to_s + ' ' + dn.qty.to_s + ' ￥'+dn.cost.to_s+'</div></a></small></td>'

                
                @view_dns += '<td style="padding: 0px;margin: 0px;" ><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ @itemid.to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s +  '&bomsuse=bomsuse" data-toggle="popover" tabindex="0"  data-trigger="hover" data-placement="top" data-content="' + dn.remark.to_s + '"><div>' 
                Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                #@view_dns += dn.remark ? dn.remark[0]:''
                if dn.remark
                    @view_dns += dn.remark
                else
                    @view_dns += ''
                end
                @view_dns += '</div></a></small></td>'             
                @view_dns += '<td style="padding: 0px;margin: 0px;"  width="15"><small><a class="glyphicon glyphicon-trash" data-method="get" data-remote="true" href="/del_dn?id='+dn.id.to_s+'&item_id='+@itemid.to_s+'" data-confirm="确定要删除?"></a></small></td>'
                @view_dns += '</tr>'
            end
            @view_dns += '</tbody>'
            @view_dns += '</table>'
        end

        #end
        #redirect_to :back
        #return false    
        
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        Rails.logger.info(@view_dns.inspect)
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        render "p_edit_cost_dn.js.erb"
    end

    def p_up_userdo
        @user_do = params[:user_do]
        if not params[:bom_version].blank?
            @bom_item = PVersionItem.find(params[:id])
        else
            @bom_item = PItem.find(params[:id])
        end
        if not @bom_item.blank?
            if @bom_item.user_do != params[:user_do]
                @bom_item.user_do = params[:user_do]
                @bom_item.user_do_change = "c"
                #@bom_item.color = nil
                @bom_item.save   
=begin
                if params[:user_do] != '999'            
                    open_id = User.find(params[:user_do]).open_id
                    oauth = Oauth.find(1)
                    company_id = oauth.company_id
                    company_token = oauth.company_token
                    url = 'https://openapi.b.qq.com/api/tips/send'
                    if not open_id.blank? or open_id != ""
                        url += '?company_id='+company_id
                        url += '&company_token='+company_token
                        url += '&app_id=200710667'
                        url += '&client_ip=120.25.151.208'
                        url += '&oauth_version=2'
                        url += '&to_all=0'  
                        url += '&receivers='+open_id
                        url += '&window_title=Fastbom-PCB AND PCBA'
                        url += '&tips_title='+URI.encode('亲爱的'+User.find(params[:user_do]).full_name)
                        url += '&tips_content='+URI.encode('你有新的任务，点击查看。')
                        url += '&tips_url=erp.fastbom.com/p_viewbom?bom_id='+@bom_item.procurement_bom_id.to_s 
                        resp = Net::HTTP.get_response(URI(url))
                    end 
                end
=end
            end
        end  
    end

    def up_check
        #check_user_do = PItem.where(procurement_bom_id: params[:bom_id],user_do: params[:user_do],user_do_change: "c")
        check_user_do = PItem.where("`procurement_bom_id` = #{params[:bom_id]} AND `user_do` = #{params[:user_do]} AND (`user_do_change` = 'c' OR `check` IS NULL OR `cost` IS NULL)")
        if not check_user_do.blank?
            redirect_to :back 
            return false
        else
            check_do = PItem.where(procurement_bom_id: params[:bom_id],user_do: params[:user_do]).update_all(check: "do")
            if can? :work_g_all, :all
                check_all = PItem.where(procurement_bom_id: params[:bom_id], check: nil)
                if check_all.blank?
                    ProcurementBom.find(params[:bom_id]).update(check: "do")
                end
            end
            redirect_to :p_bomlist 
            return false
        end
    end

    def del_dn
        @item_id = params[:item_id]
        @dn_id = params[:id]
        if not params[:bom_version].blank?
            itemall = PVersionItem.find(params[:item_id])
            @dn = PVersionDn.find(params[:id])
        else
            itemall = PItem.find(params[:item_id])
            @dn = PDn.find(params[:id])
        end
        if not @dn.blank?
            itemall.dn_id = nil
            itemall.dn = nil
            itemall.dn_long = nil
            itemall.save
            #@dn.destroy
            @dn.state = "del"
            @dn.save
        end
    end

    def p_excel
        @bom = ProcurementBom.find(params[:bom_id])
        file_name = @bom.p_name.to_s+".xls"
        path = Rails.root.to_s+"/public/uploads/bom/excel_file/"
        #Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        #Rails.logger.info(file_name.inspect)
        #Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")

                Spreadsheet.client_encoding = 'UTF-8'
		ff = Spreadsheet::Workbook.new

		sheet1 = ff.create_worksheet

		#sheet1.row(0).concat %w{No 描述 报价 技术资料}
                all_title = @bom.all_title.split("|",-1)
                all_title << "MPN"
                all_title << "MOKO物料名称"
                all_title << "MOKO物料描述"
                all_title << "数量"
                all_title << "成本单价"
                all_title << "报价"
                all_title << "备注"
                sheet1.row(0).concat all_title
                #sheet1.column(1).width = 50
                set_color = 0  
                while set_color < all_title.size do         
                    sheet1.row(0).set_format(set_color,ColorFormat.new(:gray,:white))
                    if all_title[set_color] =~ /Quantity/i or all_title[set_color] =~ /qty/i
                        sheet1.column(set_color).width = 8
                    elsif all_title[set_color] =~ /成本价/i or all_title[set_color] =~ /报价/i
                        sheet1.column(set_color).width = 8
                    elsif all_title[set_color] =~ /MOKO物料描述/i
                        sheet1.column(set_color).width = 35
                    elsif all_title[set_color] =~ /part/i
                        sheet1.column(set_color).width = 22
                    else
                        sheet1.column(set_color).width = 15
                    end
                    set_color += 1
                end
		@bom.p_items.each_with_index do |item,index|
		    rowNum = index+1
                    title_format = Spreadsheet::Format.new({
                    :text_wrap => 1,:size => 8
                    })
                    add_format = Spreadsheet::Format.new({
                    :text_wrap => 1,:size => 8,:pattern_fg_color => :builtin_red
                    })
		    row = sheet1.row(rowNum)
                    row.set_format(2,title_format)
                    set_f = 0  
                    while set_f < all_title.size do         
                        row.set_format(set_f,title_format)
                        set_f += 1
                    end
                    #if item.warn
                        #[0,1,2,3,4,5,6,7].each{|col|
                        #row.set_format(2,title_format)
                        #row.default_format = color
                        #}
                    #end
                    if not item.all_info.blank?
                        item.all_info.split("|",-1).each do |info|
                            row.push(info.to_s)
                        end
                    else
                        all_title.each_with_index do |set_color,index|
                            row.set_format(index,ColorFormat.new(:red,:white))
                        end
                        @bom.all_title.split("|",-1).each do |do_it|
                            row.push("")
                        end
                    end
		    #row.push(rowNum)
		    #row.push(item.description)
		    #row.push(item.quantity)
                    row.push("#{item.mpn}")
                    if item.product_id != 0 and item.product_id != nil
                        row.push(Product.find(item.product_id).name)
                        row.push(Product.find(item.product_id).description)
                    else
                        row.push("")
                        row.push("")
                    end
                    if can? :work_d, :all
                        row.push(" ")
                        row.push(" ")
                        row.push(" ")
                    else
                        row.push("#{item.quantity}")
                        row.push("#{item.cost}")
                        row.push("#{item.price}")
                    end
                    if item.dn_id.blank?
                        row.push("")
                    else
                        begin
                            if PDn.find(item.dn_id).remark.blank?
                                row.push("")
                            else
                                row.push(PDn.find(item.dn_id).remark)
                            end
                        rescue
                            row.push("")
                        end
                    end
                    Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                    Rails.logger.info(item.all_info.inspect)
                    #Rails.logger.info(item.all_info.split("|",-1).inspect)
                    Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                    if not item.dn_id.blank?
                        Rails.logger.info("111111111111111")
                        #Rails.logger.info(request.protocol)
                        #Rails.logger.info(request.host_with_port)
                        #Rails.logger.info(PDn.find(item.dn_id).info_url.inspect)
                        #Rails.logger.info("111111111111111")
                        begin
                            if not PDn.find(item.dn_id).info_url.blank?
                                #row.push(request.protocol + request.host_with_port + PDn.find(item.dn_id).info_url)
                                row.push(Spreadsheet::Link.new request.protocol + request.host_with_port + PDn.find(item.dn_id).info_url, '技术资料')
                            else
                                row.push("")
                            end
                        rescue
                            row.push("")
                        end
                    else
                        row.push("")
                    end		 
                end

                #file_contents = StringIO.new
	        #ff.write (file_contents)
	        #send_data(file_contents.string.force_encoding('UTF-8'), filename: file_name)
                              
                ff.write (path+file_name)              
                send_file(path+file_name, type: "application/vnd.ms-excel")
                #send_file(path,filename: file_name, type: "application/vnd.ms-excel")    
    end

    def p_profit
        bom = ProcurementBom.find(params[:bom_id])
        
        t_p = 0
        t_pp = 0
        bom.p_items.each do |item|
            if not item.cost.blank?
                #t_p += item.cost*item.quantity
                t_p += item.cost*item.pmc_qty
                item.price = item.cost*(100+params[:profit].to_i)/100
                t_pp += item.price*item.quantity
                item.save
            end
        end
        #bom.t_p = t_p*bom.qty
        bom.t_p = t_p
        bom.profit = params[:profit].to_i
        bom.t_pp = t_pp*bom.qty
        bom.save
        redirect_to :back 
    end

    def del_cost
        @p_item = PItem.find(params[:id])
        Rails.logger.info("--------------------------")
        Rails.logger.info(@p_item.id.inspect)
        Rails.logger.info("--------------------------")
        if not @p_item.blank?
            @p_item.product_id = 0
            @p_item.moko_part = nil
            @p_item.moko_des = nil
            @p_item.cost = nil 
            @p_item.price = nil
            @p_item.color = ""
            @p_item.dn_id = nil
            @p_item.dn = nil
            @p_item.dn_long = nil
            @p_item.save
        end 
        PDn.where(p_item_id: params[:id],state: "").update_all "color=NULL"
        

        @bom = ProcurementBom.find(@p_item.procurement_bom_id)
        @match_str_nn = "#{@bom.p_items.count('product_id')+@bom.p_items.count('mpn_id')} / #{@bom.p_items.count}"
        @matched_items_nn = PItem.where(procurement_bom_id: @bom.id)   
        
        @total_price_nn = 0.00               
	if not @matched_items_nn.blank?
            @bom_api_all = []
	    @matched_items_nn.each do |item|
                if not item.cost.blank?
                    @total_price_nn += item.cost * item.quantity * @bom.qty.to_i 
                end                      
	    end
        end
        Rails.logger.info("--------------------------")
        Rails.logger.info(@total_price_nn.to_f.round(4))
        Rails.logger.info("--------------------------")
        @bom.t_p = @total_price_nn.to_f.round(4)
        @bom.state = ""
        @bom.save
    end

    def p_edit_mpn_moko
        item = MokoBomItem.find(params[:itemp_id])
        @p_item = item
        item.mpn = params[:item_mpn].strip
        item.save
    end

    def p_edit_mpn
        item = PItem.find(params[:itemp_id])
        @p_item = item
        item.mpn = params[:item_mpn].strip
        item.save

=begin
        item = PItem.find(params[:itemp_id])
        @p_item = item
        item.mpn = params[:item_mpn].strip
        use_mpn = Product.find_by_sql("SELECT * FROM products WHERE products.mpn LIKE '%#{item.mpn.strip}%'")
        if not use_mpn.blank?
            item.product_id = use_mpn.id          
            part_code = Product.find(item.product_id).name
            all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{part_code}' AND all_dns.qty >= 100 ORDER BY all_dns.date DESC").first
            if all_dns.blank?
                all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{part_code}' ORDER BY all_dns.date DESC").first
            end
            if not all_dns.blank?
                add_dns = PDn.new
                add_dns.item_id = @item.id
                add_dns.date = all_dns.date
                add_dns.part_code = all_dns.part_code
                add_dns.dn = all_dns.dn
                add_dns.dn_long = all_dns.dn_long
                add_dns.cost = all_dns.price
                add_dns.qty = all_dns.qty
                add_dns.color = "g"
                add_dns.save
                item.cost = add_dns.cost
                item.color = "g"
                item.dn_id = add_dns.id
                item.save
            else
                item.save
            end
        else
            item.product_id = 0
            item.cost = nil
            item.price = nil
            item.color = nil
            item.dn_id = nil
            item.save
        end
        @bom = ProcurementBom.find(item.procurement_bom_id)
        @match_str_nn = "#{@bom.p_items.count('product_id')+@bom.p_items.count('mpn_id')} / #{@bom.p_items.count}"
        @matched_items_nn = PItem.where(procurement_bom_id: @bom.id)      
        @total_price_nn = 0.00               
	if not @matched_items_nn.blank?
            @bom_api_all = []
	    @matched_items_nn.each do |item|
                if not item.cost.blank?
                    @total_price_nn += item.cost * item.quantity * @bom.qty.to_i 
                end                      
	    end
        end
        @bom.t_p = @total_price_nn
        @bom.save
        @dn_info = ""
        if DigikeysStock.find_by(manufacturer_part_number: item.mpn).blank?
            if MousersStock.find_by(manufacturer_part_number: item.mpn).blank?
                if item.link.blank? or item.link == ""
                    @dn_info += '<td class="text-center" style="padding: 0px;margin: 0px;"><small><a class="glyphicon glyphicon-info-sign" data-container="body" data-toggle="popover" tabindex="0"  data-trigger="hover" data-placement="top" data-content="NO DATA" href="http://www.digikey.com/product-search/en?keywords='+item.mpn+'" target="_blank"></a></small></td>'
                else
                    if item.link =~ /http/i
                        @dn_info += '<td class="text-center" style="padding: 0px;margin: 0px;"><small><a class="glyphicon glyphicon-info-sign" data-container="body" data-toggle="popover" tabindex="0"  data-trigger="hover" data-placement="top" data-content="NO DATA" href="http://' + item.link.split("http://")[-1].split(" ")[0] + '" target="_blank"></a></small></td>'
                    else
                        @dn_info += '<td class="text-center" style="padding: 0px;margin: 0px;"><small><a class="glyphicon glyphicon-info-sign" data-container="body" data-toggle="popover" tabindex="0"  data-trigger="hover" data-placement="top" data-content="NO DATA" href="http://www.digikey.com/product-search/en?keywords=' + item.mpn + '" target="_blank"></a></small></td>'
                    end
                end

                @dn_info += '<td class="text-center" style="padding: 0px;margin: 0px;"><small><a class="glyphicon glyphicon-picture" data-toggle="popover" tabindex="0"  data-trigger="hover" data-placement="top" data-content="NO DATA"></a></small></td>'
                                            
                @dn_info += '<td class="text-center" style="padding: 0px;margin: 0px;"><small><a class="glyphicon glyphicon-file" data-toggle="popover" tabindex="0"  data-trigger="hover" data-placement="top" data-content="NO DATA"></a></small></td>'
            else
#MousersStock
                if item.link.blank? or item.link == ""
                    @dn_info += '<td class="text-center" style="padding: 0px;margin: 0px;"><small><a class="glyphicon glyphicon-info-sign" data-container="body" data-toggle="popover" tabindex="0"  data-trigger="hover" data-placement="top"  data-content="' + MousersStock.find_by(manufacturer_part_number: item.mpn).description + ' ' + MousersStock.find_by(manufacturer_part_number: item.mpn).others.split("<name>Tolerance</name><value>")[-1].split("</value>")[0].to_s + '" ﻿http://www.mouser.com/Search/Refine.aspx?Keyword='+item.mpn+'" target="_blank"></a></small></td>'
                else
                    if item.link =~ /https:/i
                        @dn_info += '<td class="text-center" style="padding: 0px;margin: 0px;"><small><a class="glyphicon glyphicon-info-sign" data-container="body" data-toggle="popover" tabindex="0"  data-trigger="hover" data-placement="top" data-content="'+ MousersStock.find_by(manufacturer_part_number: item.mpn).description + ' ' + MousersStock.find_by(manufacturer_part_number: item.mpn).others.split("<name>Tolerance</name><value>")[-1].split("</value>")[0].to_s + '" href="https://' + item.link.split('https://')[-1].split(' ')[0] + '" target="_blank"></a></small></td>'
                    elsif item.link =~ /http:/i
                        @dn_info += '<td class="text-center" style="padding: 0px;margin: 0px;"><small><a class="glyphicon glyphicon-info-sign" data-container="body" data-toggle="popover" tabindex="0"  data-trigger="hover" data-placement="top" data-content="' + MousersStock.find_by(manufacturer_part_number: item.mpn).description + ' ' + MousersStock.find_by(manufacturer_part_number: item.mpn).others.split("<name>Tolerance</name><value>")[-1].split("</value>")[0].to_s + '" href="http://' + item.link.split('http://')[-1].split(' ')[0] + '" target="_blank"></a></small></td>'
                    else
                        @dn_info += '<td class="text-center" style="padding: 0px;margin: 0px;"><small><a class="glyphicon glyphicon-info-sign" data-container="body" data-toggle="popover" tabindex="0"  data-trigger="hover" data-placement="top"  data-content="' + MousersStock.find_by(manufacturer_part_number: item.mpn).description + ' ' + MousersStock.find_by(manufacturer_part_number: item.mpn).others.split("<name>Tolerance</name><value>")[-1].split("</value>")[0].to_s + '" href="﻿http://www.mouser.com/Search/Refine.aspx?Keyword='+item.mpn+'" target="_blank"></a></small></td>'
                    end
                end
                            
                @dn_info += '<td class="text-center" style="padding: 0px;margin: 0px;"><small><a class="glyphicon glyphicon-picture" data-toggle="popoverii" data-placement="right" data_src="' + MousersStock.find_by(manufacturer_part_number: item.mpn).image + '" href="' + MousersStock.find_by(manufacturer_part_number: item.mpn).image + '"  target="_blank" ></a></small></td>'
                                            
                @dn_info += '<td class="text-center" style="padding: 0px;margin: 0px;"><small><a class="glyphicon glyphicon-file" href="' +  MousersStock.find_by(manufacturer_part_number: item.mpn).datasheets + '" target="_blank"></a></small></td>'

#MousersStock

            end
        else
            if item.link.blank? or item.link == ""
                @dn_info += '<td class="text-center" style="padding: 0px;margin: 0px;"><small><a class="glyphicon glyphicon-info-sign" data-container="body" data-toggle="popover" tabindex="0"  data-trigger="hover" data-placement="top"  data-content="' + DigikeysStock.find_by(manufacturer_part_number: item.mpn).description + ' ' + DigikeysStock.find_by(manufacturer_part_number: item.mpn).others.split("<name>Tolerance</name><value>")[-1].split("</value>")[0].to_s + '" href="http://www.digikey.com/product-search/en?keywords='+item.mpn+'" target="_blank"></a></small></td>'
            else
                if item.link =~ /https:/i
                    @dn_info += '<td class="text-center" style="padding: 0px;margin: 0px;"><small><a class="glyphicon glyphicon-info-sign" data-container="body" data-toggle="popover" tabindex="0"  data-trigger="hover" data-placement="top" data-content="'+ DigikeysStock.find_by(manufacturer_part_number: item.mpn).description + ' ' + DigikeysStock.find_by(manufacturer_part_number: item.mpn).others.split("<name>Tolerance</name><value>")[-1].split("</value>")[0].to_s + '" href="https://' + item.link.split('https://')[-1].split(' ')[0] + '" target="_blank"></a></small></td>'
                elsif item.link =~ /http:/i
                    @dn_info += '<td class="text-center" style="padding: 0px;margin: 0px;"><small><a class="glyphicon glyphicon-info-sign" data-container="body" data-toggle="popover" tabindex="0"  data-trigger="hover" data-placement="top" data-content="' + DigikeysStock.find_by(manufacturer_part_number: item.mpn).description + ' ' + DigikeysStock.find_by(manufacturer_part_number: item.mpn).others.split("<name>Tolerance</name><value>")[-1].split("</value>")[0].to_s + '" href="http://' + item.link.split('http://')[-1].split(' ')[0] + '" target="_blank"></a></small></td>'
                else
                    @dn_info += '<td class="text-center" style="padding: 0px;margin: 0px;"><small><a class="glyphicon glyphicon-info-sign" data-container="body" data-toggle="popover" tabindex="0"  data-trigger="hover" data-placement="top"  data-content="' + DigikeysStock.find_by(manufacturer_part_number: item.mpn).description + ' ' + DigikeysStock.find_by(manufacturer_part_number: item.mpn).others.split("<name>Tolerance</name><value>")[-1].split("</value>")[0].to_s + '" href="http://www.digikey.com/product-search/en?keywords='+item.mpn+'" target="_blank"></a></small></td>'
                end
            end
                            
            @dn_info += '<td class="text-center" style="padding: 0px;margin: 0px;"><small><a class="glyphicon glyphicon-picture" data-toggle="popoverii" data-placement="right" data_src="' + DigikeysStock.find_by(manufacturer_part_number: item.mpn).image + '" href="' + DigikeysStock.find_by(manufacturer_part_number: item.mpn).image + '"  target="_blank" ></a></small></td>'
                                            
            @dn_info += '<td class="text-center" style="padding: 0px;margin: 0px;"><small><a class="glyphicon glyphicon-file" href="' +  DigikeysStock.find_by(manufacturer_part_number: item.mpn).datasheets + '" target="_blank"></a></small></td>'
        end
        Rails.logger.info("--------------------------")
        Rails.logger.info(@dn_info.inspect)             
        Rails.logger.info("--------------------------")
        #redirect_to :back
=end
    end

    def copy_data
        if not params[:bom_version].blank?
            source_data = PVersionItem.find(params[:item_id])
        else
            source_data = PItem.find(params[:item_id])
        end
        if not source_data.blank?
            if not params[:bom_version].blank?
                update_data = PVersionItem.where("procurement_bom_id = #{source_data.procurement_bom_id} AND trim(description) = '#{source_data.description.strip}'")
            else
                update_data = PItem.where("procurement_bom_id = #{source_data.procurement_bom_id} AND trim(description) = '#{source_data.description.strip}'")
            end
            update_data.update_all(product_id: source_data.product_id, cost: source_data.cost, price: source_data.price, dn_id: source_data.dn_id, color: source_data.color,moko_part: source_data.moko_part,moko_des: source_data.moko_des)
        end
        redirect_to :back
    end

    def p_del_bb
        p_bom = ProcurementBom.find(params[:bom_id])
        if can? :work_g_all, :all
            if p_bom.check != "do"
                p_bom.destroy
            end
        end
        redirect_to :back
    end

    def add_order
        p_bom = ProcurementBom.find(params[:bom_id])
        if can? :work_d, :all
            p_bom.order_do = "do"
            p_bom.save
        end
        redirect_to p_bomlist_path(order_list: true)
    end

    private
        class ColorFormat < Spreadsheet::Format
            def initialize(gb_color, font_color)
                super :pattern => 1, :pattern_fg_color => gb_color,:color => font_color, :text_wrap => 1
            end
        end

        def find_price(mpn_id,qty)
            mpn_info = InfoPart.find(mpn_id)
            @mpn_item = JSON.parse(mpn_info.info)    
            #naive_id_all = []
            part_all = []
            mf_all = []
            dm_all = []
            prices_all = []
            #Rails.logger.info(@mpn_item['response'].inspect)
            #mpn_stock = 0
            if @mpn_item['response'].blank?
                result = ""
            else
                @mpn_item['response'].each do |result|  
                    if result['distributor']['name'] == "Digi-Key"
                        result['parts'].each do |part|
                            part['price'].each do |f|     
                                if f.has_value?"USD"
                                    if f['quantity'].to_i >= qty.to_i
                                        prices_all << f['price'].to_f
                                        mf_all << part['manufacturer']
                                        dm_all << "Digi-Key"
                                    end
                                    #naive_id_all << result['distributor']['id']                                    
                                end
                            end
                            #mpn_stock += part['stock'].to_i
                        end  
                    else
                        result['parts'].each do |part|
                            part['price'].each do |f|     
                                if f.has_value?"USD"
                                    if f['quantity'].to_i >= qty.to_i
                                        prices_all << f['price'].to_f
                                        #Rails.logger.info("--------------------------")
                                        #Rails.logger.info(f['price'].to_f.inspect)
                                        mf_all << part['manufacturer']
                                        #Rails.logger.info("--------------------------")
                                        #Rails.logger.info(part['manufacturer'].inspect)
                                        dm_all << result['distributor']['name']
                                        #Rails.logger.info("--------------------------")
                                        #Rails.logger.info(result['distributor']['name'].inspect)
                                    end
                                    #naive_id_all << result['distributor']['id']                         
                                end
                            end
                            #mpn_stock += part['stock'].to_i
                        end  
                    end                                
                end
                #Rails.logger.info("--------------------------")
                #Rails.logger.info(mpn_id.inspect)
                #Rails.logger.info(prices_all.inspect)
                #Rails.logger.info(mf_all.inspect)
                #Rails.logger.info(dm_all.inspect)
                #Rails.logger.info("--------------------------")
                @mpn_result = []
                if not prices_all.blank?
                    @mpn_result << prices_all.min     
                    @mpn_result << mf_all[(prices_all.index prices_all.min)]   
                    @mpn_result << dm_all[(prices_all.index prices_all.min)]
                end
                result = @mpn_result
            end
        end


        def bom_params
  	    params.require(:bom).permit(:name, :excel_file)
  	end

        def other_baojia_params
  	    params.require(:bom).permit(:name, :excel_file)
  	end

        def bn_params
  	    params.require(:info).permit(:name, :info)
  	end

        def editbn_params
  	    params.require(:dn_info).permit(:info)
  	end

        def search_bom_use (query_str,mpn_str)
            if not mpn_str.blank?
                result1 = PItem.find_by_sql("SELECT * FROM p_items WHERE p_items.mpn = '" + mpn_str.to_s + "' AND p_items.dn_id IS NOT NULL ORDER BY p_items.created_at DESC").first
            end
            if result1.blank?
                Rails.logger.info("------------------------result.blank---------------------------")
                if not query_str.blank?
                    #result = PItem.find_by_sql("SELECT * FROM p_items WHERE p_items.description LIKE '%" + query_str.to_s.strip + "%' AND p_items.dn_id IS NOT NULL ORDER BY p_items.created_at DESC").first
                    result = PItem.find_by_sql("SELECT * FROM p_items WHERE p_items.description LIKE '%" + query_str.to_s.strip.gsub(/['"]/,"") + "%' AND p_items.dn_id IS NOT NULL ORDER BY p_items.created_at DESC").first
                end
            else
                result = result1
            end
        end

        def search_bom (query_str,part_code)
            #str = get_query_str(query_str)

            if not part_code.blank?
                ary2 = part_code.upcase.to_s.scan(/[A-Z]+/)
	        part_code = ary2[0]
            end
            str = get_query_str_new(query_str,part_code)            
            Rails.logger.info("0000000000000000000000000000000000000aaa")
            Rails.logger.info(str)
            Rails.logger.info("0000000000000000000000000000000aaaaaaaaa")
            
            return [] if str.blank?     
                part = Part.find_by(part_code: part_code)
                if part
                    
                    Rails.logger.info("0000000000000000000000000000000000000uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu")
                    Rails.logger.info(part.part_name)
                    Rails.logger.info(str)
                    Rails.logger.info("0000000000000000000000000000000uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu")
                    #if str.split(" ")[1].blank?
                        #result = Product.find_by_sql("SELECT * FROM `products` WHERE `value2` LIKE '%"+str.split(" ")[0]+"%' AND `ptype` = '"+part.part_name+"' ORDER BY `price`, `prefer` DESC").to_ary
                    #else
                        #result_w = Product.find_by_sql("SELECT * FROM `products` WHERE `value2` LIKE '%"+str.split(" ")[0]+"%' AND `value3` = '"+str.split(" ")[1]+"' AND `ptype` = '"+part.part_name+"' ORDER BY `price`, `prefer` DESC").to_ary
                        #if result_w.blank?
                            #if (part_code[0] =~ /[Cc]/ and str.split(" ")[0]=~ /[^uU]/)
                                #result = Product.find_by_sql("SELECT * FROM `products` WHERE `value2` LIKE '%"+str.split(" ")[0]+"%' AND `value3` = '50v' AND `ptype` = '"+part.part_name+"' ORDER BY `price`, `prefer` DESC").to_ary
                            #else
                                #result = Product.find_by_sql("SELECT * FROM `products` WHERE `value2` LIKE '%"+str.split(" ")[0]+"%' AND `ptype` = '"+part.part_name+"' ORDER BY `price`, `prefer` DESC").to_ary 
                            #end
                        #else
                            #result = result_w 
                        #end
                    #end
                    if part.part_name == "CAP" or part.part_name == "RES"
                        if str.split(" ")[0] == "nothing" 
                            str = get_query_str(query_str.to_s)     
                        end 
                    end
                    if str.split(" ")[-1] == "nothing" or str.split(" ")[-1] == "Q" or str.split(" ")[-1] == "D"
                        sql_a = "SELECT * FROM `products` WHERE `description` LIKE '%"+str.split(" ")[0]+"%'"
                        #sql_b = " ORDER BY `prefer` DESC" 
                        sql_b = ""
                    else
                        if str.split(" ")[0] == "0R" or str.split(" ")[0] == "0r" or str.split(" ")[0] == "0o" or str.split(" ")[0] == "0O"
                            sql_a = "SELECT * FROM `products` WHERE `value2` = '"+str.split(" ")[0]+"'"
                        else
                            #sql_a = "SELECT * FROM `products` WHERE `value2` LIKE '%"+str.split(" ")[0]+"%'" 
                            sql_a = "SELECT * FROM `products` WHERE `value2` = '"+str.split(" ")[0]+"'"
                        end
                    end
                    tan_tag = ""
                    if query_str.to_s =~ /t491/i or query_str.to_s =~ /tant/i
                        sql_a = sql_a  + " AND `part_name` = '钽电容'" 
                        tan_tag = "tan"
                    elsif query_str.to_s =~ /radial/i   
                        sql_a = sql_a  + " AND `part_name` = '电解电容'" 
                        tan_tag = "tan"
                    elsif query_str.to_s =~ /led/i   
                        tan_tag = "tan"  
                    #elsif query_str.to_s =~ /SMD/i   
                        #sql_a = sql_a  + " AND `value1` LIKE '%贴片%'" 
                        #tan_tag = "tan"               
                    end
                    #sql_b = " ORDER BY `prefer` DESC" 
                    sql_b = ""
                    unless  str.split(" ")[2].blank? or str.split(" ")[2] == "nothing"
                        find_bom = " AND `package2` = '"+str.split(" ")[2]+"' "
                    else
                        find_bom = ""
                    end
                    if str.split(" ")[1].blank? or str.split(" ")[1] == "nothing" or tan_tag == "tan" 
                        Rails.logger.info("0")
                        if query_str.to_s =~ /led/i 
                            led_package2_all = Product.find_by_sql("SELECT products.package2, products.ptype FROM products WHERE products.ptype = 'LED' AND products.package2 <> '' GROUP BY products.package2")
                            led_p_all = led_package2_all.select { |item| query_str.to_s.include?item.package2.to_s }
                            if not led_p_all.blank?
                                Rails.logger.info("led_p_all.first.package2__________0000000000000000000000000000000000000bbbbb_________")
                                Rails.logger.info(led_p_all.first.package2)
                                Rails.logger.info("led_p_all.first.package2_________0000000000000000000000000000000000000bbbbb________") 
                                led_package = led_p_all.first.package2
                                find_led_p = " AND `package2` = '"+led_package.to_s+"'"                
                            else
                                find_led_p = ""
                            end 
                            if query_str.to_s =~ /green/i 
                                result_w = Product.find_by_sql("SELECT * FROM `products` WHERE `value1` = '绿灯' AND `part_name` = 'LED'"+find_led_p).to_ary
                            elsif query_str.to_s =~ /red/i 
                                result_w = Product.find_by_sql("SELECT * FROM `products` WHERE `value1` = '红灯' AND `part_name` = 'LED'"+find_led_p).to_ary
                            elsif query_str.to_s =~ /blue/i 
                                result_w = Product.find_by_sql("SELECT * FROM `products` WHERE `value1` = '蓝灯' AND `part_name` = 'LED'"+find_led_p).to_ary
                            elsif query_str.to_s =~ /yellow/i 
                                result_w = Product.find_by_sql("SELECT * FROM `products` WHERE `value1` = '黄灯' AND `part_name` = 'LED'"+find_led_p).to_ary
                            elsif query_str.to_s =~ /white/i 
                                result_w = Product.find_by_sql("SELECT * FROM `products` WHERE `value1` = '白灯' AND `part_name` = 'LED'"+find_led_p).to_ary
                            elsif query_str.to_s =~ /orange/i 
                                result_w = Product.find_by_sql("SELECT * FROM `products` WHERE `value1` = '橙灯' AND `part_name` = 'LED'"+find_led_p).to_ary
                            else
                                result_w = Product.find_by_sql("SELECT * FROM `products` WHERE `description` LIKE '%"+str.split(" ")[0]+"%' AND `part_name` = 'LED'"+find_led_p).to_ary
                            end
                        else
                            result_w = Product.find_by_sql(sql_a+" AND `ptype` = '"+str.split(" ")[-1]+"' "+find_bom+sql_b).to_ary
                        end




                        
                        if result_w.blank?
                            Rails.logger.info("1")
                            result_w = Product.find_by_sql(sql_a+" AND `ptype` = '"+str.split(" ")[-1]+"'"+sql_b).to_ary
                        else
                            Rails.logger.info("2")
                            result = result_w 
                        end
                    else
                        Rails.logger.info("3")
                        result_w = Product.find_by_sql(sql_a+" AND `value3` = '"+str.split(" ")[1]+"' AND `ptype` = '"+part.part_name+"' "+find_bom+sql_b).to_ary
                        if result_w.blank?
                            Rails.logger.info("4")
                            result_w = Product.find_by_sql(sql_a+" AND `value3` = '"+str.split(" ")[1]+"' AND `ptype` = '"+part.part_name+"'"+  sql_b).to_ary
                            if result_w.blank?
                                Rails.logger.info("5")
                                if (part_code[0] =~ /[Cc]/ and str.split(" ")[0]=~ /[^uU]/)
                                    Rails.logger.info("6")
                                    result_w = Product.find_by_sql(sql_a+" AND `value3` = '50v' AND `ptype` = '"+str.split(" ")[-1]+"' "+find_bom+sql_b).to_ary
                                    if result_w.blank?
                                        Rails.logger.info("7")
                                        result_w = Product.find_by_sql(sql_a+" AND `value3` = '50v' AND `ptype` = '"+str.split(" ")[-1]+"'"+sql_b).to_ary    
                                    else
                                        Rails.logger.info("8")
                                        result = result_w 
                                    end
                                else
                                    Rails.logger.info("9")
                                    result_w = Product.find_by_sql(sql_a+" AND `ptype` = '"+str.split(" ")[-1]+"' "+find_bom+sql_b).to_ary
                                    if result_w.blank?
                                        Rails.logger.info("11")
                                        result_w = Product.find_by_sql(sql_a+" AND `ptype` = '"+str.split(" ")[-1]+"'"+sql_b).to_ary
                                    else
                                        Rails.logger.info("12")
                                        result = result_w
                                    end 
                                end
                            else
                                Rails.logger.info("13")
                                result = result_w 
                            end
                        else
                            Rails.logger.info("14")
                            result = result_w     
                        end
                    end





                    
  	  	    #result = Product.search(str,conditions: {part_name: part.part_name},star: true,order: 'prefer DESC').to_ary
                    Rails.logger.info("qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq222222222222222222")
                    #Rails.logger.info(result.inspect)
                    Rails.logger.info("qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq2222222222222222222222222222")
  	            #如果匹配不到产品，则只使用关键字串全局匹配，不需要匹配原件类型
  	  	    if result_w.length == 0
                        Rails.logger.info("15") 
                        
                        #result = Product.search(str,star: true,order: 'prefer DESC').to_ary
                        #result_w = Product.find_by_sql("SELECT * FROM `products` WHERE `description` LIKE '%"+str.split(" ")[0]+"%' ORDER BY `prefer` DESC").to_ary
                        result_w = Product.find_by_sql("SELECT * FROM `products` WHERE `description` LIKE '%"+str.split(" ")[0]+"%' ").to_ary
  	  		#如果全局匹配不到，则需要检查关键字串中的单位，转换成标准的单位
  	  		if result_w.length == 0
                            
  	  		    #匹配出单位的字符串
  	  		    ary_unit = str.scan(/([a-zA-Z]+)/)
  	  		    #如果匹配出多个，则提示错误
                            if ary_unit.length > 1
  	  		        Rails.logger.info(t('error_a'))
  	  		    else
  	  		        #从unit表查找对应的目标单位字符串
  	  		        ary_unit = ary_unit.join("")
  	  		        unit = Unit.find_by(unit: ary_unit)
  	  		        unless unit
  	  		            Rails.logger.info(t('error_b'))
  	  		        else
  	  		            #用查询得到的标准单位替换关键字串中的单位
  	  		            str.sub!(/[a-zA-Z]+/, unit.targetunit)
  	  		            #result_w = Product.search(str,conditions: {part_name: part.part_name},star: true,order: 'prefer DESC').to_ary
                                    result_w = Product.search(str,conditions: {part_name: part.part_name},star: true).to_ary
                                    #result = Product.search(str,conditions: {part_name: part.part_name},star: true).to_ary
  	  		            if result_w.length == 0
  	                                #全局匹配
  			                result_w = Product.search(str,star: true,order: 'prefer DESC').to_ary
                                        result_w = Product.search(str,star: true).to_ary
                                        #result = Product.search(str,star: true).to_ary
     		                        if result_w.length == 0
	  		                    Rails.logger.info(t('error_c'))
	  		                end
  	  		            end
  	  		        end
  	  		    end
  	  		end  	
  	  		result = result_w  		  
                    else
  	  		result = result_w #返回已经匹配的result
  	            end
  	  	else
                    #result = Product.search(str,star: true,order: 'prefer DESC').to_ary
                    Rails.logger.info("1111")
                    #result_w = Product.find_by_sql("SELECT * FROM `products` WHERE `description` LIKE '%"+str.split(" ")[0]+"%' ORDER BY `prefer` DESC").to_ary
                    result_w = Product.find_by_sql("SELECT * FROM `products` WHERE `description` LIKE '%"+str.split(" ")[0]+"%' ").to_ary
                    #result = Product.search(str,star: true).to_ary
                    result = result_w
  	  	end
            result = result_w
        end

  	def get_query_str(query_str)
            Rails.logger.info("gogogogogogogogogogogogogogogogogogogogogo!!!!!!!!!!!!!!!!!!!!!1111")
  	    # ary_nc = query_str.scan(/[0-9]+\.?[0-9]*[a-zA-Z]+/i)
  	    # ary_n = query_str.scan(/[0-9]+[%]*/)
  	    # ary_q = ary_nc | ary_n 
  	    # ary_q.join(" ")
  	    #ary_q = query_str.scan(/([0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)

            #start
            #ary_q = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
  	    #ary_q.join(" ")
            #判断是否电容
            if query_str =~ /[Μµμ]/
                query_str.gsub!(/[Μµμ]/, "u")
            end
            if query_str.include?".0uF"
                query_str[".0uF"]="uF"
            elsif query_str.include?"0.1uF"
                query_str["0.1uF"]="100nF"
            elsif query_str.include?"0.1UF"
                query_str["0.1UF"]="100nF" 
            end
            if query_str.include?"Y5V"    
                query_str["Y5V"]=""
            end   
            ary_all = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
            #value2_all = ary_all.join(" ").split(" ").grep(/[uUnNpPmM]/)
            #value2 = "nothing"
            #ary_q = []
            #if value2_all != []
                #value2 = value2_all.join(" ").scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[uUnNpPmM]|[0-9]\.?[0-9]*[uUnNpPmM])/)
            #end
            #获取容值
            ary_q = []
            value2_test = query_str.to_s.scan(/[0-9]*[uUnNpPmMμ][0-9]/)            
            value2_use = "nothing"
            if value2_test != []
                value2_use = value2_test[0].to_s.sub(/[uUnNpPmMμ]/, ".") + value2_test[0].to_s.scan(/[uUnNpPmMμ]/)[0]
            else
                value2_all = ary_all.join(" ").to_s.split(" ").grep(/[uUnNpPmMμ]/)                 
                if value2_all != []
                    value2 = /[+-]?([0-9]*\.?[0-9]+|[0-9]+\.?[0-9]*)([eE][+-]?[0-9]+)?[uUnNpPmMμ]+[F]?/.match(value2_all.join(" ").to_s)
                    if value2.blank?
                        value2_use = "nothing"
                    else
                        value2_use = value2[0]
                    end                        
                end
            end
            #获取电压
            if value2_use != "nothing"
                value3_all = ary_all.join(" ").split(" ").grep(/[vV]/)
                value3 = "50v"
                if value3_all != []
                    value3 = value3_all[0]
                end
                Rails.logger.info("value2_use-------------------------------------------------------------value2_usevalue2_usevalue2_use")
                Rails.logger.info(value2_use.inspect)
                Rails.logger.info("value2_use-------------------------------------------------------------value2_usevalue2_usevalue2_use")
                if not value2_use =~ /f/i
                    value2_use = value2_use + "F"
                end
                if value2_use =~ /pf/i
                    Rails.logger.info("value2_use-------------------------------------------------------------value2_usevalue2_usevalue2_use")
                    if value2_use.gsub(/\D/, "").to_i > 999
                        Rails.logger.info("value2_use---------999999---------999-----value2_999")
                        Rails.logger.info(value2_use.inspect)
                        value2_use = (value2_use.gsub(/\D/, "").to_i.to_i/1000).to_s + "nF"
                        Rails.logger.info(value2_use.inspect)
                        Rails.logger.info("value2_use---------999999---------999-----value2_999")
                    end
                end
                ary_q[0] = value2_use
                ary_q[1] = value3
                package2_all = Product.find_by_sql("SELECT products.package2, products.ptype FROM products WHERE products.ptype = 'CAP' GROUP BY products.package2")
                value4_all = package2_all.select { |item| ary_all.join(" ").include?item.package2 }
                if not value4_all.blank?                  
                    ary_q[2] = value4_all.first.package2
                    if "ABCDE".include?ary_q[2]
                        if not query_str.include?"tantalum" or query_str.include?"Tantalum" or query_str.include?"TANTALUM"
                            ary_q[2] = "nothing"    
                        end  
                    end
                else
                    ary_q[2] = "nothing"
                end
                ary_q[3] = "CAP"
            else
                #判断是否电阻
                if query_str.include?"o"
                    query_str = query_str.gsub("o","r")
                end
                if query_str.include?"O"
                    query_str = query_str.gsub("O","r")
                end
                if query_str.include?"Ω"
                    query_str = query_str.gsub("Ω","r")
                end
                if query_str.include?"Ω"
                    query_str = query_str.gsub("Ω","r")
                end
                if query_str.include?"e"
                    query_str = query_str.gsub("e","r")
                end
                if query_str.include?"E"
                    query_str = query_str.gsub("E","r")
                end
                #ary_all = query_str.to_s.scan(/([0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                
                ary_all = query_str.to_s.scan(/[0-9]\.?[0-9]*[mMkKuUrRΩΩ][0-9]\.?[0-9]*/)
                if not ary_all.blank?
                    value2 = ary_all.join("").scan(/[mMkKuUrRΩΩ]/)
                end
                ary_all = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                #获取阻值
                ary_q = []
                value2_test = query_str.to_s.scan(/[0-9]*[mMkKuUrRΩΩ][0-9]/)
                Rails.logger.info("value2_test!!!!!!!!!!!!!!!!!!!!!!!!!!!value2_test")
                Rails.logger.info(query_str.inspect)
                Rails.logger.info(value2_test.inspect)
                Rails.logger.info("value2_test!!!!!!!!!!!!!!!!!!!!!!!!!!!value2_test")
                value2_use = "nothing"
                if value2_test != []
                    value2_use = value2_test[0].to_s.sub(/[mMkKuUrRΩΩ]/, ".") + value2_test[0].to_s.scan(/[mMkKuUrRΩΩ]/)[0]
                else
                    value2_all = ary_all.join(" ").to_s.split(" ").grep(/[mMkKuUrRΩΩ]/)
                    Rails.logger.info("rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr")
                    Rails.logger.info(query_str.inspect)
                    Rails.logger.info(ary_all.inspect)
                    Rails.logger.info(value2_test.inspect)
                    Rails.logger.info("rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrvalue2_all")
                    Rails.logger.info(value2_all.inspect)
                    Rails.logger.info("rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrvalue2_all")
                
                    
                    if value2_all != []
                        #value2 = /[+-]?([0-9]*\.?[0-9]+|[0-9]+\.?[0-9]*)([eE][+-]?[0-9]+)?[mMkKuUrR]/.match(value2_all.join(" ").to_s)
                        value2 = /([0-9]*\.?[0-9]+|[0-9]+\.?[0-9]*)([eE][0-9]+)?[mMkKuUrR]/.match(value2_all.join(" ").to_s)
                        if value2.blank?
                            value2_use = "nothing"
                        else
                            value2_use = value2[0]
                        end
                        #value2 = query_str.to_s.scan(/-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)*[mMkKuUrR]|-?[1-9]\d*[mMkKuUrR]/)
                        
                    end
                end
                if value2_use != "nothing"
                    Rails.logger.info("rrrrrrrrrrrrr获取电压")
                    #获取电压
                    value3_all = ary_all.join(" ").split(" ").grep(/[vV]/)
                    value3 = "nothing"
                    if value3_all != []
                        value3 = value3_all[0]
                    end
                    ary_q[0] = value2_use
                    ary_q[1] = value3
                    #获取封装
                    Rails.logger.info("rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr获取封装")
                    package2_all = Product.find_by_sql("SELECT products.package2, products.ptype FROM products WHERE products.ptype = 'RES' GROUP BY products.package2")
                    value4_all = package2_all.select { |item| ary_all.join(" ").include?item.package2 }
                    if not value4_all.blank? 
                        ary_q[2] = value4_all.first.package2
                        value4 = value4_all.first.package2
                    else
                        ary_q[2] = "nothing"
                    end
                    ary_q[3] = "RES"

                    #if  value2 == "nothing" and value3 == "nothing" and ary_q[2] == "nothing"
                        #ary_q = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                    #end
                else
                    Rails.logger.info("rrrrrrrrrrrrr判断是否IC")
                    #判断是否IC
                    ary_q = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                    ary_q << "nothing"
                end
            end
            ary_q.join(" ")
  	end

        def get_query_str_new(query_str,part_code)
            
            part = Part.find_by(part_code: part_code)
            query_str = query_str.to_s
            #if  ( part_code[0] =~ /[Cc]/ )
            if  ( part and part.part_name == "CAP" )
                Rails.logger.info("ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc")
                Rails.logger.info("ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc")
                Rails.logger.info("ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc")
                if query_str =~ /[Μµμ]/
                    query_str.gsub!(/[Μµμ]/, "u")
                end
                Rails.logger.info("--------------------------------------------------------------11")
                Rails.logger.info(query_str)
                Rails.logger.info("---------------------------------------------------------------11")
                if query_str.include?".0uF"
                    query_str[".0uF"]="uF"
                elsif query_str.include?"0.1uF"
                    query_str["0.1uF"]="100nF"
                elsif query_str.include?"0.1UF"
                    query_str["0.1UF"]="100nF"
                elsif query_str.include?"μ"
                    query_str["μ"]="u"
                elsif query_str.include?"µ"
                    query_str["µ"]="u"
                end
                if query_str.include?"Y5V"    
                    query_str["Y5V"]=""
                end 
                Rails.logger.info("--------------------------------------------------------------22")
                Rails.logger.info(query_str)
                Rails.logger.info("---------------------------------------------------------------22")
                #ary_all = query_str.to_s.scan(/([0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                ary_all = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                Rails.logger.info("____________________________________________0000000000000000000000000000000000000bbbbb")
                Rails.logger.info(ary_all)
                Rails.logger.info("______________________________________________0000000000000000000000000000000000000bbbbb")
                #ary_q.find{|v| v.include?"u"}
                #ary_q.grep(/u|n|p|m/)
                
                
                #value2_all = ary_all.join(" ").split(" ").grep(/[uUnMpPmMμ]/)
                #value2 = "nothing"
                #ary_q = []
                #if value2_all != []
                    #value2 = value2_all[0]
                #end
                #获取容值
                ary_q = []
                value2_test = query_str.to_s.scan(/[0-9]+[uUnNpPmM][0-9]/)            
                value2_use = "nothing"
                if value2_test != []
                    value2_use = value2_test[0].to_s.sub(/[uUnNpPmM]/, ".") + value2_test[0].to_s.scan(/[uUnNpPmM]/)[0]
                else
                    value2_all = ary_all.join(" ").to_s.split(" ").grep(/[uUnNpPmM]/)                 
                    if value2_all != []
                        value2 = /[+-]?([0-9]*\.?[0-9]+|[0-9]+\.?[0-9]*)([eE][+-]?[0-9]+)?[uUnNpPmM]+[F]?/.match(value2_all.join(" ").to_s)
                        if value2.blank?
                            value2_use = "nothing"
                        else
                            value2_use = value2[0]
                            if value2_use =~ /\./
                                value2_use = value2_use.gsub(/[A-Za-z]/, "").to_s.gsub(/(\.?0+$)/,"").gsub(/(\.+)/,".")+value2_use.scan(/[A-Za-z]+/)[0].to_s
                            end
                        end                        
                    end
                end
                #获取电压
                value3_all = ary_all.join(" ").split(" ").grep(/[vV]/)
                value3 = "50v"
                if value3_all != []
                    value3 = value3_all[0]
                end
                Rails.logger.info("value2_use-------------------------------------------------------------value2_usevalue2_usevalue2_use")
                Rails.logger.info(value2_use.inspect)
                Rails.logger.info("value2_use-------------------------------------------------------------value2_usevalue2_usevalue2_use")
                if not value2_use =~ /f/i
                    value2_use = value2_use + "F"
                end
                if value2_use =~ /pf/i
                    Rails.logger.info("value2_use-------------------------------------------------------------value2_usevalue2_usevalue2_use")
                    if value2_use.gsub(/\D/, "").to_i > 999
                        Rails.logger.info("value2_use---------999999---------999-----value2_999")
                        Rails.logger.info(value2_use.inspect)
                        value2_use = (value2_use.gsub(/\D/, "").to_i.to_i/1000).to_s + "nF"
                        Rails.logger.info(value2_use.inspect)
                        Rails.logger.info("value2_use---------999999---------999-----value2_999")
                    end
                
                end
                
                ary_q[0] = value2_use
                ary_q[1] = value3
                package2_all = Product.find_by_sql("SELECT products.package2, products.ptype FROM products WHERE products.ptype = 'CAP' GROUP BY products.package2")
                value4_all = package2_all.select { |item| ary_all.join(" ").include?item.package2 }
                if not value4_all.blank?
                    Rails.logger.info("__________0000000000000000000000000000000000000bbbbb___________________________")
                    #Rails.logger.info(value4_all.first.package2)
                    Rails.logger.info("_________0000000000000000000000000000000000000bbbbb_______________________________") 
                    ary_q[2] = value4_all.first.package2
                else
                    ary_q[2] = "nothing"
                end
                if ary_q[2] != "nothing" and ary_q[0] =~ /uf/i
                    Rails.logger.info("uf--------------------------------uf--------------uf_uf_uf_uf")
                    #Rails.logger.info(value2_use.gsub(/[a-zA-Z]/, ""))
                    Rails.logger.info("uf--------------------------------uf--------------uf_uf_uf_uf")
                    if ary_q[0].gsub(/[a-zA-Z]/, "").to_f < 1
                        ary_q[0] = (value2_use.gsub(/[a-zA-Z]/, "").to_f*1000).to_i.to_s + "nF"
                    end
                end
                ary_q[3] = "CAP"
                #ary_q = value2 + " " + value3
                Rails.logger.info("0000000000000000000000000000000000000bbbbb1111111111111111")
                Rails.logger.info(value2_all.inspect)
                Rails.logger.info(value3_all.inspect)
                Rails.logger.info("0000000000000000000000000000000000000bbbbb111111111111111111")
            #elsif  ( part_code[0] =~ /[Rr]/ )
            elsif  ( part and part.part_name == "RES" )
                if query_str.include?"o"
                    query_str = query_str.gsub("o","r")
                end
                if query_str.include?"O"
                    query_str = query_str.gsub("O","r")
                end
                if query_str.include?"Ω"
                    query_str = query_str.gsub("Ω","r")
                end
                if query_str.include?"Ω"
                    query_str = query_str.gsub("Ω","r")
                end
                if query_str.include?"e"
                    query_str = query_str.gsub("e","r")
                end
                if query_str.include?"E"
                    query_str = query_str.gsub("E","r")
                end
                Rails.logger.info("rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr")
                Rails.logger.info("rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr")
                Rails.logger.info("rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr")
                #ary_all = query_str.to_s.scan(/([0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                ary_all = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                #处理电阻
                ary_q = []
                #获取封装
                Rails.logger.info("获取封装!!!!!!!!!!!!!!!!!!!!!!!!!!!获取封装")
                Rails.logger.info(ary_all.inspect)
                Rails.logger.info(ary_all.join(" ").inspect)
                Rails.logger.info("获取封装!!!!!!!!!!!!!!!!!!!!!!!!!!!获取封装")
                package2_all = Product.find_by_sql("SELECT products.package2, products.ptype FROM products WHERE products.ptype = 'RES' GROUP BY products.package2")
                value4_all = package2_all.select { |item| ary_all.join(" ").include?item.package2 }
                if not value4_all.blank?
                    ary_q[2] = value4_all.first.package2
                    Rails.logger.info("获取封装!!!!!!!!!!!!!!!!!!!!!!!!!!!获取封装000000000000000000000bbbbb___________________________")
                    Rails.logger.info(value4_all.inspect)
                    Rails.logger.info(ary_q[2].inspect)
                    Rails.logger.info("获取封装!!!!!!!!!!!!!!!!!!!!!!!!!!!获取封装0000bbbbb_______________________________") 

                else
                    ary_q[2] = "nothing"
                end
                #获取阻值
                value2_test = query_str.to_s.scan(/[0-9]+[mMkKuUrRΩΩ][0-9]/)
                Rails.logger.info("value2_test!!!!!!!!!!!!!!!!!!!!!!!!!!!value2_test")
                Rails.logger.info(query_str.inspect)
                Rails.logger.info(value2_test.inspect)
                Rails.logger.info("value2_test!!!!!!!!!!!!!!!!!!!!!!!!!!!value2_test")
                value2_use = "nothing"
                if value2_test != []
                    value2_use = value2_test[0].to_s.sub(/[mMkKuUrRΩ﻿Ω]/, ".") + value2_test[0].to_s.scan(/[mMkKuUrRΩ﻿Ω]/)[0]
                else
                    value2_all = ary_all.join(" ").to_s.split(" ").grep(/[mMkKuUrRΩ]/)
                    Rails.logger.info("rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr")
                    Rails.logger.info(query_str.inspect)
                    Rails.logger.info(ary_all.inspect)
                    Rails.logger.info(value2_test.inspect)
                    Rails.logger.info("rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr")
                    Rails.logger.info("rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr")
                
                    
                    if value2_all != []
                        #value2 = /[+-]?([0-9]*\.?[0-9]+|[0-9]+\.?[0-9]*)([eE][+-]?[0-9]+)?[mMkKuUrR]/.match(value2_all.join(" ").to_s)
                        value2 = /([0-9]*\.?[0-9]+|[0-9]+\.?[0-9]*)([eE][0-9]+)?[mMkKuUrR]/.match(value2_all.join(" ").to_s)
                        if value2.blank?
                            value2_use = "nothing"
                        else
                            value2_use = value2[0]
                            if value2_use =~ /\./
                                value2_use = value2_use.gsub(/[A-Za-z]/, "").to_s.gsub(/(\.?0+$)/,"").gsub(/(\.+)/,".")+value2_use.scan(/[A-Za-z]+/)[0].to_s  
                                if value2_use.gsub(/[A-Za-z]/, "").to_f < 1 and value2_use.scan(/[A-Za-z]+/)[0].to_s =~ /m/i 
                                    value2_use = (value2_use.gsub(/[A-Za-z]/, "").to_f*1000).to_i.to_s + "k"
                                end 
                            end
                        end
                        #value2 = query_str.to_s.scan(/-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)*[mMkKuUrR]|-?[1-9]\d*[mMkKuUrR]/)
                        
                    end
                end
                Rails.logger.info("0000000000000000000000000000000000000bbbbb2222222222222222222222")
                #Rails.logger.info(value2_all.join(" ").to_s.inspect)
                Rails.logger.info(value2_use.inspect)
                Rails.logger.info("0000000000000000000000000000000000000bbbbb2222222222222222222222")
                #获取电压
                value3_all = ary_all.join(" ").split(" ").grep(/[vV]/)
                value3 = "nothing"
                if value3_all != []
                    value3 = value3_all[0]
                end
                if value2_use == "nothing"
                    query_str = query_str.gsub(/[±]?+[1-9]+[%]/," ") 
                    query_str = query_str.gsub(/\D/, " ")
                    value2_try = query_str.split(" ")[0]
                    if value2_try != ""
                        value2_use = value2_try.to_s + "R"
                    end
                end

                ary_q[0] = value2_use
                ary_q[1] = value3
                
                if value2 == "nothing" and value3 == "nothing" and ary_q[2] == "nothing"
                    ary_q = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                end
                ary_q[3] = "RES"
                #ary_q = value2 + " " + value3
                Rails.logger.info("0000000000000000000000000000000000000bbbbb1111111111111111")
                Rails.logger.info(value2_all.inspect)
                Rails.logger.info(value3_all.inspect)
                Rails.logger.info("0000000000000000000000000000000000000bbbbb111111111111111111")
            elsif  ( part and part.part_name == "IC" )
                #ary_q = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[a-zA-Z]*[0-9]+[a-zA-Z]*|[0-9]+(?!\W)|[%]+)/)
                query_str_all = ""
                query_str.split(" ").each do |item_q|
                    if item_q.to_s[-2..-1] =~ /e4/i or item_q.to_s[-2..-1] =~ /tr/i 
                        item_q.to_s[-2..-1] = ""
                    elsif item_q.to_s[-3..-1] =~ /pbf/i 
                        item_q.to_s[-3..-1] = ""
                    end
                    query_str_all = query_str_all + " " + item_q
                end
                query_str = query_str_all
                #ary_q = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                ary_q = query_str.to_s.scan(/([a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+[a-zA-Z]*-?\d*\.*\d*)/)
                use_ic = ""
                ary_q.join(" ").split(" ").each do |i|
	            if i.include?"-"
		        use_ic = i
		        #puts use_ic
	            end
                end
                if use_ic != ""
	            ary_q = [] 
	            ary_q << use_ic
	            puts ary_q
                end	
                ary_q[3] = "IC"
            elsif  ( part and part.part_name == "Q" )
                Rails.logger.info("QQQ---------------------------------------------------------QQQ")              
                ary_q = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                ary_q[3] = "Q"
            elsif  ( part and part.part_name == "D" )
                Rails.logger.info("DDD---------------------------------------------------------DDD")
                ary_q = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                ary_q[3] = "D"
            elsif  ( part and part.part_name == "IN" )
                Rails.logger.info("IN---------------------------------------------------------IN")
                ary_q = []
                ary_q << query_str.to_s.strip
                ary_q << "IN"
            elsif  ( part and part.part_name == "FB" )
                Rails.logger.info("FB---------------------------------------------------------FB")
                ary_q = []
                ary_q << query_str.to_s.strip
                ary_q << "FB"
            else
                Rails.logger.info("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                Rails.logger.info("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                Rails.logger.info("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                #ary_q = query_str.to_s.scan(/([0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/) 
                ary_q = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                ary_q << "nothing"
            end
            ary_q.join(" ")
            #ary_q = query_str.to_s.scan(/([0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
  #ary_q = query_str.scan(/([a-zA-Z]+[0-9]\.?[0-9]*[a-zA-Z]+|[0-9]\.?[0-9]+[a-zA-Z]+|[0-9]+|[0-9]+(?!\W)|[%]+)/)
            #                         ([a-zA-Z]+[0-9]\.?[0-9]*[a-zA-Z]+|[0-9]\.?[0-9]+[a-zA-Z]+|[0-9]+|[%]+)
  	    
        end







end
