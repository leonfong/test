require 'will_paginate/array'
require 'roo'
require 'spreadsheet'
require 'axlsx'
class WorkFlowController < ApplicationController
before_filter :authenticate_user!

    def wh_out
        @whlist = WhOutInfo.all.order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
    end

    def new_wh_out
        if params[:wh_out_no] == "" or params[:wh_out_no] == nil
            if WhOutInfo.find_by_sql('SELECT wh_out_no FROM wh_out_infos WHERE to_days(wh_out_infos.created_at) = to_days(NOW())').blank?
                pi_n =1
            else
                pi_n = WhOutInfo.find_by_sql('SELECT wh_out_no FROM wh_out_infos WHERE to_days(wh_out_infos.created_at) = to_days(NOW())').last.wh_out_no.split("WHGET")[-1].to_i + 1
            end
            @wh_no = "MO"+current_user.s_name_self.to_s.upcase  + Time.new.strftime('%y').to_s + Time.new.strftime('%m%d').to_s + "WHOUT"+ pi_n.to_s

            wh_info = WhOutInfo.new
            wh_info.wh_out_no = @wh_no
            wh_info.wh_out_user = current_user.email
            wh_info.state = "new"
            #wh_info.site = "c"            
            wh_info.save
            wh_out_no = wh_info.wh_out_no
        else
            wh_out_no = params[:wh_out_no]
        end
        #@pcblist = PcbOrder.where(state: "quotechk").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
        redirect_to edit_wh_out_path(wh_out_no: wh_out_no) and return 
    end

    def edit_wh_out
        @wh_info = WhOutInfo.find_by(wh_out_no: params[:wh_out_no])
        @wh_item = WhOutItem.where(wh_out_info_no: params[:wh_out_no])
    end

    def find_wh_out
#要给成从仓库查询
        if not params[:wh_out_info_id].blank?
            bom_data = WarehouseInfo.find_by_erp_no_son(params[:bom_no])
            @bom_list_data = ""
            if not bom_data.blank?
                @bom_list_data += '<small>'
                @bom_list_data += '<table class="table table-bordered">'
                @bom_list_data += '<thead>'
                @bom_list_data += '<tr class="active">'
                @bom_list_data += '<th >PI NO.</th>'
                @bom_list_data += '<th >MOKO PART</th>'
                @bom_list_data += '<th >MOKO DES</th>'
                @bom_list_data += '<th width="120">数量</th>'
                @bom_list_data += '<th width="50">操作</th>'
                @bom_list_data += '<tr>'
                @bom_list_data += '</thead>'
                @bom_list_data += '<tbody>'
                #bom_data.each do |wh_bom|
                @bom_list_data += '<tr id="wh_item_'+bom_data.id.to_s+'">'
                @bom_list_data += '<td>'+bom_data.erp_no_son.to_s+'</td>'
                @bom_list_data += '<td>'+bom_data.moko_part.to_s+'</td>'
                @bom_list_data += '<td>'+bom_data.moko_des.to_s+'</td>'
                @bom_list_data += '<td>'+bom_data.qty.to_s+'</td>'
                @bom_list_data += '<td><a class="btn btn-xs btn-danger " data-method="get"  href="/wh_out_bom_up?id=' + bom_data.id.to_s + '&wh_out_info_id=' + params[:wh_out_info_id].to_s + '" data-confirm="确定?">确定</a></td>' 
                @bom_list_data += '</tr>'
                #end
                @bom_list_data += '<tbody>'
                @bom_list_data += '<table>'
                @bom_list_data += '<small>'
            end
        end
    end

    def wh_out_bom_up
        if not params[:wh_out_info_id].blank?
            Rails.logger.info("add-------------------------------------1")
            out_wh_out_info_data = WhOutInfo.find_by_id(params[:wh_out_info_id])
            if not out_wh_out_info_data.blank?
                Rails.logger.info("add-------------------------------------2")
                if out_wh_out_info_data.state == "new"
                    out_old_bom = WhOutItem.where(wh_out_info_id: params[:wh_out_info_id])
                    if not out_old_bom.blank?
                        out_old_bom.each do |item|
                            item.destroy
                        end
                    end
                end
                out_bom_info = ProcurementBom.find_by_id(params[:id])
                out_new_bom = PItem.where(procurement_bom_id: params[:id])
                if not out_new_bom.blank?
                    Rails.logger.info("add-------------------------------------3")
                    out_new_bom.each do |item|
                        up_data = WhOutItem.new
                        up_data.wh_out_info_id = out_wh_out_info_data.id
                        up_data.wh_out_info_no = out_wh_out_info_data.wh_out_no
                        up_data.moko_part = item.moko_part
                        up_data.moko_des = item.moko_des
                        up_data.p_item_id = item.id
                        up_data.erp_no_son = out_bom_info.erp_no_son
                        up_data.qty = item.quantity.to_i*out_bom_info.qty.to_i
                        up_data.qty_out = item.quantity.to_i*out_bom_info.qty.to_i
                        up_data.save
                    end
                end   
            end
        else
            Rails.logger.info("add-------------------------------------wwwwwwwwwww")
            Rails.logger.info(params[:wh_out_info_id])
            Rails.logger.info("add-------------------------------------wwwwwwwwwww")
        end
        redirect_to :back
    end

    def factory_out

    end

    def wh_get_to_check

    end

    def edit_wh_item_qty
        if not params[:wh_item_out_id].blank?
            item_data = WhGetItem.find_by_id(params[:wh_item_out_id])
            if not item_data.blank?
                info_data = WhGetInfo.find_by_id(item_data.wh_get_info_id)
                if not info_data.blank?
                    if info_data.state == "new"
                        item_data.qty_out = params[:wh_item_qty_out]
                        item_data.save
                    end
                end
            end
        end

        redirect_to :back
    end

    def find_wh_get_bom
        if not params[:wh_get_info_id].blank?
            bom_data = ProcurementBom.find_by_erp_no_son(params[:bom_no])
            @bom_list_data = ""
            if not bom_data.blank?
                @bom_list_data += '<small>'
                @bom_list_data += '<table class="table table-bordered">'
                @bom_list_data += '<thead>'
                @bom_list_data += '<tr class="active">'
                @bom_list_data += '<th >PI NO.</th>'
                @bom_list_data += '<th width="120">数量</th>'
                @bom_list_data += '<th width="50">操作</th>'
                @bom_list_data += '<tr>'
                @bom_list_data += '</thead>'
                @bom_list_data += '<tbody>'
                #bom_data.each do |wh_bom|
                @bom_list_data += '<tr id="wh_item_'+bom_data.id.to_s+'">'
                @bom_list_data += '<td>'+bom_data.erp_no_son.to_s+'</td>'
                @bom_list_data += '<td>'+bom_data.erp_qty.to_s+'</td>'
                @bom_list_data += '<td><a class="btn btn-xs btn-danger " data-method="get"  href="/wh_get_bom_up?id=' + bom_data.id.to_s + '&wh_get_info_id=' + params[:wh_get_info_id].to_s + '" data-confirm="确定?">确定</a></td>' 
                @bom_list_data += '</tr>'
                #end
                @bom_list_data += '<tbody>'
                @bom_list_data += '<table>'
                @bom_list_data += '<small>'
            end
        end
    end

    def wh_get_bom_up
        if not params[:wh_get_info_id].blank?
            Rails.logger.info("add-------------------------------------1")
            get_wh_get_info_data = WhGetInfo.find_by_id(params[:wh_get_info_id])
            if not get_wh_get_info_data.blank?
                Rails.logger.info("add-------------------------------------2")
                if get_wh_get_info_data.state == "new"
                    get_old_bom = WhGetItem.where(wh_get_info_id: params[:wh_get_info_id])
                    if not get_old_bom.blank?
                        get_old_bom.each do |item|
                            item.destroy
                        end
                    end
                end
                get_bom_info = ProcurementBom.find_by_id(params[:id])
                get_new_bom = PItem.where(procurement_bom_id: params[:id])
                if not get_new_bom.blank?
                    Rails.logger.info("add-------------------------------------3")
                    get_new_bom.each do |item|
                        up_data = WhGetItem.new
                        up_data.wh_get_info_id = get_wh_get_info_data.id
                        up_data.wh_get_info_no = get_wh_get_info_data.wh_get_no
                        up_data.moko_part = item.moko_part
                        up_data.moko_des = item.moko_des
                        up_data.p_item_id = item.id
                        up_data.erp_no_son = get_bom_info.erp_no_son
                        up_data.qty = item.quantity.to_i*get_bom_info.qty.to_i
                        up_data.qty_out = item.quantity.to_i*get_bom_info.qty.to_i
                        up_data.save
                    end
                end   
            end
        else
            Rails.logger.info("add-------------------------------------wwwwwwwwwww")
            Rails.logger.info(params[:wh_get_info_id])
            Rails.logger.info("add-------------------------------------wwwwwwwwwww")
        end
        redirect_to :back
    end

    def edit_wh_get
        @wh_info = WhGetInfo.find_by(wh_get_no: params[:wh_get_no])
        @wh_item = WhGetItem.where(wh_get_info_no: params[:wh_get_no])
        #@all_dn = "[&quot;"
        #all_s_dn = AllDn.find_by_sql("SELECT DISTINCT all_dns.dn, all_dns.dn_long FROM all_dns GROUP BY all_dns.dn")
        #all_s_dn = SupplierList.find_by_sql("SELECT  supplier_name, supplier_name_long FROM supplier_lists ")
        #all_s_dn.each do |dn|
            #@all_dn += "&quot;,&quot;" + dn.supplier_name.to_s + "&#{dn.supplier_name_long.to_s}"
        #end
        #@all_dn += "&quot;]"
    end

    def new_wh_get
        if params[:wh_get_no] == "" or params[:wh_get_no] == nil
            if WhGetInfo.find_by_sql('SELECT wh_get_no FROM wh_get_infos WHERE to_days(wh_get_infos.created_at) = to_days(NOW())').blank?
                pi_n =1
            else
                pi_n = WhGetInfo.find_by_sql('SELECT wh_get_no FROM wh_get_infos WHERE to_days(wh_get_infos.created_at) = to_days(NOW())').last.wh_get_no.split("WHGET")[-1].to_i + 1
            end
            @wh_no = "MO"+current_user.s_name_self.to_s.upcase  + Time.new.strftime('%y').to_s + Time.new.strftime('%m%d').to_s + "WHGET"+ pi_n.to_s

            wh_info = WhGetInfo.new
            wh_info.wh_get_no = @wh_no
            wh_info.wh_get_user = current_user.email
            wh_info.state = "new"
            #wh_info.site = "c"            
            wh_info.save
            wh_get_no = wh_info.wh_get_no
        else
            wh_get_no = params[:wh_get_no]
        end
        #@pcblist = PcbOrder.where(state: "quotechk").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
        redirect_to edit_wh_get_path(wh_get_no: wh_get_no) and return 
    end

    def wh_get
        @whlist = WhGetInfo.all.order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
    end

    def edit_pmc_remark
        if can? :work_d, :all or can? :work_admin, :all 
            if not params[:item_id].blank?
                get_item_data = PiPmcItem.find_by_id(params[:item_id])
                if not get_item_data.blank?
                    get_item_data.remark = params[:remark]
                    get_item_data.save
                end
            end
        end
        redirect_to :back
    end

    def pmc_close
        get_pmc_data = PiPmcItem.find_by_id(params[:id])
        if not get_pmc_data.blank?
            if get_pmc_data.state == "new" or get_pmc_data.state == "new_new"
                get_wh_data = WarehouseInfo.find_by_moko_part(get_pmc_data.moko_part)
                if not get_wh_data.blank?
                    if get_pmc_data.buy_user == "MOKO_TEMP"
                        get_wh_data.future_qty = get_wh_data.future_qty + get_pmc_data.buy_qty
                        get_wh_data.save
                    elsif get_pmc_data.buy_user == "MOKO"
                        get_wh_data.future_qty = get_wh_data.qty + get_pmc_data.buy_qty
                        get_wh_data.save
                    end
                end
                get_pmc_data.state = "close"
                get_pmc_data.pass_at = Time.new
                get_pmc_data.save
            end
        end
        redirect_to :back
    end

    def manual_pmc_item
        if not params[:manual_pmc_pi_id].blank?
            pmc_data = PiPmcItem.find_by_id(params[:manual_pmc_pi_id])
            #moko_part_data = PItem.find_by_id(params[:manual_moko_part_id])
            pmc_data_new = PiPmcItem.new
            pmc_data_new.pi_info_id = pmc_data.pi_info_id
            pmc_data_new.state = "new"
            pmc_data_new.pass_at = Time.new
            pmc_data_new.erp_no = pmc_data.erp_no
            pmc_data_new.erp_no_son = pmc_data.erp_no_son
            pmc_data_new.moko_part = params[:manual_pmc_moko_part]
            pmc_data_new.moko_des = params[:manual_pmc_moko_des]
            pmc_data_new.part_code = params[:manual_pmc_part_code]
            pmc_data_new.qty = params[:manual_pmc_qty]
            pmc_data_new.buy_qty = params[:manual_pmc_buy_qty]
            pmc_data_new.pmc_qty = params[:manual_pmc_buy_qty]
            pmc_data_new.qty_in = params[:manual_pmc_buy_qty]
            pmc_data_new.buy_user = params[:manual_pmc_buy_user]
            pmc_data_new.remark = params[:manual_pmc_remark]
            pmc_data_new.save
        end
        redirect_to :back
    end

    def find_pmc_pi
        if not params[:key_order].blank?
            pmc_new = PiPmcItem.find_by_sql("SELECT * FROM pi_pmc_items  WHERE pi_pmc_items.erp_no_son LIKE '%#{params[:key_order]}%' GROUP BY pi_pmc_items.erp_no_son")

            pmc_new = PiPmcItem.find_by_sql("SELECT p_items.*, pi_pmc_items.erp_no_son,pi_pmc_items.id AS pmc_id FROM pi_pmc_items INNER JOIN procurement_boms ON pi_pmc_items.erp_no_son = procurement_boms.erp_no_son INNER JOIN p_items ON procurement_boms.id = p_items.procurement_bom_id WHERE pi_pmc_items.erp_no_son LIKE '%#{params[:key_order]}%' AND p_items.moko_part LIKE '%#{params[:key_moko_part]}%'")
            #@pmc_new = PiPmcItem.where(erp_no_son: params[:key_order])
            if not pmc_new.blank?
                @tr = ''
                pmc_new.each do |item|
                    @tr += '<tr>'
                    @tr += '<td>' + item.erp_no_son + '</td>'
                    @tr += '<td>' + item.moko_part + '</td>'
                    @tr += '<td>' + item.moko_des + '</td>'
                    @tr += '<td><a class="btn btn-success" data-method="get" data-remote="true" href="/set_pmc_pi?id=' + item.id.to_s + '&pmc_id=' + item.pmc_id.to_s + '">选择</a></td>'
                    @tr += '</tr>'
                end
                render "find_pmc_pi.js.erb" and return
            end
        end
    end

    def set_pmc_pi
        if not params[:pmc_id].blank?
            @pmc_data = PiPmcItem.find_by_id(params[:pmc_id])
            @moko_part_data = PItem.find_by_id(params[:id])
            if not @pmc_data.blank?
                render "set_pmc_pi.js.erb" and return
            end
        end
    end

    def pmc_new
        pmc_where = "state like '%new%'"
        if not params[:pass_date].blank?
            if not pmc_where.blank?
            pmc_where += " AND "
            end
            pmc_where += "pass_at LIKE '#{params[:pass_date].to_s.strip}%'"
        end
        if not params[:order_no].blank?
            if not pmc_where.blank?
            pmc_where += " AND "
            end
            pmc_where += "erp_no_son LIKE '%#{params[:order_no].to_s.strip}%'"
        end
        if not params[:moko_part].blank?
            if not pmc_where.blank?
            pmc_where += " AND "
            end
            pmc_where += "moko_part LIKE '%#{params[:moko_part].to_s.strip}%'"
        end
        if not params[:moko_des].blank?
            if not pmc_where.blank?
            pmc_where += " AND "
            end
            pmc_where += "moko_des LIKE '%#{params[:moko_des].to_s.strip}%'"
        end
        if not params[:part_code].blank?
            if not pmc_where.blank?
            pmc_where += " AND "
            end
            pmc_where += "part_code LIKE '%#{params[:part_code].to_s.strip}%'"
        end
        if not params[:buy_user].blank?
            if not pmc_where.blank?
            pmc_where += " AND "
            end
            pmc_where += "buy_user LIKE '%#{params[:buy_user].to_s.strip}%'"
        end
        sort_data = "moko_part"
        if not params[:sort_data].blank?
            sort_data = params[:sort_data]
        end
        if params[:chk].blank?
            pmc_where += " AND pmc_type = ''"
            @pmc_new = PiPmcItem.where(pmc_where).order("#{sort_data} DESC").paginate(:page => params[:page], :per_page => 30)
        else
            pmc_where += " AND pmc_type = 'CHK'"
            @pmc_new = PiPmcItem.where(pmc_where).order("#{sort_data} DESC").paginate(:page => params[:page], :per_page => 30)
            render "pmc_new_chk.html.erb" and return
        end
    end

    def pmc_manual_list
        @pmc_manual_list = PiPmcAddInfo.where(state: "new").paginate(:page => params[:page], :per_page => 20)
    end

    def new_pmc_manual_order
        if params[:pi_pmc_add_info_no] == "" or params[:pi_pmc_add_info_no] == nil
            if PiPmcAddInfo.find_by_sql('SELECT no FROM pi_pmc_add_infos WHERE to_days(pi_pmc_add_infos.created_at) = to_days(NOW())').blank?
                pi_n =1
            else
                pi_n = PiPmcAddInfo.find_by_sql('SELECT no FROM pi_pmc_add_infos WHERE to_days(pi_pmc_add_infos.created_at) = to_days(NOW())').last.no.split("PMC")[-1].to_i + 1
            end
            @pi_pmc_add_info_no = "MO"+ Time.new.strftime('%y').to_s + Time.new.strftime('%m%d').to_s + "PMC"+ pi_n.to_s
            pi_pmc_add_info = PiPmcAddInfo.new()
            pi_pmc_add_info.no = @pi_pmc_add_info_no
            pi_pmc_add_info.user = current_user.email
            pi_pmc_add_info.state = "new"
            pi_pmc_add_info.save
            pi_pmc_add_info_id = pi_pmc_add_info.id
        else
            pi_pmc_add_info_id = params[:pi_pmc_add_info_id]
        end
        redirect_to edit_pmc_manual_order_path(pi_pmc_add_info_id: pi_pmc_add_info_id) and return 
    end

    def edit_pmc_manual_order
        @get_info = PiPmcAddInfo.find_by_id(params[:pi_pmc_add_info_id])
        @get_item = PiPmcAddItem.where(pi_pmc_add_info_id: params[:pi_pmc_add_info_id])
    end

    def ping_zheng_del
        if can? :work_finance, :all
            if not params[:id].blank?
                get_data = ZongZhangInfo.find_by_id(params[:id])
                if not get_data.blank?
                    get_data.destroy
                end
            end
        end
        redirect_to :back
    end

    def edit_ping_zheng
        if not params[:ping_zheng_id].blank?
            get_data = ZongZhangInfo.find_by_id(params[:ping_zheng_id])
            if not get_data.blank?
                get_data.des = params[:des]
                get_data.jie_fang_kemu = params[:jie_fang_kemu]
                get_data.dai_fang_kemu = params[:dai_fang_kemu]
                get_data.jie_fang = params[:jie_fang]
                get_data.dai_fang = params[:dai_fang]
                get_data.remark = params[:remark]
                get_data.finance_at = params[:finance_at]
                get_data.save
            end
        end
        redirect_to :back
    end

    def new_ping_zheng
        if can? :work_finance, :all
            get_data = ZongZhangInfo.new

            get_data.des = params[:new_des]
            get_data.jie_fang_kemu = params[:new_jie_fang_kemu]
            get_data.dai_fang_kemu = params[:new_dai_fang_kemu]
            get_data.jie_fang = params[:new_jie_fang]
            get_data.dai_fang = params[:new_dai_fang]
            get_data.remark = params[:new_remark]
            get_data.finance_at = params[:new_finance_at]
            get_data.save

        end
        redirect_to :back
    end

    def zong_zhang_list
        if not params[:pass_date].blank?
            @pingzheng = ZongZhangInfo.find_by_sql("SELECT * FROM zong_zhang_infos WHERE date_format(zong_zhang_infos.finance_at,'%Y-%m')='#{params[:pass_date]}' ").paginate(:page => params[:page], :per_page => 20)
        else
            @pingzheng = ZongZhangInfo.all.paginate(:page => params[:page], :per_page => 20)
        end
    end

    def shou_kuan_ping_zheng
        if not params[:pass_date].blank?
            @pingzheng = ZongZhangInfo.find_by_sql("SELECT * FROM zong_zhang_infos WHERE date_format(zong_zhang_infos.finance_at,'%Y-%m')='#{params[:pass_date]}' AND zong_zhang_infos.zong_zhang_type = 'shou'").paginate(:page => params[:page], :per_page => 20)
        else
            @pingzheng = ZongZhangInfo.where(zong_zhang_type: "shou").paginate(:page => params[:page], :per_page => 20)
        end
    end

    def fu_kuan_ping_zheng
        if not params[:pass_date].blank?
            @pingzheng = ZongZhangInfo.find_by_sql("SELECT * FROM zong_zhang_infos WHERE date_format(zong_zhang_infos.finance_at,'%Y-%m')='#{params[:pass_date]}' AND zong_zhang_infos.zong_zhang_type = 'fu'").paginate(:page => params[:page], :per_page => 20)
        else
            @pingzheng = ZongZhangInfo.where(zong_zhang_type: "fu").paginate(:page => params[:page], :per_page => 20)
        end
    end

    def pmc_back_to_pi

    end

    def send_pmc_back
        get_pmc_data = PiPmcItem.find_by_id(params[:id])
        if not get_pmc_data.blank?
            if get_pmc_data.state == "pass"
                get_wh_data = WarehouseInfo.find_by_moko_part(get_pmc_data.moko_part)
                if not get_wh_data.blank?
                    if get_pmc_data.buy_user == "MOKO_TEMP"
                        get_wh_data.future_qty = get_wh_data.future_qty + get_pmc_data.buy_qty
                        get_wh_data.save
                    elsif get_pmc_data.buy_user == "MOKO"
                        get_wh_data.future_qty = get_wh_data.qty + get_pmc_data.buy_qty
                        get_wh_data.save
                    end
                end
                get_pmc_data.state = "new_new"
                get_pmc_data.save
            end
        end
        redirect_to :back
    end

    def pi_to_pmc
        Rails.logger.info("pmc_new--------------------------------------1")
        #@pi_buy = PiInfo.find_by_sql("SELECT p_items.*,pi_items.order_item_id FROM pi_infos INNER JOIN pi_items ON pi_infos.pi_no = pi_items.pi_no INNER JOIN p_items ON pi_items.bom_id = p_items.procurement_bom_id WHERE pi_infos.state = 'checked' AND p_items.buy = '' ORDER BY p_items.product_id DESC")
        @pi_buy = PiBomQtyInfoItem.find_by_sql("SELECT pi_bom_qty_info_items.pi_item_id,pi_bom_qty_info_items.pi_info_id,pi_bom_qty_info_items.bom_ctl_qty AS pmc_qty,pi_bom_qty_info_items.customer_qty,pi_bom_qty_info_items.p_item_id,pi_bom_qty_info_items.order_item_id,pi_bom_qty_info_items.id AS qty_item_id FROM pi_bom_qty_info_items INNER JOIN p_items ON pi_bom_qty_info_items.p_item_id = p_items.id WHERE pi_bom_qty_info_items.pi_item_id = '#{params[:p_pi_item_id]}' AND pi_bom_qty_info_items.buy = '' ")
        if not @pi_buy.blank?
            Rails.logger.info("pmc_new--------------------------------------2")
            @pi_buy.each do |item_buy|
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


        get_pi_item_data = PiItem.find_by_id(params[:p_pi_item_id])
        if not get_pi_item_data.blank?
            get_pi_item_data.to_pmc_state = "send"
            get_pi_item_data.sell_at = Time.new()
            get_pi_item_data.save
        end

        redirect_to :back
    end

    def pmc_to_sell
        if params[:key_order]
            #@pilist = PiInfo.where("(c_code LIKE '%#{params[:key_order]}%' OR c_des LIKE '%#{params[:key_order]}%' OR p_name LIKE '%#{params[:key_order]}%' OR des_cn LIKE '%#{params[:key_order]}%' OR des_en LIKE '%#{params[:key_order]}%' OR pi_no LIKE '%#{params[:key_order]}%' OR remark LIKE '%#{params[:key_order]}%' OR follow_remark LIKE '%#{params[:key_order]}%') AND state <> 'new' AND pi_sell = '#{current_user.email}'").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
            
            @pilist = PiBomQtyInfoItem.find_by_sql("SELECT pi_bom_qty_info_items.*, pi_items.*, p_items.* FROM pi_items INNER JOIN pi_bom_qty_info_items ON pi_items.id = pi_bom_qty_info_items.pi_item_id INNER JOIN p_items ON pi_bom_qty_info_items.p_item_id = p_items.id WHERE pi_bom_qty_info_items.pmc_back_state = '' AND (pi_items.pi_no LIKE '%#{params[:key_order]}%' OR p_items.moko_part LIKE '%#{params[:key_order]}%' OR p_items.moko_des LIKE '%#{params[:key_order]}%')").paginate(:page => params[:page], :per_page => 20)
            #@pilist = PiItem.find_by_sql("SELECT pi_infos.follow_remark,pi_infos.pi_sell,pi_infos.pcb_customer_id,pi_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.id = pi_items.pi_info_id ORDER BY updated_at DESC").paginate(:page => params[:page], :per_page => 20)
        end        
    end


    def edit_fu_kuan_remark
        if not params[:zhi_fu_id].blank?
            get_fukuan = FuKuanShenQingDanInfo.find_by_id(params[:zhi_fu_id])
            get_fukuan.remark = params[:remark_edit]
            get_fukuan.save
        end
        redirect_to :back and return
    end

    def edit_fu_kuan_info_a
        if not params[:id].blank?
            get_fukuan = FuKuanShenQingDanInfo.find_by_id(params[:id])
            get_fukuan.info_a = params[:info_a]
            get_fukuan.save
        end
        redirect_to :back and return
    end

    def edit_fu_kuan_info_b
        if not params[:id].blank?
            get_fukuan = FuKuanShenQingDanInfo.find_by_id(params[:id])
            get_fukuan.info_b = params[:info_b]
            get_fukuan.save
        end
        redirect_to :back and return
    end

    def edit_j_h_r_q
        if not params[:jhrq_at].blank?
            get_info_data = PiBuyInfo.find_by_id(params[:id])
            get_info_data.delivery_date = params[:jhrq_at]
            if get_info_data.save
                get_item_data = PiBuyItem.where(pi_buy_info_id: get_info_data.id).update_all "delivery_date = '#{params[:jhrq_at]}'"
            end
        end
        redirect_to :back
    end

    def edit_ecn_up
        if not params[:bom_ecn_info_id].blank?
            get_ecn_info = BomEcnInfo.find_by_id(params[:bom_ecn_info_id])
            if params[:commit] == "保存草稿"
                get_ecn_info.state = "new"
            elsif params[:commit] == "发送给BOM工程师"
                get_ecn_info.state = "checking"
                get_ecn_info.send_at = Time.new()
            elsif params[:commit] == "审批通过"
                get_ecn_info.state = "checked"
            end
            get_ecn_info.remark = params[:ecn_remark]
            if not params[:sheng_xiao_type].blank?
                get_ecn_info.sheng_xiao_type = params[:sheng_xiao_type].join("")
            end
            if not params[:change_type].blank?
                get_ecn_info.change_type = params[:change_type].join("")
            end
            get_ecn_info.save
        end
        redirect_to :back
    end

    def up_ecn_item
        if not params[:up_item_id].blank?
            get_data = BomEcnItem.find_by_id(params[:up_item_id])
            if not get_data.blank?
                get_data.eng_moko_part = params[:up_eng_moko_part]
                get_data.eng_moko_des = params[:up_eng_moko_des]
                get_data.eng_part_code = params[:up_eng_part_code]
                get_data.eng_quantity = params[:up_eng_quantity]
                get_data.eng_remark = params[:up_eng_remark]
                get_data.opt_type = params[:opt_type].join("")
                get_data.state = "opt"
                get_data.save
            end
        end
        redirect_to :back
    end

    def add_ecn_item
        if not params[:ecn_info_id].blank? 
            if not params[:bom_item_id].blank?
                check_item = BomEcnItem.find_by(bom_ecn_info_id: params[:ecn_info_id],bom_item_id: params[:bom_item_id])

                if check_item.blank?
                    ecn_item_new = BomEcnItem.new
                    ecn_item_new.bom_ecn_info_id = params[:ecn_info_id]
                    ecn_item_new.bom_item_id = params[:bom_item_id]
                    ecn_item_new.moko_bom_item_id = params[:moko_bom_item_id]
                    ecn_item_new.old_moko_part = params[:old_moko_part]
                    ecn_item_new.old_moko_des = params[:old_moko_des]
                    ecn_item_new.old_part_code = params[:old_part_code]
                    ecn_item_new.old_quantity = params[:old_quantity]
                    ecn_item_new.new_moko_part = params[:new_moko_part]
                    ecn_item_new.new_sell_des = params[:new_sell_des]
                    ecn_item_new.new_moko_des = params[:new_moko_des]
                    ecn_item_new.new_part_code = params[:new_part_code]
                    ecn_item_new.new_quantity = params[:new_quantity]
                    ecn_item_new.change_type = params[:change_type].join("")
                    ecn_item_new.remark = params[:ecn_remark]
                    if ecn_item_new.save
                        p_item_data = PItem.find_by_id(params[:bom_item_id])
                        p_item_data.ecn_tag = "new"
                        p_item_data.save
                    end
                else
                    check_item.old_moko_part = params[:old_moko_part]
                    check_item.old_moko_des = params[:old_moko_des]
                    check_item.old_part_code = params[:old_part_code]
                    check_item.old_quantity = params[:old_quantity]
                    check_item.new_moko_part = params[:new_moko_part]
                    check_item.new_sell_des = params[:new_sell_des]
                    check_item.new_moko_des = params[:new_moko_des]
                    check_item.new_part_code = params[:new_part_code]
                    check_item.new_quantity = params[:new_quantity]
                    check_item.change_type = params[:change_type].join("")
                    check_item.remark = params[:ecn_remark]
                    check_item.save
                end
            else
                ecn_item_new = BomEcnItem.new
                ecn_item_new.bom_ecn_info_id = params[:ecn_info_id]
                ecn_item_new.bom_item_id = params[:bom_item_id]
                ecn_item_new.moko_bom_item_id = params[:moko_bom_item_id]
                ecn_item_new.old_moko_part = params[:old_moko_part]
                ecn_item_new.old_moko_des = params[:old_moko_des]
                ecn_item_new.old_part_code = params[:old_part_code]
                ecn_item_new.old_quantity = params[:old_quantity]
                ecn_item_new.new_moko_part = params[:new_moko_part]
                ecn_item_new.new_sell_des = params[:new_sell_des]
                ecn_item_new.new_moko_des = params[:new_moko_des]
                ecn_item_new.new_part_code = params[:new_part_code]
                ecn_item_new.new_quantity = params[:new_quantity]
                ecn_item_new.change_type = params[:change_type].join("")
                ecn_item_new.remark = params[:ecn_remark]
                if ecn_item_new.save
                    p_item_data = PItem.find_by_id(params[:bom_item_id])
                    if not p_item_data.blank?
                        p_item_data.ecn_tag = "new"
                        p_item_data.save
                    end
                end
            end
        end
        redirect_to :back
    end

    def add_ecn
        if not params[:pi_item_id].blank?
            pi_item = PiItem.find_by_id(params[:pi_item_id])
            @state = pi_item.state
            @to_pmc_state = pi_item.to_pmc_state
            @boms = ProcurementBom.find_by_id(pi_item.bom_id)
            @pi_bom_qty_info = PiBomQtyInfo.find_by_pi_item_id(params[:pi_item_id])

=begin
            @bom_item = PItem.find_by_sql("SELECT p_items.*, pi_bom_qty_info_items.id AS pi_item_qty, pi_bom_qty_info_items.bom_ctl_qty, pi_bom_qty_info_items.customer_qty, pi_bom_qty_info_items.lock_state FROM p_items INNER JOIN pi_bom_qty_info_items ON p_items.id = pi_bom_qty_info_items.p_item_id WHERE p_items.procurement_bom_id = '#{@boms.id}' AND pi_bom_qty_info_items.pi_item_id = '#{params[:pi_item_id]}'")

            if not @bom_item.blank?
                @bom_item = @bom_item.select {|item| item.quantity != 0 }
            end


            if not params[:pi_info_id].blank? 
                @shou_kuan_tong_zhi_dan_list = PaymentNoticeInfo.where(pi_info_id: params[:pi_info_id])
            end
            @baojia = @bom_item
=end
            new_bom_ecn = BomEcnInfo.new
            new_bom_ecn.bom_id =@boms.id
            new_bom_ecn.pi_id = pi_item.pi_info_id
            new_bom_ecn.pi_item_id = pi_item.id
            new_bom_ecn.pi_no = pi_item.pi_no
            new_bom_ecn.bom_no = @boms.no
            #new_bom_ecn.chan_pin_xing_hao = ""
            new_bom_ecn.fa_qi_ren_id = current_user.id
            new_bom_ecn.fa_qi_ren_name = current_user.full_name
            #new_bom_ecn.shen_he_ren_id = ""
            #new_bom_ecn.shen_he_ren_name =""
            #new_bom_ecn.pi_zhun_ren_id =""
            #new_bom_ecn.pi_zhun_ren_name =""
            #new_bom_ecn.zhi_xing_date_at =""
            #new_bom_ecn.bom_update_date_at =""
            #new_bom_ecn.change_type =""
            #new_bom_ecn.sheng_xiao_type =""
            #new_bom_ecn.remark =""
            new_bom_ecn.save
            redirect_to edit_ecn_path(bom_ecn_info_id: new_bom_ecn.id) and return
        end
        
    end

    def cut_in_ecn
        if can? :work_d, :all or can? :work_admin, :all 
            if not bom_ecn_info_id.blank?
                get_ecn_info = BomEcnInfo.find_by_id(params[:bom_ecn_info_id])
                get_ecn_item = BomEcnItem.where(bom_ecn_info_id: params[:bom_ecn_info_id])
                if not get_ecn_item.blank?
                    get_ecn_item.each do |item|
                        if item.opt_type == "del"
                            if item.change_type == "ever"
                                get_moko_item = MokoBomItem.find_by_id(item.moko_bom_item_id)
                                get_moko_item.destroy
                            end
                            if can? :work_d, :all or can? :work_admin, :all 
                                if not item.bom_item_id.blank?
                                    get_data = PItem.find_by_id(item.bom_item_id)
                                    if not get_data.blank?
                                        if not get_data.cost.blank? and not get_data.pmc_qty.blank?
                                            del_t_p = get_data.pmc_qty*get_data.cost
                                            get_bom = ProcurementBom.find_by_id(get_data.procurement_bom_id)  
                                            if not get_bom.blank?
                                                get_bom.t_p = get_bom.t_p - del_t_p
                                                get_bom.save
                                            end
                                        end
                                        get_data.destroy
                                    end
                                end
                            end

                        elsif item.opt_type == "add"

                            get_bom = ProcurementBom.find_by_id(get_ecn_info.bom_id)
                            if item.change_type == "ever"
                                get_moko_bom_info = MokoBomInfo.find_by_id(get_bom.moko_bom_info_id)
                                new_moko_item = MokoBomItem.new
                                new_moko_item.bom_version = get_moko_bom_info.bom_version
                                new_moko_item.moko_bom_info_id = get_moko_bom_info.id
                                new_moko_item.quantity = item.eng_quantity
                                new_moko_item.part_code = item.eng_part_code
                                new_moko_item.description = item.new_sell_des
                                new_moko_item.moko_part = item.eng_moko_part
                                new_moko_item.moko_des = item.eng_moko_des
                                new_moko_item.user_id = current_user.id
                                new_moko_item.save
                            end
                            if not get_bom.blank?
                                bom_item = PItem.new
                            
                                bom_item.bom_version = get_bom.bom_version
                                bom_item.pmc_qty = item.eng_quantity.to_i*get_bom.qty.to_i
                                bom_item.procurement_bom_id = get_ecn_info.bom_id
                                bom_item.quantity = item.eng_quantity
                                bom_item.part_code = item.eng_part_code
                                bom_item.description = item.new_sell_des
                                bom_item.moko_part = item.eng_moko_part
                                bom_item.moko_des = item.eng_moko_des
                                bom_item.user_id = current_user.id
                                if item.change_type == "ever"
                                    bom_item.moko_bom_item_id = new_moko_item.id
                                end
                                bom_item.save
                            end
                        elsif item.opt_type == "edit"
                            if item.change_type == "ever"
                                get_moko_item = MokoBomItem.find_by_id(item.moko_bom_item_id)
                                get_moko_item.quantity = item.eng_quantity
                                get_moko_item.part_code = item.eng_part_code
                                get_moko_item.description = item.new_sell_des
                                get_moko_item.moko_part = item.eng_moko_part
                                get_moko_item.moko_des = item.eng_moko_des
                                get_moko_item.user_id = current_user.id
                                get_moko_item.save
                            end 
                            if not item.bom_item_id.blank?
                                get_data = PItem.find_by_id(item.bom_item_id)
                                get_data.bom_version = get_bom.bom_version
                                get_data.pmc_qty = item.eng_quantity.to_i*get_bom.qty.to_i
                                get_data.procurement_bom_id = get_ecn_info.bom_id
                                get_data.quantity = item.eng_quantity
                                get_data.part_code = item.eng_part_code
                                get_data.description = item.new_sell_des
                                get_data.moko_part = item.eng_moko_part
                                get_data.moko_des = item.eng_moko_des
                                get_data.user_id = current_user.id
                                get_data.save
                            end
                        end
                        item.state = "done"
                        item.save
                    end
                end
                get_ecn_info.state = "checked"
                get_ecn_info.save
            end
        end
        redirect_to :back
    end

    def edit_ecn
        @get_ecn_info = BomEcnInfo.find_by_id(params[:bom_ecn_info_id])
        @get_ecn_item = BomEcnItem.where(bom_ecn_info_id: params[:bom_ecn_info_id])
        if not @get_ecn_info.blank?
            pi_item = PiItem.find_by_id(@get_ecn_info.pi_item_id)
            @state = pi_item.state
            @to_pmc_state = pi_item.to_pmc_state
            @boms = ProcurementBom.find_by_id(pi_item.bom_id)
            #@bom_item = PItem.where(procurement_bom_id: @boms.id)
            @bom_item = PItem.find_by_sql("SELECT p_items.*, pi_bom_qty_info_items.id AS pi_item_qty, pi_bom_qty_info_items.bom_ctl_qty, pi_bom_qty_info_items.customer_qty, pi_bom_qty_info_items.lock_state FROM p_items INNER JOIN pi_bom_qty_info_items ON p_items.id = pi_bom_qty_info_items.p_item_id WHERE p_items.procurement_bom_id = '#{@boms.id}' AND pi_bom_qty_info_items.pi_item_id = '#{@get_ecn_info.pi_item_id}'")
            @pi_bom_qty_info = PiBomQtyInfo.find_by_pi_item_id(@get_ecn_info.pi_item_id)
            if not @bom_item.blank?
                @bom_item = @bom_item.select {|item| item.quantity != 0 }
            end
            Rails.logger.info("add-------------------------------------12")
            Rails.logger.info(@boms.inspect)
            Rails.logger.info("add-------------------------------------12")

            if not params[:pi_info_id].blank? 
                @shou_kuan_tong_zhi_dan_list = PaymentNoticeInfo.where(pi_info_id: params[:pi_info_id])
            end
            @baojia = @bom_item
=begin
            if @get_ecn_info.state == "new"
                render "edit_ecn.html.erb" and return
            else
                render "edit_ecn_show.html.erb" and return
            end
=end
        end
    end

    def new_ecn_find_pi
        if params[:key_order]

            if can? :work_admin, :all
                @pilist = PiItem.find_by_sql("SELECT pi_infos.follow_remark,pi_infos.pi_sell,pi_infos.pcb_customer_id,pi_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.id = pi_items.pi_info_id WHERE (pi_infos.c_code LIKE '%#{params[:key_order]}%' OR pi_infos.c_des LIKE '%#{params[:key_order]}%' OR pi_infos.p_name LIKE '%#{params[:key_order]}%' OR pi_infos.des_cn LIKE '%#{params[:key_order]}%' OR pi_infos.des_en LIKE '%#{params[:key_order]}%' OR pi_infos.pi_no LIKE '%#{params[:key_order]}%' OR pi_infos.remark LIKE '%#{params[:key_order]}%' OR pi_infos.follow_remark LIKE '%#{params[:key_order]}%') ORDER BY updated_at DESC").paginate(:page => params[:page], :per_page => 20)
            elsif can? :work_e, :all
                @pilist = PiItem.find_by_sql("SELECT pi_infos.follow_remark,pi_infos.pi_sell,pi_infos.pcb_customer_id,pi_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.id = pi_items.pi_info_id WHERE pi_infos.pi_sell = '#{current_user.email}' ORDER BY updated_at DESC").paginate(:page => params[:page], :per_page => 20)
            else
                @pilist = PiItem.find_by_sql("SELECT pi_infos.follow_remark,pi_infos.pi_sell,pi_infos.pcb_customer_id,pi_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.id = pi_items.pi_info_id ORDER BY updated_at DESC").paginate(:page => params[:page], :per_page => 20)
            end
        end 
        @all_item = ''
        if not @pilist.blank?
            @pilist.each do |pcb|
                @all_item += '<tr >'
                if not pcb.pcb_customer_id.blank?
                    @all_item += '<td><a href="/edit_pcb_pi?c_id='+pcb.pcb_customer_id.to_s+'&amp;pi_info_id='+pcb.pi_info_id.to_s+'&amp;pi_item_id='+pcb.id.to_s+'&amp;pi_no='+pcb.pi_no.to_s+'">'+pcb.pi_no.to_s+'</a></td>'
                else
                    @all_item += '<td><a href="/edit_pcb_pi?pi_info_id='+pcb.pi_info_id.to_s+'&amp;pi_item_id='+pcb.id.to_s+'&amp;pi_no='+pcb.pi_no.to_s+'">'+pcb.pi_no.to_s+'</a></td>'
                end
        
                @all_item += '<td>'+pcb.created_at.localtime.strftime('%Y-%m-%d %H:%M:%S').to_s+'</td>'
                @all_item += '<td>'+pcb.to_pmc_state+'</td>'
                @all_item += '<td>'
                if pcb.bom_state == "check"
                    @all_item += '审核中'
                elsif pcb.bom_state == "checked"
                    @all_item += '审核完成'
                else
                    @all_item += pcb.bom_state.to_s
                end
                    @all_item += '</td>'
                @all_item += '<td>'
                if pcb.buy_state == "check"
                    @all_item += '审核中'
                elsif pcb.buy_state == "checked"
                    @all_item += '审核完成'
                else
                    @all_item += pcb.buy_state.to_s
                end
                @all_item += '</td>'
                @all_item += '<td>'
                if pcb.finance_state == "check"
                    @all_item += '审核中'
                elsif pcb.finance_state == "checked"
                    @all_item += '审核完成'
                else
                    @all_item += pcb.finance_state.to_s
                end
                @all_item += '</td>'
                @all_item += '<td>'+pcb.qty.to_s+'</td>'
                @all_item += '<td>'+pcb.price.to_s+'</td>'
                @all_item += '<td></td>'
                @all_item += '<td>'+User.find_by(email: pcb.pi_sell).full_name.to_s+'</td>'
                @all_item += '<td>'+pcb.remark.to_s+'</td>'
                @all_item += '<td>'+pcb.follow_remark.to_s+'</td>'
                @all_item += '</tr>'
            end
        end         
    end

    def new_ecn
        @ecn_draft_list = BomEcnInfo.where(state: "new",fa_qi_ren_id: current_user.id ).paginate(:page => params[:page], :per_page => 20)
        if can? :work_admin, :all
            @pilist = PiItem.find_by_sql("SELECT pi_infos.follow_remark,pi_infos.pi_sell,pi_infos.pcb_customer_id,pi_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.id = pi_items.pi_info_id ORDER BY updated_at DESC").paginate(:page => params[:page], :per_page => 20)
        elsif can? :work_e, :all
            @pilist = PiItem.find_by_sql("SELECT pi_infos.follow_remark,pi_infos.pi_sell,pi_infos.pcb_customer_id,pi_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.id = pi_items.pi_info_id WHERE pi_infos.pi_sell = '#{current_user.email}' ORDER BY updated_at DESC").paginate(:page => params[:page], :per_page => 20)
        else
            @pilist = PiItem.find_by_sql("SELECT pi_infos.follow_remark,pi_infos.pi_sell,pi_infos.pcb_customer_id,pi_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.id = pi_items.pi_info_id ORDER BY updated_at DESC").paginate(:page => params[:page], :per_page => 20)
        end
       
    end

    def ecn_list
        if can? :work_admin, :all or can? :work_d, :all
            @ecn_draft_list = BomEcnInfo.where("state <> 'new'" ).paginate(:page => params[:page], :per_page => 20)
        else
            @ecn_draft_list = BomEcnInfo.where("state <> 'new' AND fa_qi_ren_id = #{current_user.id}" ).paginate(:page => params[:page], :per_page => 20)
        end
        
    end

    def sell_back_item
        if not params[:pi_bom_qty_info_item_id].blank?
            get_data = PiBomQtyInfoItem.find_by_id(params[:pi_bom_qty_info_item_id])
            if not get_data.blank?
                get_pi_data = PiItem.find_by_id(get_data.pi_item_id)
                if get_pi_data.to_pmc_state == "send"
                    get_data.lock_state = "lock"
                    get_data.save
                end
            end
        end
        redirect_to :back
    end



    def edit_pi_info_t_p
        get_pi_data = PiInfo.find_by_id(params[:p_pi_id])
        get_pi_data.t_p = params[:p_pi_t_p]
        get_pi_data.save
        redirect_to :back
    end

    def edit_pi_bank_info
        get_pi_data = PiInfo.find_by_id(params[:pi_id])
        get_bank_info = BankInfo.find_by_id(params[:bank_info])

        get_pi_data.bank_info_id = params[:bank_info]
        get_pi_data.save
        redirect_to :back
    end

    def add_ling_liao_dan_item
        if not params[:ling_liao_dan_id].blank?
            get_ling_liao_info = LingLiaoDanInfo.find_by_id(params[:ling_liao_dan_id])
            if not params[:roles].blank?
                params[:roles].each do |id|
                    get_pmc_data = PiPmcItem.find_by_id(id)
                    new_ling_liao_item = LingLiaoDanItem.new
                    new_ling_liao_item.ling_liao_dan_info_id = get_ling_liao_info.id
                    new_ling_liao_item.pi_bom_qty_info_item_id = get_pmc_data.pi_bom_qty_info_item_id
                    new_ling_liao_item.pi_info_id = get_pmc_data.pi_info_id
                    new_ling_liao_item.pi_item_id = get_pmc_data.pi_item_id
                    new_ling_liao_item.pmc_flag = get_pmc_data.pmc_flag
                    new_ling_liao_item.state = get_pmc_data.state
                    new_ling_liao_item.pmc_type = get_pmc_data.pmc_type
                    new_ling_liao_item.buy_type = get_pmc_data.buy_type
                    new_ling_liao_item.erp_no = get_pmc_data.erp_no
                    new_ling_liao_item.erp_no_son = get_pmc_data.erp_no_son
                    new_ling_liao_item.moko_part = get_pmc_data.moko_part
                    new_ling_liao_item.moko_des = get_pmc_data.moko_des
                    new_ling_liao_item.part_code = get_pmc_data.part_code
                    new_ling_liao_item.qty = get_pmc_data.qty
                    new_ling_liao_item.f_qty = get_pmc_data.qty
                    new_ling_liao_item.pmc_qty = get_pmc_data.pmc_qty
                    new_ling_liao_item.qty_in = get_pmc_data.qty_in
                    new_ling_liao_item.remark = get_pmc_data.remark
                    new_ling_liao_item.buy_user = get_pmc_data.buy_user
                    new_ling_liao_item.buy_qty = get_pmc_data.buy_qty
                    new_ling_liao_item.p_item_id = get_pmc_data.p_item_id
                    new_ling_liao_item.erp_id = get_pmc_data.erp_id
                    new_ling_liao_item.user_do = get_pmc_data.user_do
                    new_ling_liao_item.user_do_change = get_pmc_data.user_do_change
                    new_ling_liao_item.check = get_pmc_data.check
                    new_ling_liao_item.pi_buy_info_id = get_pmc_data.pi_buy_info_id
                    new_ling_liao_item.procurement_bom_id = get_pmc_data.procurement_bom_id
                    new_ling_liao_item.quantity = get_pmc_data.quantity
                    new_ling_liao_item.qty_done = get_pmc_data.qty_done
                    new_ling_liao_item.qty_wait = get_pmc_data.qty_wait
                    new_ling_liao_item.wh_qty = get_pmc_data.wh_qty
                    new_ling_liao_item.description = get_pmc_data.description
                    new_ling_liao_item.fengzhuang = get_pmc_data.fengzhuang
                    new_ling_liao_item.link = get_pmc_data.link
                    new_ling_liao_item.cost = get_pmc_data.cost
                    new_ling_liao_item.info = get_pmc_data.info
                    new_ling_liao_item.product_id = get_pmc_data.product_id
                    new_ling_liao_item.warn = get_pmc_data.warn
                    new_ling_liao_item.user_id = get_pmc_data.user_id
                    new_ling_liao_item.danger = get_pmc_data.danger
                    new_ling_liao_item.manual = get_pmc_data.manual
                    new_ling_liao_item.mark = get_pmc_data.mark
                    new_ling_liao_item.mpn = get_pmc_data.mpn
                    new_ling_liao_item.mpn_id = get_pmc_data.mpn_id
                    new_ling_liao_item.price = get_pmc_data.price
                    new_ling_liao_item.mf = get_pmc_data.mf
                    new_ling_liao_item.dn_id = get_pmc_data.dn_id
                    new_ling_liao_item.dn = get_pmc_data.dn
                    new_ling_liao_item.dn_long = get_pmc_data.dn_long
                    new_ling_liao_item.other = get_pmc_data.other
                    new_ling_liao_item.all_info = get_pmc_data.all_info
                    new_ling_liao_item.color = get_pmc_data.color
                    new_ling_liao_item.supplier_tag = get_pmc_data.supplier_tag
                    new_ling_liao_item.supplier_out_tag = get_pmc_data.supplier_out_tag
                    new_ling_liao_item.sell_feed_back_tag = get_pmc_data.sell_feed_back_tag
                    new_ling_liao_item.pass_at = get_pmc_data.pass_at
                    new_ling_liao_item.save
                end
            end
        end
        redirect_to :back
    end


    def edit_ling_liao_item_qty
        if not params[:ling_liao_item_id].blank?
            get_item_data = LingLiaoDanItem.find_by_id(params[:ling_liao_item_id]) 
            if not get_item_data.blank?
                get_item_data.f_qty = params[:ling_liao_qty].to_i
                get_item_data.save
            end
        end
        redirect_to :back
    end

    def factory_in
        if not params[:order_no].blank?
            @buy_done = PcbOrderItem.where(buy_type: "done",pcb_order_no_son: params[:order_no].strip)
        else
            @buy_done = PcbOrderItem.where(buy_type: "done")
        end
    end

    def factory_in_manual
        if not params[:order_no].blank?
            @buy_done = PcbOrderItem.where(buy_type: "done",pcb_order_no_son: params[:order_no].strip)
        else
            @buy_done = PcbOrderItem.where(buy_type: "done")
        end
    end

    def factory_online_manual
        if can? :work_c, :all or can? :work_admin, :all
            set_order_state = PcbOrderItem.find_by_pcb_order_no_son(params[:order])
            #if set_order_state.factory_state == ""
            if set_order_state.pcb_order_no_son != ""
                new_ling_liao = LingLiaoDanInfo.new
                new_ling_liao.ling_liao_user = current_user.email
                new_ling_liao.ling_liao_user_name = current_user.full_name
                new_ling_liao.pi_lock = set_order_state.pi_lock
                new_ling_liao.buy_type = set_order_state.buy_type
                new_ling_liao.item_pcba_id = set_order_state.item_pcba_id
                new_ling_liao.item_pcb_id = set_order_state.item_pcb_id
                new_ling_liao.c_id = set_order_state.c_id
                new_ling_liao.bom_id = set_order_state.bom_id
                new_ling_liao.pcb_order_id = set_order_state.pcb_order_id
                new_ling_liao.pcb_order_sell_item_id = set_order_state.pcb_order_sell_item_id
                new_ling_liao.pcb_order_no = set_order_state.pcb_order_no
                new_ling_liao.pcb_order_no_son = set_order_state.pcb_order_no_son
                new_ling_liao.moko_code = set_order_state.moko_code
                new_ling_liao.moko_des = set_order_state.moko_des
                new_ling_liao.des_en = set_order_state.des_en
                new_ling_liao.des_cn = set_order_state.des_cn
                new_ling_liao.qty = set_order_state.qty
                new_ling_liao.p_type = set_order_state.p_type
                new_ling_liao.moko_attribute = set_order_state.moko_attribute
                new_ling_liao.t_p = set_order_state.t_p
                new_ling_liao.price = set_order_state.price
                new_ling_liao.att = set_order_state.att
                new_ling_liao.state = set_order_state.state
                new_ling_liao.remark = set_order_state.remark
                new_ling_liao.p_remark = set_order_state.p_remark
                new_ling_liao.save
=begin
                if new_ling_liao.save
                    get_order_data = PiPmcItem.find_by_sql("SELECT * FROM pi_pmc_items WHERE erp_no_son = '#{params[:order]}'")
                    get_order_data.each do |item|
                        new_ling_liao_item = LingLiaoDanItem.new
                        new_ling_liao_item.ling_liao_dan_info_id = new_ling_liao.id
                        new_ling_liao_item.pi_bom_qty_info_item_id = item.pi_bom_qty_info_item_id
                        new_ling_liao_item.pi_info_id = item.pi_info_id
                        new_ling_liao_item.pi_item_id = item.pi_item_id
                        new_ling_liao_item.pmc_flag = item.pmc_flag
                        new_ling_liao_item.state = item.state
                        new_ling_liao_item.pmc_type = item.pmc_type
                        new_ling_liao_item.buy_type = item.buy_type
                        new_ling_liao_item.erp_no = item.erp_no
                        new_ling_liao_item.erp_no_son = item.erp_no_son
                        new_ling_liao_item.moko_part = item.moko_part
                        new_ling_liao_item.moko_des = item.moko_des
                        new_ling_liao_item.part_code = item.part_code
                        new_ling_liao_item.qty = item.qty
                        new_ling_liao_item.f_qty = item.qty
                        new_ling_liao_item.pmc_qty = item.pmc_qty
                        new_ling_liao_item.qty_in = item.qty_in
                        new_ling_liao_item.remark = item.remark
                        new_ling_liao_item.buy_user = item.buy_user
                        new_ling_liao_item.buy_qty = item.buy_qty
                        new_ling_liao_item.p_item_id = item.p_item_id
                        new_ling_liao_item.erp_id = item.erp_id
                        new_ling_liao_item.user_do = item.user_do
                        new_ling_liao_item.user_do_change = item.user_do_change
                        new_ling_liao_item.check = item.check
                        new_ling_liao_item.pi_buy_info_id = item.pi_buy_info_id
                        new_ling_liao_item.procurement_bom_id = item.procurement_bom_id
                        new_ling_liao_item.quantity = item.quantity
                        new_ling_liao_item.qty_done = item.qty_done
                        new_ling_liao_item.qty_wait = item.qty_wait
                        new_ling_liao_item.wh_qty = item.wh_qty
                        new_ling_liao_item.description = item.description
                        new_ling_liao_item.fengzhuang = item.fengzhuang
                        new_ling_liao_item.link = item.link
                        new_ling_liao_item.cost = item.cost
                        new_ling_liao_item.info = item.info
                        new_ling_liao_item.product_id = item.product_id
                        new_ling_liao_item.warn = item.warn
                        new_ling_liao_item.user_id = item.user_id
                        new_ling_liao_item.danger = item.danger
                        new_ling_liao_item.manual = item.manual
                        new_ling_liao_item.mark = item.mark
                        new_ling_liao_item.mpn = item.mpn
                        new_ling_liao_item.mpn_id = item.mpn_id
                        new_ling_liao_item.price = item.price
                        new_ling_liao_item.mf = item.mf
                        new_ling_liao_item.dn_id = item.dn_id
                        new_ling_liao_item.dn = item.dn
                        new_ling_liao_item.dn_long = item.dn_long
                        new_ling_liao_item.other = item.other
                        new_ling_liao_item.all_info = item.all_info
                        new_ling_liao_item.color = item.color
                        new_ling_liao_item.supplier_tag = item.supplier_tag
                        new_ling_liao_item.supplier_out_tag = item.supplier_out_tag
                        new_ling_liao_item.sell_feed_back_tag = item.sell_feed_back_tag
                        new_ling_liao_item.pass_at = item.pass_at
                        new_ling_liao_item.save
                    end
                end
=end
                set_order_state.factory_state = "checking"
                set_order_state.save
                redirect_to edit_ling_liao_dan_path(id: new_ling_liao.id) and return
            end
            
        end
        redirect_to :back
        
    end

    def edit_ling_liao_dan
        @ling_liao_data = LingLiaoDanInfo.find_by_id(params[:id])
        @ling_liao_pmc = PiPmcItem.find_by_sql("SELECT * FROM pi_pmc_items WHERE erp_no_son = '#{@ling_liao_data.pcb_order_no_son}'")
        @ling_liao_item = LingLiaoDanItem.where(ling_liao_dan_info_id: params[:id])
    end

    def up_ling_liao_dan
        get_data = LingLiaoDanInfo.find_by_id(params[:ling_liao_dan_id])
        get_data.ling_liao_state = "checking"
        get_data.checked_user = current_user.email
        get_data.checked_user = current_user.full_name  
        get_data.checked_at = Time.new 
        get_data.save
        redirect_to :back
    end

    def check_ling_liao_dan
        get_data = LingLiaoDanInfo.find_by_id(params[:ling_liao_dan_id])
        get_data.ling_liao_state = "checked"
        get_data.checked_user = current_user.email
        get_data.checked_user = current_user.full_name  
        get_data.checked_at = Time.new 
        if get_data.save
            set_order_state = PcbOrderItem.find_by_pcb_order_no_son(get_data.pcb_order_no_son)
            if set_order_state.state != "online"
                get_order_data = PiPmcItem.find_by_sql("SELECT DISTINCT p_item_id,moko_part FROM pi_pmc_items WHERE erp_no_son = '#{get_data.pcb_order_no_son}'")
                get_order_data.each do |item|
                    wh_data = WarehouseInfo.find_by_moko_part(item.moko_part)
                    wh_data.wh_qty = wh_data.wh_qty - item.qty
                    wh_data.wh_f_qty = wh_data.wh_f_qty - item.qty
                    wh_data.save
                end
                set_order_state = PcbOrderItem.find_by_pcb_order_no_son(get_data.pcb_order_no_son)
                set_order_state.state = "online"
                set_order_state.save
            end
        end
        redirect_to :back
    end

    def factory_online
        if can? :work_c, :all or can? :work_admin, :all
            #get_order_data = PiPmcItem.where(erp_no_son: params[:order])
            set_order_state = PcbOrderItem.find_by_pcb_order_no_son(params[:order])
            if set_order_state.state != "online"
                get_order_data = PiPmcItem.find_by_sql("SELECT DISTINCT p_item_id,moko_part FROM pi_pmc_items WHERE erp_no_son = '#{params[:order]}'")
                get_order_data.each do |item|
                    wh_data = WarehouseInfo.find_by_moko_part(item.moko_part)
                    wh_data.wh_qty = wh_data.wh_qty - item.qty
                    wh_data.wh_f_qty = wh_data.wh_f_qty - item.qty
                    wh_data.save
                end
                set_order_state = PcbOrderItem.find_by_pcb_order_no_son(params[:order])
                set_order_state.state = "online"
                set_order_state.save
            end
        end
        redirect_to :back
    end

    def cai_gou_fa_piao_list
        @fa_piao = CaiGouFaPiaoInfo.all
    end

    def show_cai_gou_fa_piao
        @fa_piao = CaiGouFaPiaoInfo.find_by_id(params[:id])
        @fa_piao_item = CaiGouFaPiaoItem.where(cai_gou_fa_piao_info_id: params[:id])
    end

    def edit_cai_gou_fa_piao
        fa_piao = CaiGouFaPiaoInfo.find_by_id(params[:cai_gou_fa_piao_id])
        supplier_data = SupplierList.find_supplier_code(fa_piao.dn)
        fa_piao.fa_piao_state = "checked"
        if fa_piao.save
            get_data = CaiGouFaPiaoItem.find_by_sql("SELECT Sum(cai_gou_fa_piao_items.cost) AS cost FROM cai_gou_fa_piao_items WHERE cai_gou_fa_piao_items.cai_gou_fa_piao_info_id='#{params[:cai_gou_fa_piao_id]}'")
            pingzheng_data = FuKuanPingZhengYuejieInfo.new
            pingzheng_data.cai_gou_fa_piao_info_id = fa_piao.id
            pingzheng_data.jie_fang_kemu = "2202-应付账款---" + get_fukuan.dn.to_s + "---" + get_fukuan.dn_long
            pingzheng_data.dai_fang_kemu = ""
            pingzheng_data.jie_fang = get_data.first.cost + (get_data.first.cost*supplier_data.supplier.tax)
            pingzheng_data.dai_fang = get_data.first.cost + (get_data.first.cost*supplier_data.supplier.tax)
            pingzheng_data.yuan_cai_liao = get_data.first.cost
            pingzheng_data.ying_jiao_shui_fei = get_data.first.cost*supplier_data.supplier.tax
            pingzheng_data.save
        end
        redirect_to :back and return
    end

    def edit_wh_order
        @wh_info = PiWhInfo.find_by(pi_wh_no: params[:pi_wh_no])
        @wh_item = PiWhItem.where(pi_wh_info_no: params[:pi_wh_no])
        @all_dn = "[&quot;"
        #all_s_dn = AllDn.find_by_sql("SELECT DISTINCT all_dns.dn, all_dns.dn_long FROM all_dns GROUP BY all_dns.dn")
        all_s_dn = SupplierList.find_by_sql("SELECT  supplier_name, supplier_name_long FROM supplier_lists ")
        all_s_dn.each do |dn|
            @all_dn += "&quot;,&quot;" + dn.supplier_name.to_s + "&#{dn.supplier_name_long.to_s}"
        end
        @all_dn += "&quot;]"
    end

    def wh_draft
        wh_order = PiWhInfo.find_by_pi_wh_no(params[:wh_no])
        if not wh_order.blank?
            if wh_order.state == "new" or wh_order.state == "fail"
                wh_order.state = "checking"
                wh_order.save
            elsif wh_order.state == "checking"
                if params[:commit] == "PASS"
                    wh_order.state = "checked"
                elsif params[:commit] == "FAIL"
                    wh_order.state = "fail"
                end
                wh_order.save
            end
            if wh_order.state == "checked"
                new_fapiao = CaiGouFaPiaoInfo.new
                new_fapiao.site = wh_order.site
                new_fapiao.pi_wh_id = wh_order.id
                new_fapiao.pi_wh_no = wh_order.pi_wh_no
                new_fapiao.wh_user = wh_order.wh_user
                new_fapiao.state = wh_order.state
                if not wh_order.dn.blank?
                    new_fapiao.supplier_list_id = SupplierList.find_by_supplier_name(wh_order.dn).id
                end
                new_fapiao.dn = wh_order.dn
                new_fapiao.dn_long = wh_order.dn_long
                #new_fapiao.cai_gou_fang_shi = wh_order.
                new_fapiao.wh_at = wh_order.created_at
                new_fapiao.save
            #if wh_order.state == "new"
                new_t_p = 0
                new_tax_t_p = 0
                wh_in_data = PiWhItem.where(pi_wh_info_no: params[:wh_no])
                if not wh_in_data.blank?
                    wh_in_data.each do |wh_in|
                        new_fapiao_item = CaiGouFaPiaoItem.new
                        new_fapiao_item.cai_gou_fa_piao_info_id = new_fapiao.id
                        new_fapiao_item.pmc_flag = wh_in.pmc_flag
                        new_fapiao_item.pi_pmc_item_id = wh_in.pi_pmc_item_id
                        new_fapiao_item.buy_user = wh_in.buy_user
                        new_fapiao_item.pi_wh_info_id = wh_in.pi_wh_info_id
                        new_fapiao_item.pi_wh_info_no = wh_in.pi_wh_info_no
                        new_fapiao_item.pi_buy_item_id = wh_in.pi_buy_item_id
                        new_fapiao_item.moko_part = wh_in.moko_part
                        new_fapiao_item.moko_des = wh_in.moko_des
                        new_fapiao_item.qty_in = wh_in.qty_in
                        new_fapiao_item.remark = wh_in.remark
                        new_fapiao_item.p_item_id = wh_in.p_item_id
                        new_fapiao_item.erp_id = wh_in.erp_id
                        new_fapiao_item.erp_no = wh_in.erp_no
                        new_fapiao_item.pi_buy_info_id = wh_in.pi_buy_info_id
                        new_fapiao_item.procurement_bom_id = wh_in.procurement_bom_id
                        new_fapiao_item.state = wh_in.state
                        get_buy_info = PiBuyItem.find_by_id(wh_in.pi_buy_item_id)
                        new_fapiao_item.cost = get_buy_info.cost
                        new_fapiao_item.tax_cost = get_buy_info.tax_cost
                        #new_fapiao_item.tax = get_buy_info.tax
                        new_fapiao_item.tax_t_p = get_buy_info.tax_t_p
                        new_fapiao_item.save   
                        new_t_p += new_fapiao_item.cost
                        new_tax_t_p += new_fapiao_item.tax_t_p           




                        wh_data = WarehouseInfo.find_by_moko_part(wh_in.moko_part)
                        if not wh_data.blank?
                            wh_data.wh_qty = wh_data.wh_qty + wh_in.qty_in
                            #if wh_data.site == "c"
                                #wh_data.wh_c_qty = wh_data.wh_c_qty + wh_in.qty_in
                            #elsif wh_data.site == "f"
                            wh_data.wh_f_qty = wh_data.wh_f_qty + wh_in.qty_in
                            #end
                            if wh_in.buy_user == "MOKO"
                                wh_data.temp_moko_qty = wh_data.temp_moko_qty - wh_in.qty_in
                            elsif wh_in.buy_user == "MOKO_TEMP" 
                                wh_data.temp_future_qty = wh_data.temp_future_qty - wh_in.qty_in
                            elsif wh_in.buy_user == "CUSTOMER" 
                                wh_data.temp_customer_qty = wh_data.temp_customer_qty - wh_in.qty_in
                            else
                                if wh_data.temp_buy_qty >= wh_in.qty_in
                                    wh_data.temp_buy_qty = wh_data.temp_buy_qty - wh_in.qty_in 
                                    wh_data.true_buy_qty = wh_data.true_buy_qty - wh_in.qty_in
                                    if  wh_in.pmc_flag == "pmc"
                                        wh_data.future_qty - wh_data.future_qty - wh_in.qty_in
                                        wh_data.qty = wh_data.qty + wh_in.qty_in
                                    end
                                elsif wh_data.temp_buy_qty < wh_in.qty_in
                                    if  wh_in.pmc_flag == "pmc"
                                        wh_data.qty = wh_data.qty + wh_in.qty_in
                                        if wh_data.future_qty - wh_in.qty_in > 0
                                            wh_data.future_qty = wh_data.future_qty - wh_in.qty_in
                                        else
                                            wh_data.future_qty = 0
                                        end
                                    else
                                        wh_data.qty = wh_data.qty + (wh_in.qty_in - wh_data.temp_buy_qty)
                                        if wh_data.future_qty - (wh_in.qty_in - wh_data.temp_buy_qty) > 0
                                            wh_data.future_qty = wh_data.future_qty - (wh_in.qty_in - wh_data.temp_buy_qty)
                                        else
                                            wh_data.future_qty = 0
                                        end
                                    end
                                    wh_data.temp_buy_qty = 0
                                    wh_data.true_buy_qty = wh_data.true_buy_qty - wh_in.qty_in
                                     
                                end 
                            end
                            #wh_data.qty = wh_data.qty + wh_in.qty_in
                            #wh_data.save
                        else   
                            wh_data = WarehouseInfo.new
                            wh_data.moko_part = wh_in.moko_part
                            wh_data.moko_des = wh_in.moko_des
                            if wh_in.pmc_flag == "pmc"
                                wh_data.qty = wh_in.qty_in  
                            end
                            wh_data.wh_qty = wh_in.qty_in
                            wh_data.wh_f_qty = wh_in.qty_in                        
                            #wh_data.save
                        end
                        if wh_data.save
                            pmc_data = PiPmcItem.find_by_id(wh_in.pi_pmc_item_id)
                            if pmc_data.qty_in.to_i - wh_in.qty_in.to_i <= 0
                                pmc_data.buy_type = "done"
                            end
                            pmc_data.qty_in = pmc_data.qty_in.to_i - wh_in.qty_in.to_i
                            pmc_data.save
                            find_order_done = PiPmcItem.where(erp_no_son: pmc_data.erp_no_son,buy_type: "")
                            if find_order_done.blank?
                                get_order_son = PcbOrderItem.find_by_pcb_order_no_son(pmc_data.erp_no_son)
                                if not get_order_son.blank?
                                    get_order_son.buy_type = "done"
                                    get_order_son.save
                                end
                            end
                            uo_buy_item = PiBuyItem.find_by_id(wh_in.pi_buy_item_id)
                            uo_buy_item.qty_done = uo_buy_item.qty_done + wh_in.qty_in
                            uo_buy_item.qty_wait = uo_buy_item.qty_wait - wh_in.qty_in
                            uo_buy_item.save
                            if uo_buy_item.qty_done  >= uo_buy_item.buy_qty 
                                uo_buy_item.state = "done"
                                uo_buy_item.save
                            end
                            
                            item_data = PiBuyItem.find_by_id(wh_in.pi_buy_item_id)
                            if not item_data.blank?
                                add_history_data = WhInHistoryItem.new
                                add_history_data.wh_qty_in = wh_in.qty_in
                                add_history_data.p_item_id = item_data.id
                                add_history_data.erp_id = item_data.erp_id
                                add_history_data.erp_no = item_data.erp_no
                                add_history_data.erp_no_son = item_data.erp_no_son
                                add_history_data.user_do = item_data.user_do
                                add_history_data.user_do_change = item_data.user_do_change
                                add_history_data.check = item_data.check
                                add_history_data.pi_buy_info_id = wh_in.pi_buy_info_id
                                add_history_data.procurement_bom_id = item_data.procurement_bom_id
                                add_history_data.quantity = item_data.quantity
                                add_history_data.qty = item_data.qty
                                add_history_data.description = item_data.description
                                add_history_data.part_code = item_data.part_code
                                add_history_data.fengzhuang = item_data.fengzhuang
                                add_history_data.link = item_data.link
                                add_history_data.cost = item_data.cost
                                add_history_data.info = item_data.info
                                add_history_data.product_id = item_data.product_id
                                add_history_data.moko_part = item_data.moko_part
                                add_history_data.moko_des = item_data.moko_des
                                add_history_data.warn = item_data.warn
                                add_history_data.user_id = item_data.user_id
                                add_history_data.danger = item_data.danger
                                add_history_data.manual = item_data.manual
                                add_history_data.mark = item_data.mark
                                add_history_data.mpn = item_data.mpn
                                add_history_data.mpn_id = item_data.mpn_id
                                add_history_data.price = item_data.price
                                add_history_data.mf = item_data.mf
                                add_history_data.dn = item_data.dn
                                add_history_data.dn_id = item_data.dn_id
                                add_history_data.dn_long = item_data.dn_long
                                add_history_data.other = item_data.other
                                add_history_data.all_info = item_data.all_info
                                add_history_data.remark = item_data.remark
                                add_history_data.color = item_data.color
                                add_history_data.supplier_tag = item_data.supplier_tag
                                add_history_data.supplier_out_tag = item_data.supplier_out_tag
                                add_history_data.sell_feed_back_tag = item_data.sell_feed_back_tag
                                add_history_data.save
                            end
                        end
                    end
                end
                wh_order.state = "done"
                wh_order.save
                new_fapiao.t_p = new_t_p
                new_fapiao.tax_t_p = new_tax_t_p
                new_fapiao.save
            end            
        end
        redirect_to wh_draft_list_path()
    end

    def find_fu_kuan_item
        @all_item = ''
        if not params[:date_at].blank?
            #get_item_data = PiBuyItem.where("supplier_list_id = '#{params[:supplier_list_id]}' AND yi_fu_kuan_p < buy_qty*cost")
            if not params[:supplier_list_id].blank?
                get_info_data = CaiGouFaPiaoInfo.where("supplier_list_id = '#{params[:supplier_list_id]}' AND date_format(wh_at,'%Y-%m') ='#{params[:date_at]}'")
            else
                get_info_data = CaiGouFaPiaoInfo.where("date_format(wh_at,'%Y-%m') ='#{params[:date_at]}'")
            end
            if not get_info_data.blank?
                get_info_data.each do |item|
                    @all_item += '<tr>' 
                    @all_item += '<td><input class="chk_all" type="checkbox" value="' + item.id.to_s + '" name="roles[]" id="roles_" checked></td>'
                    @all_item += '<td>' + item.wh_at.localtime.strftime('%Y-%m') + '</td>'
                    @all_item += '<td>' + item.t_p.to_s + '</td>'
                    @all_item += '<td>' + item.tax_t_p.to_s + '</td>'
                    @all_item += '</tr>'
                end
            end
        end
    end

    def edit_fu_kuan_shen_qing_dan
        if not params[:id].blank?
            @fu_kuan = FuKuanShenQingDanInfo.find_by_id(params[:id])
            if not @fu_kuan.supplier_code.blank?
               @bank_user = SupplierBankList.find_by_sql("SELECT supplier_bank_user,id FROM supplier_bank_lists WHERE supplier_code = '#{@fu_kuan.supplier_code}'")
            end
            @fu_kuan_item = FuKuanShenQingDanItem.where(fu_kuan_shen_qing_dan_info_id: params[:id])
            if @fu_kuan.supplier_clearing == "日结"
                @buy_item = PiBuyItem.where("supplier_list_id = '#{@fu_kuan.supplier_list_id}' AND yi_fu_kuan_p < buy_qty*cost")
            elsif @fu_kuan.supplier_clearing == "月结"
                
            end
            @t_p = FuKuanShenQingDanItem.find_by_sql("SELECT SUM(shen_qing_p) AS t_p FROM fu_kuan_shen_qing_dan_items WHERE fu_kuan_shen_qing_dan_info_id = '#{params[:id]}'").first.t_p
        end
    end

    def fu_kuan_dan_list
        if not params[:state].blank?
            if params[:state] == "none"
                @list = FuKuanShenQingDanInfo.where(state: "checked",fu_kuan_dan_state: "")
                render "fu_kuan_dan_list_new.html.erb" and return
            elsif params[:state] == "new"
                @list = FuKuanDanInfo.where(state: "new")
                render "fu_kuan_dan_list.html.erb" and return
            elsif params[:state] == "check"
                @list = FuKuanDanInfo.where(state: "check")
                render "fu_kuan_dan_list.html.erb" and return
            elsif params[:state] == "checked"
                @list = FuKuanDanInfo.where(state: "checked")
                render "fu_kuan_dan_list.html.erb" and return
            end
        end
    end

    def fu_kuan_shen_qing_list
        if not params[:state].blank?
            if params[:state] == "new"
                @list = FuKuanShenQingDanInfo.where(state: "")
            elsif params[:state] == "check"
                @list = FuKuanShenQingDanInfo.where(state: "check")
            elsif params[:state] == "checked"
                @list = FuKuanShenQingDanInfo.where(state: "checked")
            end
        else 
            @list = FuKuanShenQingDanInfo.all
        end
    end

    def fu_kuan_dan_to_check
        if not params[:fu_kuan_dan_to_check_id].blank?
            get_fukuan = FuKuanDanInfo.find_by_id(params[:fu_kuan_dan_to_check_id])
            get_fukuan.state = "check"
            get_fukuan.save
        end
        redirect_to fu_kuan_dan_list_path() and return
    end

    def fu_kuan_dan_to_checked
        if not params[:fu_kuan_dan_to_check_id].blank?
            @t_p = FuKuanDanItem.find_by_sql("SELECT SUM(fu_kuan_p) AS true_t_p FROM fu_kuan_dan_items WHERE fu_kuan_dan_info_id = '#{params[:fu_kuan_dan_to_check_id]}'").first.true_t_p
            get_fukuan = FuKuanDanInfo.find_by_id(params[:fu_kuan_dan_to_check_id])
            get_fukuan.state = "checked"
            get_fukuan.true_t_p = @t_p
            if get_fukuan.save
                fu_kuan_ping_zheng_info = ZongZhangInfo.new
                fu_kuan_ping_zheng_info.type = "fu"
                fu_kuan_ping_zheng_info.fu_kuan_dan_info_id = get_fukuan.id
                #fu_kuan_ping_zheng_info.no = 1
                #fu_kuan_ping_zheng_info.des = finance_voucher_info.sell_team.to_s + finance_voucher_info.sell_full_name_up.to_s + finance_voucher_info.pi_info_no.to_s
                fu_kuan_ping_zheng_info.remark = get_fukuan.remark
                fu_kuan_ping_zheng_info.jie_fang_kemu = "2202-应付账款---" + get_fukuan.supplier_code.to_s + "---" + get_fukuan.supplier_name
                fu_kuan_ping_zheng_info.dai_fang_kemu = get_fukuan.xianjin_kemu.to_s
                fu_kuan_ping_zheng_info.jie_fang = get_fukuan.true_t_p
                fu_kuan_ping_zheng_info.dai_fang = get_fukuan.true_t_p
                fu_kuan_ping_zheng_info.finance_at = get_fukuan.finance_at
                fu_kuan_ping_zheng_info.save
            end
        end
        redirect_to fu_kuan_dan_list_path() and return
    end

    def fu_kuan_shen_qing_to_check
        if not params[:fu_kuan_shen_qing_to_check_id].blank?
            get_fukuan = FuKuanShenQingDanInfo.find_by_id(params[:fu_kuan_shen_qing_to_check_id])
            if get_fukuan.supplier_bank_user.blank?
                Rails.logger.info("1111111111111111111111111111")
                redirect_to :back, :flash => {:error => "请选择付款户名！！！"} and return false
            else
                Rails.logger.info("22222222222222222222222222")
                get_fukuan.state = "check"
                get_fukuan.save
            end
        end
        redirect_to :back and return
    end

    def fu_kuan_shen_qing_to_checked
        if not params[:fu_kuan_shen_qing_to_check_id].blank?
            get_fukuan = FuKuanShenQingDanInfo.find_by_id(params[:fu_kuan_shen_qing_to_check_id])
            get_fukuan.user_checked = current_user.full_name
            get_fukuan.state = "checked"
            get_fukuan.save
        end
        redirect_to :back and return
    end

    def edit_fukuandan_xianjin_kemu
        if not params[:fu_kuan_dan_id].blank?
            get_data = FuKuanDanInfo.find_by_id(params[:fu_kuan_dan_id])
            get_data.xianjin_kemu = params[:xianjin_kemu]
            get_data.save
        end
        redirect_to :back and return
    end

    def edit_fukuandan_finance_at
        if not params[:fu_kuan_dan_id].blank?
            get_data = FuKuanDanInfo.find_by_id(params[:fu_kuan_dan_id])
            get_data.finance_at = params[:finance_at]
            get_data.save
        end
        redirect_to :back and return
    end

    def edit_fu_kuan_p
        if not params[:fu_kuan_p_id].blank?
            get_item = FuKuanDanItem.find_by_id(params[:fu_kuan_p_id])
            get_item.fu_kuan_p = params[:fu_kuan_p]
            get_item.zhe_kou_p = BigDecimal.new(get_item.shen_qing_p) - BigDecimal.new(params[:fu_kuan_p])
            get_item.save
        end
        redirect_to :back and return
    end

    def new_fu_kuan_dan
        if not params[:id].blank?
            check_data = FuKuanDanInfo.find_by_fu_kuan_shen_qing_dan_info_id(params[:id])
            if check_data.blank?
                copy_data = FuKuanShenQingDanInfo.find_by_id(params[:id])
                new_fu_kuan_dan = FuKuanDanInfo.new
                new_fu_kuan_dan.fu_kuan_shen_qing_dan_info_id = params[:id]
                new_fu_kuan_dan.user_new = current_user.full_name
                new_fu_kuan_dan.user_fu_kuan_shen_qing_dan = copy_data.user_new
                new_fu_kuan_dan.state = "new"
                new_fu_kuan_dan.t_p = copy_data.t_p
                new_fu_kuan_dan.supplier_code = copy_data.supplier_code
                new_fu_kuan_dan.supplier_name = copy_data.supplier_name
                new_fu_kuan_dan.supplier_name_long = copy_data.supplier_name_long
                new_fu_kuan_dan.supplier_list_id = copy_data.supplier_list_id
                new_fu_kuan_dan.supplier_clearing = copy_data.supplier_clearing
                new_fu_kuan_dan.supplier_address = copy_data.supplier_address
                new_fu_kuan_dan.supplier_contacts = copy_data.supplier_contacts
                new_fu_kuan_dan.supplier_phone = copy_data.supplier_phone
                new_fu_kuan_dan.supplier_bank_user = copy_data.supplier_bank_user
                new_fu_kuan_dan.supplier_bank_account = copy_data.supplier_bank_account
                new_fu_kuan_dan.supplier_bank_name = copy_data.supplier_bank_name
                new_fu_kuan_dan.shen_qing_jiner = copy_data.shen_qing_jiner
                new_fu_kuan_dan.shen_pi_jiner = copy_data.shen_pi_jiner
                new_fu_kuan_dan.remark = copy_data.remark
                new_fu_kuan_dan.kuai_ji_ke_mu = params[:kuai_ji_ke_mu]
                new_fu_kuan_dan.finance_at = params[:finance_at]
                if new_fu_kuan_dan.save
                    copy_data.fu_kuan_dan_state = "done"
                    copy_data.save
                    copy_data_item = FuKuanShenQingDanItem.where(fu_kuan_shen_qing_dan_info_id: params[:id])
                    if not copy_data_item.blank?
                        copy_data_item.each do |item|
                            new_fu_kuan_dan_item = FuKuanDanItem.new
                            new_fu_kuan_dan_item.pi_info_id = item.pi_info_id
                            new_fu_kuan_dan_item.pi_item_id = item.pi_item_id
                            new_fu_kuan_dan_item.fu_kuan_dan_info_id = new_fu_kuan_dan.id
                            new_fu_kuan_dan_item.pi_buy_info_id = item.pi_buy_info_id
                            new_fu_kuan_dan_item.pi_buy_item_id = item.pi_buy_item_id
                            new_fu_kuan_dan_item.pi_buy_no = item.pi_buy_no
                            new_fu_kuan_dan_item.t_p = item.t_p
                            new_fu_kuan_dan_item.ding_dan_zhi_fu_bi_li = item.ding_dan_zhi_fu_bi_li
                            new_fu_kuan_dan_item.shen_qing_p = item.shen_qing_p
                            new_fu_kuan_dan_item.fu_kuan_p = item.shen_qing_p
                            #new_fu_kuan_dan_item.zhe_kou_p = params[:zhe_kou_p]
                            new_fu_kuan_dan_item.shen_pi_p = item.shen_pi_p
                            new_fu_kuan_dan_item.moko_part = item.moko_part
                            new_fu_kuan_dan_item.moko_des = item.moko_des
                            new_fu_kuan_dan_item.save
                        end
                    end
                end
                redirect_to edit_fu_kuan_dan_path(id: new_fu_kuan_dan.id) and return
            else
                redirect_to :back, :flash => {:error => "这个付款申请单已经做了付款单！"} and return
            end
        end
        redirect_to :back, :flash => {:error => "付款申请单异常！"} and return
    end

    def edit_fu_kuan_dan
        @type_b = "[&quot;"
        
        all_type_b = KuaijikemuInfo.find_by_sql("select CONCAT(code_a_name,'-',code_b_name,'-',code_c_name) AS c_name,CONCAT(code_a,' ',code_b,' ',code_c) AS c_code from kuaijikemu_infos")
        all_type_b.each do |type_b|
            @type_b += "&quot;,&quot;" + type_b.c_code.strip.split(" ")[-1] + "-" + type_b.c_name.split("-").join(" ").strip.split(" ").join("-")
        end
        @type_b += "&quot;]"
        if not params[:id].blank?
            @fu_kuan_dan = FuKuanDanInfo.find_by_id(params[:id])
            @fu_kuan_dan_item = FuKuanDanItem.where(fu_kuan_dan_info_id: params[:id])
        end
    end



    def edit_fu_kuan_bank_user
        if not params[:id].blank?
            get_fukuan = FuKuanShenQingDanInfo.find_by_id(params[:id])
            get_bank =SupplierBankList.find_by_id(params[:bank_user_edit])
            get_fukuan.supplier_bank_user = get_bank.supplier_bank_user
            get_fukuan.supplier_bank_name = get_bank.supplier_bank_name
            get_fukuan.supplier_bank_account = get_bank.supplier_bank_account
            get_fukuan.save
        end
        redirect_to :back and return
    end

    def edit_fu_kuan_bank
        if not params[:id].blank?
            get_fukuan = FuKuanShenQingDanInfo.find_by_id(params[:id])
            get_fukuan.supplier_bank_user = params[:supplier_bank_user]
            get_fukuan.supplier_bank_name = params[:supplier_bank_name]
            get_fukuan.supplier_bank_account = params[:supplier_bank_account]
            get_fukuan.save
        end
        redirect_to :back and return
    end

    def edit_wh_order_songhuono
        if not params[:id].blank?
            get_wh = PiWhInfo.find_by_id(params[:id])
            get_wh.song_huo_no = params[:songhuono_edit]
            get_wh.save
        end
        redirect_to :back and return
    end

    def edit_wh_order_remark
        if not params[:id].blank?
            get_wh = PiWhInfo.find_by_id(params[:id])
            get_wh.remark = params[:bei_zhu_edit]
            get_wh.save
        end
        redirect_to :back and return
    end

    def edit_zhi_fu_bi_li
        if not params[:zhi_fu_bi_li_id].blank?
            get_fukuan = FuKuanShenQingDanItem.find_by_id(params[:zhi_fu_bi_li_id])
            get_buyitem = PiBuyItem.find_by_id(get_fukuan.pi_buy_item_id)
            shen_qing_p = BigDecimal.new(get_buyitem.buy_qty)*BigDecimal.new(get_buyitem.cost)*BigDecimal.new(params[:zhi_fu_bi_li])/100
            Rails.logger.info("add-------------------------------------12")
            Rails.logger.info(shen_qing_p.to_i.inspect)
            Rails.logger.info((BigDecimal.new(get_buyitem.buy_qty)*BigDecimal.new(get_buyitem.cost)).to_i.inspect)
            Rails.logger.info("add-------------------------------------12")
            if (BigDecimal.new(get_buyitem.buy_qty)*BigDecimal.new(get_buyitem.cost)-(BigDecimal.new(get_buyitem.yi_fu_kuan_p) - BigDecimal.new(get_fukuan.shen_qing_p))) >= shen_qing_p
                get_buyitem.yi_fu_kuan_p = BigDecimal.new(get_buyitem.yi_fu_kuan_p) - BigDecimal.new(get_fukuan.shen_qing_p)
                get_buyitem.save
                get_fukuan.ding_dan_zhi_fu_bi_li = BigDecimal.new(params[:zhi_fu_bi_li])
                get_fukuan.shen_qing_p = BigDecimal.new(get_buyitem.buy_qty)*BigDecimal.new(get_buyitem.cost)*BigDecimal.new(params[:zhi_fu_bi_li])/100
                get_fukuan.save
                get_buyitem.yi_fu_kuan_p = BigDecimal.new(get_buyitem.yi_fu_kuan_p) + BigDecimal.new(get_fukuan.shen_qing_p)
                get_buyitem.save
                redirect_to :back and return
            else
                redirect_to :back, :flash => {:error => "请款比例超过100%！"} and return
            end
        end
    end

    def add_fu_kuan_shen_qing_dan_item
        if not params[:fu_kuan_shen_qing_dan_id].blank?
            get_fu_kuan_info = FuKuanShenQingDanInfo.find_by_id(params[:fu_kuan_shen_qing_dan_id])
            if not params[:roles].blank?
                params[:roles].each do |id|
                    if get_fu_kuan_info.supplier_clearing == "月结"
                        cai_gou_fa_piao_item_data = CaiGouFaPiaoItem.where(cai_gou_fa_piao_info: id)
                        if not cai_gou_fa_piao_item_data.blank?
                            cai_gou_fa_piao_item_data.each do |item|
                                buy_data = PiBuyItem.find_by_id(item.pi_buy_item_id)

                                new_fu_kuan_item = FuKuanShenQingDanItem.new
                                new_fu_kuan_item.pi_info_id = buy_data.pi_info_id
                                new_fu_kuan_item.pi_item_id = buy_data.pi_item_id
                                new_fu_kuan_item.fu_kuan_shen_qing_dan_info_id = params[:fu_kuan_shen_qing_dan_id]
                                new_fu_kuan_item.pi_buy_info_id = buy_data.pi_buy_info_id
                                new_fu_kuan_item.pi_buy_item_id = buy_data.id
                                new_fu_kuan_item.pi_buy_no = PiBuyInfo.find_by_id(buy_data.pi_buy_info_id).pi_buy_no
                                new_fu_kuan_item.t_p = buy_data.buy_qty*buy_data.cost
                                new_fu_kuan_item.ding_dan_zhi_fu_bi_li = (buy_data.buy_qty*buy_data.cost - buy_data.yi_fu_kuan_p)/(buy_data.buy_qty*buy_data.cost)*100
                                new_fu_kuan_item.shen_qing_p = buy_data.buy_qty*buy_data.cost - buy_data.yi_fu_kuan_p
                                new_fu_kuan_item.moko_part = buy_data.moko_part
                                new_fu_kuan_item.moko_des = buy_data.moko_des
                                if new_fu_kuan_item.save
                                    buy_data.yi_fu_kuan_p = buy_data.yi_fu_kuan_p + new_fu_kuan_item.shen_qing_p
                                    buy_data.save
                                end

                            end
                        end
                    else
                        buy_data = PiBuyItem.find_by_id(id)
                        new_fu_kuan_item = FuKuanShenQingDanItem.new
                        new_fu_kuan_item.pi_info_id = buy_data.pi_info_id
                        new_fu_kuan_item.pi_item_id = buy_data.pi_item_id
                        new_fu_kuan_item.fu_kuan_shen_qing_dan_info_id = params[:fu_kuan_shen_qing_dan_id]
                        new_fu_kuan_item.pi_buy_info_id = buy_data.pi_buy_info_id
                        new_fu_kuan_item.pi_buy_item_id = buy_data.id
                        new_fu_kuan_item.pi_buy_no = PiBuyInfo.find_by_id(buy_data.pi_buy_info_id).pi_buy_no
                        new_fu_kuan_item.t_p = buy_data.buy_qty*buy_data.cost
                        new_fu_kuan_item.ding_dan_zhi_fu_bi_li = (buy_data.buy_qty*buy_data.cost - buy_data.yi_fu_kuan_p)/(buy_data.buy_qty*buy_data.cost)*100
                        new_fu_kuan_item.shen_qing_p = buy_data.buy_qty*buy_data.cost - buy_data.yi_fu_kuan_p
                        new_fu_kuan_item.moko_part = buy_data.moko_part
                        new_fu_kuan_item.moko_des = buy_data.moko_des
                        if new_fu_kuan_item.save
                            buy_data.yi_fu_kuan_p = buy_data.yi_fu_kuan_p + new_fu_kuan_item.shen_qing_p
                            buy_data.save
                        end
                    end
                end
            end
        end
        redirect_to :back
    end

    def new_fu_kuan_shen_qing_dan
        if not params[:id].blank?
            get_supplier_data = SupplierList.find_by_id(params[:id])
            new_fu_kuan = FuKuanShenQingDanInfo.new
            new_fu_kuan.user_new = current_user.full_name
            new_fu_kuan.supplier_code = get_supplier_data.supplier_code
            new_fu_kuan.supplier_name = get_supplier_data.supplier_name
            new_fu_kuan.supplier_name_long = get_supplier_data.supplier_name_long
            new_fu_kuan.supplier_list_id = get_supplier_data.id
            new_fu_kuan.supplier_clearing = get_supplier_data.supplier_clearing
            new_fu_kuan.supplier_address = get_supplier_data.supplier_address
            new_fu_kuan.supplier_contacts = get_supplier_data.supplier_contacts
            new_fu_kuan.supplier_phone = get_supplier_data.supplier_phone
            new_fu_kuan.supplier_bank_user = get_supplier_data.supplier_bank_user
            new_fu_kuan.supplier_bank_name = get_supplier_data.supplier_bank_name
            new_fu_kuan.supplier_bank_account = get_supplier_data.supplier_bank_account
            new_fu_kuan.save
        else
            new_fu_kuan = FuKuanShenQingDanInfo.new
            new_fu_kuan.user_new = current_user.full_name
            new_fu_kuan.supplier_name = "TB"
            new_fu_kuan.supplier_name_long = "TB"
            new_fu_kuan.supplier_clearing = "日结"
            new_fu_kuan.save
        end
        redirect_to edit_fu_kuan_shen_qing_dan_path(id: new_fu_kuan.id)
    end

    def find_supplier
        if params[:supplier_code] != ""
            if params[:pay_type] == "d"
                pay_type = " AND `supplier_lists`.`supplier_clearing` = '日结'"
            elsif params[:pay_type] == "m"
                pay_type = " AND `supplier_lists`.`supplier_clearing` = '月结'"
            end
            @supplier_info = SupplierList.find_by_sql("SELECT * FROM `supplier_lists`  WHERE (`supplier_lists`.`supplier_name` LIKE '%#{params[:supplier_code]}%' OR `supplier_lists`.`supplier_name_long` LIKE '%#{params[:supplier_code]}%')#{pay_type}")
            Rails.logger.info("add-------------------------------------12")
            Rails.logger.info(@supplier_info.inspect)
            Rails.logger.info("add-------------------------------------12")
            if not @supplier_info.blank?
                Rails.logger.info("add-------------------------------------12")
                @supplier_table = '<br>'
                @supplier_table += '<small>'
                @supplier_table += '<table class="table table-bordered">'
                @supplier_table += '<thead>'
                @supplier_table += '<tr class="active">'
                @supplier_table += '<th width="70">供简称</th>'
                @supplier_table += '<th>供简全称</th>'
                @supplier_table += '<th>默认结算方式</th>'
                @supplier_table += '<tr>'
                @supplier_table += '</thead>'
                @supplier_table += '<tbody>'
                @supplier_info.each do |cu|
                    @supplier_table += '<tr>'
                    #@c_table += '<td>' + cu.c_no + '</td>'
                    @supplier_table += '<td><a rel="nofollow" data-method="get"  href="/new_fu_kuan_shen_qing_dan?id='+ cu.id.to_s + '"><div>' + cu.supplier_name.to_s.gsub(/'/,'') + '</div></a></td>'
                    @supplier_table += '<td><a rel="nofollow" data-method="get"  href="/new_fu_kuan_shen_qing_dan?id='+ cu.id.to_s + '"><div>' + cu.supplier_name_long.to_s.gsub(/'/,'') + '</div></a></td>'
                    @supplier_table += '<td><a rel="nofollow" data-method="get"  href="/new_fu_kuan_shen_qing_dan?id='+ cu.id.to_s + '"><div>' + cu.supplier_clearing.to_s.gsub(/'/,'') + '</div></a></td>'
                    @supplier_table += '</tr>'
                end
                @supplier_table += '</tbody>'
                @supplier_table += '</table>'
                @supplier_table += '</small>'
                Rails.logger.info("add-------------------------------------12")
                Rails.logger.info(@supplier_table.inspect)
                Rails.logger.info("add-------------------------------------12")
            end
        end
    end

    def find_c
        if params[:c_code] != ""
            #@c_info = PcbCustomer.find_by(c_no: params[:c_code])
            @c_info = PcbCustomer.find_by_sql("SELECT * FROM `pcb_customers`  WHERE (`pcb_customers`.`c_no` LIKE '%#{params[:c_code]}%' OR `pcb_customers`.`customer` LIKE '%#{params[:c_code]}%' OR `pcb_customers`.`customer_com` LIKE '%#{params[:c_code]}%' OR `pcb_customers`.`email` LIKE '%#{params[:c_code]}%') AND `pcb_customers`.`follow` = '#{current_user.email}'")
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
                @c_table += '<th width="70">客户代码</th>'
                @c_table += '<th>客户名</th>'
                @c_table += '<th>客户公司名</th>'
                @c_table += '<th width="70">所属</th>'
                @c_table += '<tr>'
                @c_table += '</thead>'
                @c_table += '<tbody>'
                @c_info.each do |cu|
                    @c_table += '<tr>'
                    #@c_table += '<td>' + cu.c_no + '</td>'
                    @c_table += '<td><a rel="nofollow" data-method="get"  href="/find_c_ch?id='+ cu.id.to_s + '&c_order_no=' + params[:c_order_no] + '"><div>' + cu.c_no.to_s.gsub(/'/,'') + '</div></a></td>'
                    @c_table += '<td><a rel="nofollow" data-method="get"  href="/find_c_ch?id='+ cu.id.to_s + '&c_order_no=' + params[:c_order_no] + '"><div>' + cu.customer.to_s.gsub(/'/,'') + '</div></a></td>'
                    @c_table += '<td><a rel="nofollow" data-method="get"  href="/find_c_ch?id='+ cu.id.to_s + '&c_order_no=' + params[:c_order_no] + '"><div>' + cu.customer_com.to_s.gsub(/'/,'') + '</div></a></td>'
                    @c_table += '<td><a rel="nofollow" data-method="get"  href="/find_c_ch?id='+ cu.id.to_s + '&c_order_no=' + params[:c_order_no] + '"><div>' + User.find_by(email: cu.sell).full_name.to_s + '</div></a></td>'
                    @c_table += '</tr>'
                end
                @c_table += '</tbody>'
                @c_table += '</table>'
                @c_table += '</small>'
                Rails.logger.info("add-------------------------------------12")
                Rails.logger.info(@c_table.inspect)
                Rails.logger.info("add-------------------------------------12")
            end
        end
    end

    def fu_kuan_shen_qing_type

    end

    def edit_setup_finance
        if not params[:dollar_rate].blank?
            get_data = SetupFinanceInfo.find_by_id(1)
            get_data.dollar_rate = params[:dollar_rate]
            get_data.save
        end 
        redirect_to :back
    end

    def setup_finance
        @setup_finance=SetupFinanceInfo.find_by_id(1)
    end

    def edit_voucher
        @dollar_rate = SetupFinanceInfo.find_by_id(1).dollar_rate
        if not params[:voucher_id].blank?
            get_voucher_data = FinanceVoucherInfo.find_by_id(params[:voucher_id])
            get_voucher_data.voucher_item = params[:voucher_item]
            get_voucher_data.voucher_way = params[:voucher_way]
            get_voucher_data.collection_type = params[:collection_type]
            get_voucher_data.xianjin_kemu = params[:xianjin_kemu]
            get_voucher_data.voucher_bank_name = params[:voucher_bank_name]
            get_voucher_data.voucher_bank_account = params[:voucher_bank_account]
            get_voucher_data.get_money = params[:get_money]
            get_voucher_data.get_money_self = BigDecimal.new(params[:get_money])*BigDecimal.new(@dollar_rate)
            get_voucher_data.loss_money = BigDecimal.new(get_voucher_data.pay_p)-BigDecimal.new(params[:get_money])
            get_voucher_data.loss_money_self = (BigDecimal.new(get_voucher_data.pay_p)-BigDecimal.new(params[:get_money]))*BigDecimal.new(@dollar_rate)
            get_voucher_data.voucher_remark = params[:voucher_remark]
            get_voucher_data.finance_at = params[:finance_at]
            get_voucher_data.voucher_currency_type = params[:voucher_currency_type]
            get_voucher_data.voucher_exchange_rate = params[:voucher_exchange_rate]
            get_voucher_data.voucher_full_name_up = current_user.full_name
            if get_voucher_data.save
                get_finance_payment_voucher = FinancePaymentVoucherInfo.find_by_finance_voucher_info_id(get_voucher_data.id)
                get_finance_payment_voucher.jie_fang = get_voucher_data.get_money_self
                get_finance_payment_voucher.dai_fang = get_voucher_data.get_money_self
                get_finance_payment_voucher.save
            end
        end
        redirect_to :back 
    end

    def new_voucher
        @dollar_rate = SetupFinanceInfo.find_by_id(1).dollar_rate
        if not params[:pay_id].blank?
            get_payment_notice_data = PaymentNoticeInfo.find_by_id(params[:pay_id])
            if get_payment_notice_data.state == "checked"
                redirect_to :back, :flash => {:error => "收款单不能重复！！！"} and return false
            end
            finance_voucher_info = FinanceVoucherInfo.new
            finance_voucher_info.state = "new"
            finance_voucher_info.payment_notice_info_id = get_payment_notice_data.id
            finance_voucher_info.payment_notice_info_no = get_payment_notice_data.id
            finance_voucher_info.pi_info_id = get_payment_notice_data.pi_info_id
            finance_voucher_info.pi_item_id = get_payment_notice_data.pi_item_id
            finance_voucher_info.c_id = get_payment_notice_data.c_id
            finance_voucher_info.pi_info_no = get_payment_notice_data.pi_info_no
            finance_voucher_info.pi_date = get_payment_notice_data.pi_date
            finance_voucher_info.c_code = get_payment_notice_data.c_code
            finance_voucher_info.c_des = get_payment_notice_data.c_des
            finance_voucher_info.c_country = get_payment_notice_data.c_country
            finance_voucher_info.payment_way = get_payment_notice_data.payment_way
            finance_voucher_info.currency_type = get_payment_notice_data.currency_type
            finance_voucher_info.exchange_rate = get_payment_notice_data.exchange_rate
            finance_voucher_info.pi_t_p = get_payment_notice_data.pi_t_p
            finance_voucher_info.unreceived_p = get_payment_notice_data.unreceived_p
            finance_voucher_info.pay_att = get_payment_notice_data.pay_att
            finance_voucher_info.pay_p = get_payment_notice_data.pay_p
            finance_voucher_info.pay_type = get_payment_notice_data.pay_type
            finance_voucher_info.pay_account_name = get_payment_notice_data.pay_account_name
            finance_voucher_info.pay_account_number = get_payment_notice_data.pay_account_number
            finance_voucher_info.pay_swift_code = get_payment_notice_data.pay_swift_code
            finance_voucher_info.pay_bank_name = get_payment_notice_data.pay_bank_name
            finance_voucher_info.remark = get_payment_notice_data.remark
            finance_voucher_info.sell_id = get_payment_notice_data.sell_id
            finance_voucher_info.sell_full_name_new = get_payment_notice_data.sell_full_name_new
            finance_voucher_info.sell_full_name_up = get_payment_notice_data.sell_full_name_up
            finance_voucher_info.sell_team = get_payment_notice_data.sell_team
            finance_voucher_info.send_at = get_payment_notice_data.send_at
            finance_voucher_info.voucher_item = params[:voucher_item]
            finance_voucher_info.voucher_way = params[:voucher_way]
            finance_voucher_info.collection_type = params[:collection_type]
            finance_voucher_info.xianjin_kemu = params[:xianjin_kemu]
            finance_voucher_info.voucher_bank_name = params[:voucher_bank_name]
            finance_voucher_info.voucher_bank_account = params[:voucher_bank_account]
            finance_voucher_info.get_money = params[:get_money]
            finance_voucher_info.get_money_self = BigDecimal.new(params[:get_money])*BigDecimal.new(@dollar_rate)
            finance_voucher_info.loss_money = BigDecimal.new(get_payment_notice_data.pay_p)-BigDecimal.new(params[:get_money])
            finance_voucher_info.loss_money_self = (BigDecimal.new(get_payment_notice_data.pay_p)-BigDecimal.new(params[:get_money]))*BigDecimal.new(@dollar_rate)
            finance_voucher_info.voucher_remark = params[:voucher_remark]
            #finance_voucher_info.voucher_no = params[:voucher_item]
            finance_voucher_info.voucher_at = Time.new
            finance_voucher_info.finance_at = params[:finance_at]
            finance_voucher_info.voucher_currency_type = params[:voucher_currency_type]
            finance_voucher_info.voucher_exchange_rate = params[:voucher_exchange_rate]
            finance_voucher_info.voucher_full_name_new = current_user.full_name
            finance_voucher_info.voucher_full_name_up = current_user.full_name
            if finance_voucher_info.save
                get_payment_notice_data.state = "checked"
                get_payment_notice_data.save
            end
=begin
            if finance_voucher_info.save
                
                payment_voucher_info = FinancePaymentVoucherInfo.new
                payment_voucher_info.finance_voucher_info_id = finance_voucher_info.id
                payment_voucher_info.no = 1
                payment_voucher_info.des = finance_voucher_info.sell_team.to_s + finance_voucher_info.sell_full_name_up.to_s + finance_voucher_info.pi_info_no.to_s
                payment_voucher_info.kemu = finance_voucher_info.xianjin_kemu.to_s + "---" + finance_voucher_info.c_code
                payment_voucher_info.jie_fang = finance_voucher_info.get_money_self
                payment_voucher_info.dai_fang = finance_voucher_info.get_money_self
                payment_voucher_info.finance_at = params[:finance_at]
                payment_voucher_info.save
                get_payment_notice_data.state = "checked"
                get_payment_notice_data.save
            end
=end
        end
        redirect_to :back
    end

    def voucher_checked
        if not params[:id].blank?
            finance_voucher_info = FinanceVoucherInfo.find_by_id(params[:id])
            
            if finance_voucher_info.state == "checked"
                redirect_to :back, :flash => {:error => "已经审批通过"} and return false
            end
            finance_voucher_info.state = "checked"
            if finance_voucher_info.save
                payment_voucher_info = ZongZhangInfo.new
                payment_voucher_info.zong_zhang_type = "shou"
                payment_voucher_info.finance_voucher_info_id = finance_voucher_info.id
                payment_voucher_info.no = 1
                payment_voucher_info.des = finance_voucher_info.sell_team.to_s + finance_voucher_info.sell_full_name_up.to_s + finance_voucher_info.pi_info_no.to_s
                payment_voucher_info.jie_fang_kemu = finance_voucher_info.xianjin_kemu.to_s + "---" + finance_voucher_info.c_code
                payment_voucher_info.dai_fang_kemu = finance_voucher_info.xianjin_kemu.to_s + "---" + finance_voucher_info.c_code
                payment_voucher_info.jie_fang = finance_voucher_info.get_money_self
                payment_voucher_info.dai_fang = finance_voucher_info.get_money_self
                payment_voucher_info.finance_at = params[:finance_at]
                payment_voucher_info.save
            end
        end
        redirect_to :back
    end

    def voucher_uncheck
        if not params[:id].blank?
            finance_voucher_info = FinanceVoucherInfo.find_by_id(params[:id])
            
            if finance_voucher_info.state == "checked"
                redirect_to :back, :flash => {:error => "已经审批通过"} and return false
            end
            finance_voucher_info.state = "uncheck"
            finance_voucher_info.save
        end
        redirect_to :back
    end

    def payment_notice_list
        @dollar_rate = SetupFinanceInfo.find_by_id(1).dollar_rate
        if params[:state] == "checked"
            @payment = PaymentNoticeInfo.where(state: "checked").paginate(:page => params[:page], :per_page => 20)
        else
            @payment = PaymentNoticeInfo.where(state: "checking").paginate(:page => params[:page], :per_page => 20)
        end
        @type_b = "[&quot;"
        
        all_type_b = KuaijikemuInfo.find_by_sql("select CONCAT(code_a_name,'-',code_b_name,'-',code_c_name) AS c_name,CONCAT(code_a,' ',code_b,' ',code_c) AS c_code from kuaijikemu_infos")
        all_type_b.each do |type_b|
            @type_b += "&quot;,&quot;" + type_b.c_code.strip.split(" ")[-1] + "-" + type_b.c_name.split("-").join(" ").strip.split(" ").join("-")
        end
        @type_b += "&quot;]"
    end    

    def payment_voucher_list
        @dollar_rate = SetupFinanceInfo.find_by_id(1).dollar_rate
        if params[:state] == "checked"
            @payment = FinanceVoucherInfo.where("state = 'checked' AND DATE_FORMAT(created_at, '%Y%m') = DATE_FORMAT(CURDATE() , '%Y%m')").paginate(:page => params[:page], :per_page => 20)
        elsif params[:state] == "uncheck"
            @payment = FinanceVoucherInfo.where("state = 'uncheck' AND DATE_FORMAT(created_at, '%Y%m') = DATE_FORMAT(CURDATE() , '%Y%m')").paginate(:page => params[:page], :per_page => 20)
        else 
            @payment = FinanceVoucherInfo.where("state = 'new' AND DATE_FORMAT(created_at, '%Y%m') = DATE_FORMAT(CURDATE() , '%Y%m')").paginate(:page => params[:page], :per_page => 20)
        end
    end

    def sell_payment_notice_list
        @dollar_rate = SetupFinanceInfo.find_by_id(1).dollar_rate
        @payment = PaymentNoticeInfo.where(state: "new").paginate(:page => params[:page], :per_page => 20)
    end

    def edit_payment_notice
        @dollar_rate = SetupFinanceInfo.find_by_id(1).dollar_rate
        if params[:commit] == "审批通过"
            @payment_date = PaymentNoticeInfo.find_by_id(params[:payment_id_set])
            if not @payment_date.blank?
                @payment_date.state = "checking"
                if @payment_date.save
                    get_pi_item = PiItem.find_by_id(@payment_date.pi_item_id)
                    get_pi_item.finance_state = "check"
                    get_pi_item.state = "check"
                    get_pi_item.save
                end 
            end
            redirect_to :back and return
        end
        @payment_date = PaymentNoticeInfo.find_by_id(params[:payment_id])
        if not @payment_date.blank?
            @payment_date.pay_p = params[:pay_p]
            @payment_date.pay_type = params[:pay_type] 
            @payment_date.pay_account_name = params[:pay_account_name] 
            @payment_date.pay_account_number = params[:pay_account_number]
            @payment_date.pay_swift_code = params[:pay_swift_code]
            @payment_date.pay_bank_name = params[:pay_bank_name]
            @payment_date.remark = params[:remark]
            @payment_date.pay_att = params[:pay_att]
            @payment_date.save
        end
    end

    def new_payment_notice
        @dollar_rate = SetupFinanceInfo.find_by_id(1).dollar_rate
        if not params[:pi_info_id].blank?
            get_pi_info_data = PiInfo.find_by_id(params[:pi_info_id])
            shou_kuan_jin_e_data = PaymentNoticeInfo.find_by_sql("SELECT SUM(pay_p) AS pay_all FROM payment_notice_infos WHERE pi_info_id = '#{params[:pi_info_id]}'")
            if not shou_kuan_jin_e_data.blank?
                @shou_kuan_jin_e = shou_kuan_jin_e_data.first.pay_all
            else 
                @shou_kuan_jin_e = 0
            end
            pay_all = params[:pay_p].to_f + @shou_kuan_jin_e.to_f
            if pay_all > get_pi_info_data.t_p
                redirect_to :back, :flash => {:error => "保存失败，收款金额总和不能大于PI总金额！！！"} and return false
            end
            new_payment_notice = PaymentNoticeInfo.new
            new_payment_notice.state = "new"
            new_payment_notice.pi_info_id = params[:pi_info_id]
            new_payment_notice.pi_item_id = params[:pi_item_id]
            new_payment_notice.c_id = params[:c_id]
            new_payment_notice.pi_info_no = get_pi_info_data.pi_no
            new_payment_notice.pi_date = get_pi_info_data.created_at
            new_payment_notice.c_code = get_pi_info_data.c_code
            new_payment_notice.c_des = get_pi_info_data.c_des
            new_payment_notice.c_country = get_pi_info_data.c_country
            new_payment_notice.currency_type = params[:currency_type]
            new_payment_notice.exchange_rate = params[:exchange_rate]
            new_payment_notice.pi_t_p = get_pi_info_data.t_p
            #new_payment_notice.unreceived_p = params[:unreceived_p]
            new_payment_notice.pay_att = params[:pay_att]

            new_payment_notice.pay_p = params[:pay_p]

            new_payment_notice.pay_type = params[:pay_type]
            new_payment_notice.pay_account_name = params[:pay_account_name]
            new_payment_notice.pay_account_number = params[:pay_account_number]
            new_payment_notice.pay_swift_code = params[:pay_swift_code]
            new_payment_notice.pay_bank_name = params[:pay_bank_name]
            new_payment_notice.remark = params[:remark]
            new_payment_notice.sell_id = current_user.id
            new_payment_notice.sell_full_name_new = current_user.full_name
            new_payment_notice.sell_team = current_user.team
            new_payment_notice.save
        end
        redirect_to :back
    end


    def pi_list
        if params[:key_order]
            @pilist = PiInfo.where("(c_code LIKE '%#{params[:key_order]}%' OR c_des LIKE '%#{params[:key_order]}%' OR p_name LIKE '%#{params[:key_order]}%' OR des_cn LIKE '%#{params[:key_order]}%' OR des_en LIKE '%#{params[:key_order]}%' OR pi_no LIKE '%#{params[:key_order]}%' OR remark LIKE '%#{params[:key_order]}%' OR follow_remark LIKE '%#{params[:key_order]}%') AND state <> 'new' AND pi_sell = '#{current_user.email}'").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
        else
            if params[:bom_chk]
                if can? :work_e, :all
                    #@pilist = PiItem.where(state: "check",pi_sell: current_user.email).order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                    @pilist = PiItem.find_by_sql("SELECT pi_infos.follow_remark,pi_infos.pi_sell,pi_infos.pcb_customer_id,pi_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.id = pi_items.pi_info_id WHERE pi_items.state = 'check' AND pi_infos.pi_sell = '#{current_user.email}' AND pi_items.bom_state = 'check' ORDER BY updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    #@pilist = PiInfo.where(state: "check",bom_state: nil).order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                    @pilist = PiItem.find_by_sql("SELECT pi_infos.follow_remark,pi_infos.pi_sell,pi_infos.pcb_customer_id,pi_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.id = pi_items.pi_info_id WHERE pi_items.state = 'check' AND pi_items.bom_state = 'check' ORDER BY updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                end
                render "pi_list_eng.html.erb" and return
            elsif params[:buy_chk]
                if can? :work_e, :all
                    #@pilist = PiItem.where(state: "check",pi_sell: current_user.email).order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                    @pilist = PiItem.find_by_sql("SELECT pi_infos.follow_remark,pi_infos.pi_sell,pi_infos.pcb_customer_id,pi_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.id = pi_items.pi_info_id WHERE pi_items.state = 'check' AND pi_infos.pi_sell = '#{current_user.email}' AND pi_items.buy_state = 'check' ORDER BY updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    #@pilist = PiInfo.where(state: "check",bom_state: nil).order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                    @pilist = PiItem.find_by_sql("SELECT pi_infos.follow_remark,pi_infos.pi_sell,pi_infos.pcb_customer_id,pi_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.id = pi_items.pi_info_id WHERE pi_items.state = 'check' AND pi_items.buy_state = 'check' ORDER BY updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                end
                render "pi_list_eng.html.erb" and return
            elsif params[:finance_chk]
                @pilist = PiItem.find_by_sql("SELECT pi_infos.follow_remark,pi_infos.pi_sell,pi_infos.pcb_customer_id,pi_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.id = pi_items.pi_info_id WHERE pi_items.state = 'check' AND pi_items.finance_state = 'check' ORDER BY updated_at DESC").paginate(:page => params[:page], :per_page => 20)
=begin
                if can? :work_admin, :all
                    @pilist = PiItem.find_by_sql("SELECT pi_infos.follow_remark,pi_infos.pi_sell,pi_infos.pcb_customer_id,pi_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.id = pi_items.pi_info_id WHERE pi_items.state = 'check' AND pi_items.finance_state = 'check' ORDER BY updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                elsif can? :work_e, :all 
                    @pilist = PiItem.find_by_sql("SELECT pi_infos.follow_remark,pi_infos.pi_sell,pi_infos.pcb_customer_id,pi_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.id = pi_items.pi_info_id WHERE pi_items.state = 'check' AND pi_infos.pi_sell = '#{current_user.email}' AND pi_items.finance_state = 'check' ORDER BY updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                    
                end
=end
                render "pi_list_eng.html.erb" and return     
            elsif params[:checked]
                if can? :work_e, :all
                    @pilist = PiInfo.where(state: "checked",bom_state: "checked",finance_state: "checked",pi_sell: current_user.email).order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    @pilist = PiInfo.where(state: "checked",bom_state: "checked",finance_state: "checked").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                end
                if can? :work_e, :all
                    @pilist = PiItem.find_by_sql("SELECT pi_infos.follow_remark,pi_infos.pi_sell,pi_infos.pcb_customer_id,pi_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.id = pi_items.pi_info_id WHERE pi_items.state = 'check' AND pi_infos.pi_sell = '#{current_user.email}' AND pi_items.finance_state = 'checked' AND pi_items.bom_state = 'checked' ORDER BY updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    @pilist = PiItem.find_by_sql("SELECT pi_infos.follow_remark,pi_infos.pi_sell,pi_infos.pcb_customer_id,pi_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.id = pi_items.pi_info_id WHERE pi_items.state = 'check' AND pi_items.finance_state = 'checked' AND pi_items.bom_state = 'checked' ORDER BY updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                end
                render "pi_list_paymanet_notice.html.erb" and return
            else
                Rails.logger.info("add-------------------------------------12")
=begin
                if can? :work_e, :all
                    @pilist = PiInfo.find_by_sql("SELECT pi_infos.*, pi_infos.id AS pi_info_id FROM pi_infos WHERE state <> 'new' AND pi_sell = '#{current_user.email}' ORDER BY 'updated_at DESC'").paginate(:page => params[:page], :per_page => 20)
                else
                    @pilist = PiInfo.find_by_sql("SELECT pi_infos.*, pi_infos.id AS pi_info_id FROM pi_infos WHERE state <> 'new' ORDER BY 'updated_at DESC'").paginate(:page => params[:page], :per_page => 20)
                end
=end
                
                
                if can? :work_admin, :all
                    @pilist = PiItem.find_by_sql("SELECT pi_infos.follow_remark,pi_infos.pi_sell,pi_infos.pcb_customer_id,pi_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.id = pi_items.pi_info_id ORDER BY updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                elsif can? :work_e, :all
                    @pilist = PiItem.find_by_sql("SELECT pi_infos.follow_remark,pi_infos.pi_sell,pi_infos.pcb_customer_id,pi_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.id = pi_items.pi_info_id WHERE pi_infos.pi_sell = '#{current_user.email}' ORDER BY updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    @pilist = PiItem.find_by_sql("SELECT pi_infos.follow_remark,pi_infos.pi_sell,pi_infos.pcb_customer_id,pi_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.id = pi_items.pi_info_id ORDER BY updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                end
            end
        end        
    end

    def edit_pcb_pi
        @dollar_rate = SetupFinanceInfo.find_by_id(1).dollar_rate
        @pi_info = PiInfo.find_by_id(params[:pi_info_id])
        if not @pi_info.bank_info_id.blank?
            @bank_info = BankInfo.find_by_id(@pi_info.bank_info_id)
        end
        @pi_info_c = PcbCustomer.find_by_id(@pi_info.pcb_customer_id)
        @pi_info_c_c_no = ""
        @pi_info_c_customer = ""
        @pi_info_c_customer_com = ""
        @pi_info_c_customer_country = ""
        @pi_info_c_tel = ""
        @pi_info_c_fax = ""
        @pi_info_c_email = ""
        @pi_info_c_shipping_address = ""
        if not @pi_info_c.blank?
            @pi_info_c_c_no = @pi_info_c.c_no
            @pi_info_c_customer = @pi_info_c.customer
            @pi_info_c_customer_com = @pi_info_c.customer_com
            @pi_info_c_customer_country = @pi_info_c.customer_country
            @pi_info_c_tel = @pi_info_c.tel
            @pi_info_c_fax = @pi_info_c.fax
            @pi_info_c_email = @pi_info_c.email
            @pi_info_c_shipping_address = @pi_info_c.shipping_address
        end
        @pi_item = PiItem.where(pi_info_id: params[:pi_info_id])
        @pi_item_bom = PiItem.where(pi_info_id: params[:pi_info_id],state: "check")
        @pi_other_item = PiOtherItem.where(pi_info_id: params[:pi_info_id])
        @total_p = PiItem.where(pi_info_id: params[:pi_info_id]).sum("t_p") + PiOtherItem.where(pi_info_id: params[:pi_info_id]).sum("t_p")


        if not params[:pi_item_id].blank?
            pi_item = PiItem.find_by_id(params[:pi_item_id])
            @pi_item_data = pi_item 
            q_order_item = PcbOrderItem.find_by_id(pi_item.order_item_id)


            
            @q_order = PcbOrder.find_by_id(q_order_item.pcb_order_id)
            @q_order_sell_item = PcbOrderSellItem.find_by_id(q_order_item.pcb_order_sell_item_id)


            @state = pi_item.state
            @to_pmc_state = pi_item.to_pmc_state
            @boms = ProcurementBom.find_by_id(pi_item.bom_id)
            #@bom_item = PItem.where(procurement_bom_id: @boms.id)
            @bom_item = PItem.find_by_sql("SELECT p_items.*, pi_bom_qty_info_items.id AS pi_item_qty, pi_bom_qty_info_items.bom_ctl_qty, pi_bom_qty_info_items.customer_qty, pi_bom_qty_info_items.lock_state FROM p_items INNER JOIN pi_bom_qty_info_items ON p_items.id = pi_bom_qty_info_items.p_item_id WHERE p_items.procurement_bom_id = '#{@boms.id}' AND pi_bom_qty_info_items.pi_item_id = '#{params[:pi_item_id]}'")
            @pi_bom_qty_info = PiBomQtyInfo.find_by_pi_item_id(params[:pi_item_id])
            if not @bom_item.blank?
                @bom_item = @bom_item.select {|item| item.quantity != 0 }
            end
            Rails.logger.info("add-------------------------------------12")
            Rails.logger.info(@boms.inspect)
            Rails.logger.info("add-------------------------------------12")
            if can? :work_e, :all 
                if not params[:pi_info_id].blank? 
                    @shou_kuan_tong_zhi_dan_list = PaymentNoticeInfo.where(pi_info_id: params[:pi_info_id])
                    shou_kuan_jin_e_data = PaymentNoticeInfo.find_by_sql("SELECT SUM(pay_p) AS pay_all FROM payment_notice_infos WHERE pi_info_id = '#{params[:pi_info_id]}'")
                    if not shou_kuan_jin_e_data.blank?
                        @shou_kuan_jin_e = shou_kuan_jin_e_data.first.pay_all
                        Rails.logger.info("@shou_kuan_jin_e-------------------------")
                        Rails.logger.info(@shou_kuan_jin_e.to_i.inspect)  
                        Rails.logger.info(@pi_info.t_p.to_i.inspect)
                        Rails.logger.info("@shou_kuan_jin_e----------------------------------")
                    else
                        @shou_kuan_jin_e = 0
                    end
                end
                @baojia = @bom_item
                render "sell_view_baojia.html.erb" and return
            end
            if can? :work_d, :all
                #render "procurement/p_viewbom.html.erb" and return
                redirect_to p_viewbom_path(pi_info_id: params[:pi_info_id],pi_item_id: params[:pi_item_id],add_bom: "add_bom", bom_id: pi_item.bom_id, state_flow: "order_center") and return
            end
            if can? :work_finance, :all or can? :work_g, :all
                @all_dn = "[&quot;"
                all_s_dn = AllDn.find_by_sql("SELECT DISTINCT all_dns.dn FROM all_dns GROUP BY all_dns.dn")
                all_s_dn.each do |dn|
                    @all_dn += "&quot;,&quot;" + dn.dn.to_s
                end
                @all_dn += "&quot;]"
                render "procurement/p_viewbom.html.erb" and return
            end

        end
    end

    def edit_moko_supplier
        if can? :work_admin, :all
            if not params[:supplier_id].blank?
                new_su = SupplierList.find_by_id(params[:supplier_id])
                if not new_su.blank?
                    if not params[:supplier_name].blank?
                        new_su.supplier_name = params[:supplier_name].strip
                    end
                    if not params[:supplier_code].blank?
                        new_su.supplier_code = params[:supplier_code].strip
                    end
                    if not params[:supplier_part_type_code].blank?
                        new_su.supplier_part_type_code = params[:supplier_part_type_code].strip
                    end
                    if not params[:supplier_part_type].blank?
                        new_su.supplier_part_type = params[:supplier_part_type].strip
                    end
                    if not params[:supplier_tax].blank?
                        new_su.supplier_tax = params[:supplier_tax].strip
                    end
                    if not params[:supplier_clearing].blank?
                        new_su.supplier_clearing = params[:supplier_clearing].strip
                    end
                    if not params[:supplier_remark].blank?
                        new_su.supplier_remark = params[:supplier_remark].strip
                    end
                    if not params[:supplier_name_long].blank?
                        new_su.supplier_name_long = params[:supplier_name_long].strip
                    end
                    if not params[:supplier_label].blank?
                        new_su.supplier_label = params[:supplier_label].strip
                    end
                    if not params[:supplier_type].blank?
                        new_su.supplier_type = params[:supplier_type].strip
                    end
                    if not params[:supplier_address].blank?
                        new_su.supplier_address = params[:supplier_address].strip
                    end
                    if not params[:supplier_invoice_fullname].blank?
                        new_su.supplier_invoice_fullname = params[:supplier_invoice_fullname].strip
                    end
                    if not params[:supplier_contacts].blank?
                        new_su.supplier_contacts = params[:supplier_contacts].strip
                    end
                    if not params[:supplier_phone].blank?
                        new_su.supplier_phone = params[:supplier_phone].strip
                    end
                    if not params[:supplier_qq].blank?
                        new_su.supplier_qq = params[:supplier_qq].strip
                    end
                    new_su.save
                end
            end
        end
        redirect_to :back
    end

    def new_moko_supplier
        if can? :work_admin, :all
            new_su = SupplierList.new
            if not params[:supplier_name].blank?
                new_su.supplier_name = params[:supplier_name].strip
            end
            if not params[:supplier_code].blank?
                new_su.supplier_code = params[:supplier_code].strip
            end
            if not params[:supplier_part_type_code].blank?
                new_su.supplier_part_type_code = params[:supplier_part_type_code].strip
            end
            if not params[:supplier_part_type].blank?
                new_su.supplier_part_type = params[:supplier_part_type].strip
            end
            if not params[:supplier_tax].blank?
                new_su.supplier_tax = params[:supplier_tax].strip
            end
            if not params[:supplier_clearing].blank?
                new_su.supplier_clearing = params[:supplier_clearing].strip
            end
            if not params[:supplier_remark].blank?
                new_su.supplier_remark = params[:supplier_remark].strip
            end
            if not params[:supplier_name_long].blank?
                new_su.supplier_name_long = params[:supplier_name_long].strip
            end
            if not params[:supplier_label].blank?
                new_su.supplier_label = params[:supplier_label].strip
            end
            if not params[:supplier_type].blank?
                new_su.supplier_type = params[:supplier_type].strip
            end
            if not params[:supplier_address].blank?
                new_su.supplier_address = params[:supplier_address].strip
            end
            if not params[:supplier_invoice_fullname].blank?
                new_su.supplier_invoice_fullname = params[:supplier_invoice_fullname].strip
            end
            if not params[:supplier_contacts].blank?
                new_su.supplier_contacts = params[:supplier_contacts].strip
            end
            if not params[:supplier_phone].blank?
                new_su.supplier_phone = params[:supplier_phone].strip
            end
            if not params[:supplier_qq].blank?
                new_su.supplier_qq = params[:supplier_qq].strip
            end
            new_su.save
        end
        redirect_to :back
    end

    def moko_supplier_list
        @supplier=SupplierList.all
    end

    def edit_orderinfo
        if params[:hint] == ""
           hint = 1
        else
           hint = params[:hint]
        end
        order_info = ProcurementBom.where(p_name_mom: params[:itemp_id]).update_all "order_country = '#{params[:order_country]}', star = '#{hint}', sell_remark = '#{Time.new().localtime.strftime('%y-%m-%d')} #{params[:sell_remark]}', sell_manager_remark = '#{params[:sell_manager_remark]}'"
        if not params[:order_country].blank?
            a = ProcurementBom.find_by(p_name_mom: params[:itemp_id])
            if not a.erp_item_id.blank?
                b = PcbOrderItem.find_by_id(a.erp_item_id)
                if not b.pcb_order_id.blank?
                    c = PcbOrder.find_by_id(b.pcb_order_id)
                    c.c_country = params[:order_country]
                    c.save
                end
            end       
        end
        if params[:sell_remark] != ""
            open_id = "6ab2628d9a320296032f6a6f5495582b,5c1c9ba5ef315dcaac48cb9c1fb9731a"
            Rails.logger.info("oauth-------------------------")
            Rails.logger.info(open_id.inspect)   
            Rails.logger.info("oauth----------------------------------")
            oauth = Oauth.find(1)
            company_id = oauth.company_id
            company_token = oauth.company_token
            url = 'https://openapi.b.qq.com/api/tips/send'
            if not open_id.blank? 
                url += '?company_id='+company_id
                url += '&company_token='+company_token
                url += '&app_id=200710667'
                url += '&client_ip=120.25.151.208'
                url += '&oauth_version=2'
                url += '&to_all=0'  
                url += '&receivers='+open_id
                url += '&window_title=Fastbom-PCB AND PCBA'
                url += '&tips_title='+URI.encode('黄朝锐宝宝，马凤华宝宝，'+current_user.full_name+'宝宝回复了你们的报价请查看')
                url += '&tips_content='+URI.encode('有新的回复，点击查看。')
                url += '&tips_url=erp.fastbom.com/p_bomlist?key_order='+params[:itemp_id].to_s 
                resp = Net::HTTP.get_response(URI(url))
            end 
        end

        redirect_to :back 
    end

    def edit_orderinfo_erp
        if params[:hint] == ""
           hint = 1
        else
           hint = params[:hint]
        end

        pcb_order = PcbOrder.find_by_id(params[:itemp_id])
        pcb_order.c_country = params[:order_country]
        pcb_order.star = hint
        if params[:sell_remark] != ""
            pcb_order.remark = params[:sell_remark]
            pcb_order.remark_at = Time.new()
        end
        if not params[:sell_manager_remark].blank?
            pcb_order.manager_remark = params[:sell_manager_remark]
            pcb_order.manager_remark_at = Time.new()
        end
        if pcb_order.save
            order_info = ProcurementBom.where(p_name_mom: pcb_order.order_no).update_all "order_country = '#{params[:order_country]}', star = '#{hint}', sell_remark = '#{params[:sell_remark]}', sell_manager_remark = '#{params[:sell_manager_remark]}'"
        end
        redirect_to :back 
    end

    def sell_baojia_erp
        where_order_no = ""
        if not params[:order_no].blank?
             where_order_no = " AND pcb_orders.order_no LIKE '%#{params[:order_no]}%'"
        end
        where_sell = ""
        if not params[:sell].blank?
            where_sell = " AND pcb_orders.order_sell = '#{params[:sell]}'"
        end
        where_date = ""
        where_5star = ""
        if not params[:order_state].blank?
            if params[:order_state] == "all"
                where_5star = ""
            elsif params[:order_state] == "done"
                where_5star = "  pcb_orders.star = 5 AND"
            elsif params[:order_state] == "undone"
                where_5star = "  pcb_orders.star < 5 AND"  
            end
        end
        if params[:start_date] != "" and  params[:start_date] != nil
                where_date += "pcb_orders.created_at > '#{params[:start_date]}'"
        end
        if params[:end_date] != "" and  params[:end_date] != nil
                where_date += " AND pcb_orders.created_at < '#{params[:end_date]}' AND"
        end
        Rails.logger.info(current_user.s_name)
        if not current_user.s_name.blank?
            if current_user.s_name.split(",").size == 1
                Rails.logger.info("sell-------------------------1")
                @quate = PcbOrder.where("#{where_date + where_5star}  pcb_orders.state <> 'new' AND pcb_orders.order_sell = '#{current_user.email}'#{where_order_no} AND pcb_orders.del_flag = 'active'").order("pcb_orders.created_at DESC").paginate(:page => params[:page], :per_page => 20)
            else 
                if can? :work_admin, :all
                    Rails.logger.info("sell-------------------------2")
                    @quate = PcbOrder.find_by_sql("SELECT pcb_orders.* FROM pcb_orders  WHERE #{where_date + where_5star}  pcb_orders.state <> 'new'#{where_sell}#{where_order_no}  AND pcb_orders.del_flag = 'active' ORDER BY pcb_orders.created_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    Rails.logger.info("sell-------------------------3")
                    @quate = PcbOrder.find_by_sql("SELECT pcb_orders.* FROM pcb_orders JOIN users ON pcb_orders.order_sell = users.email WHERE #{where_date + where_5star}  pcb_orders.state <> 'new' AND users.team = '#{current_user.team}'#{where_sell}#{where_order_no}  AND pcb_orders.del_flag = 'active' ORDER BY pcb_orders.created_at DESC").paginate(:page => params[:page], :per_page => 20)
                end
            end
        else
            Rails.logger.info("sell-------------------------999")
        end
    end

    def sell_baojia
        where_p = ""
        where_date = ""
        where_5star = ""
        if params[:complete]
            where_5star = " AND procurement_boms.star = 5"
        else
            where_5star = " AND (procurement_boms.star <> 5 OR procurement_boms.star IS NULL)"
        end
        if not current_user.s_name.blank?
            if current_user.s_name.size == 1
                s_name = current_user.s_name
               
                #where_p = " POSITION('" + s_name + "' IN RIGHT(LEFT(procurement_boms.p_name_mom,9),7)) = 6 and RIGHT(LEFT(procurement_boms.p_name_mom,9),1) REGEXP '^[0-9]+$' "
                where_p = " ((POSITION('" + s_name + "' IN RIGHT(LEFT(procurement_boms.p_name_mom,9),7)) = 6 and RIGHT(LEFT(procurement_boms.p_name_mom,9),1) REGEXP '^[0-9]+$') or (POSITION('" + s_name + "' IN RIGHT(LEFT(procurement_boms.p_name_mom,9),7)) = 7 and RIGHT(LEFT(procurement_boms.p_name_mom,10),1) REGEXP '^[0-9]+$' and RIGHT(LEFT(procurement_boms.p_name_mom,8),1) REGEXP '^[0-9]+$'))"
                
            elsif current_user.s_name.size == 2
                s_name = current_user.s_name
               
                #where_p = "  POSITION('" + s_name + "' IN procurement_boms.p_name_mom) = 8 "
                where_p = "  (POSITION('" + s_name + "' IN procurement_boms.p_name_mom) = 8 or POSITION('" + s_name + "' IN procurement_boms.p_name_mom) = 9)  "
            elsif current_user.s_name.size > 2
                if params[:sell] == "" or params[:sell] == nil
                    where_p = "("
                    current_user.s_name.split(",").each_with_index do |item,index|
                        s_name = item
                        if s_name.size == 1
                            if current_user.s_name.split(",").size > (index+1)
                                where_p += "  (LOCATE('" + s_name + "', procurement_boms.p_name_mom,3) = 8 AND RIGHT(LEFT(procurement_boms.p_name_mom,9),1) REGEXP '^[0-9]+$') OR"
                                where_p += "  (LOCATE('" + s_name + "', procurement_boms.p_name_mom,3) = 9 AND RIGHT(LEFT(procurement_boms.p_name_mom,8),1) REGEXP '^[0-9]+$') OR"
                            else
                                where_p += "  (LOCATE('" + s_name + "', procurement_boms.p_name_mom,3) = 9 AND RIGHT(LEFT(procurement_boms.p_name_mom,8),1) REGEXP '^[0-9]+$') OR"
                                where_p += "  (LOCATE('" + s_name + "', procurement_boms.p_name_mom,3) = 8 AND RIGHT(LEFT(procurement_boms.p_name_mom,9),1) REGEXP '^[0-9]+$'))"
                            end
                        elsif s_name.size == 2
                            if current_user.s_name.split(",").size > (index+1)
                                where_p += "  (LOCATE('" + s_name + "', procurement_boms.p_name_mom,3) = 8 AND RIGHT(LEFT(procurement_boms.p_name_mom,10),1) REGEXP '^[0-9]+$') OR"
                                where_p += "  (LOCATE('" + s_name + "', procurement_boms.p_name_mom,3) = 9 AND RIGHT(LEFT(procurement_boms.p_name_mom,8),1) REGEXP '^[0-9]+$') OR"
                            else
                                where_p += "  (LOCATE('" + s_name + "', procurement_boms.p_name_mom,3) = 9 AND RIGHT(LEFT(procurement_boms.p_name_mom,8),1) REGEXP '^[0-9]+$') OR"
                                where_p += "  (LOCATE('" + s_name + "', procurement_boms.p_name_mom,3) = 8 AND RIGHT(LEFT(procurement_boms.p_name_mom,10),1) REGEXP '^[0-9]+$'))"
                            end
                        end
                    end
                else
                    if params[:sell].size == 1
                        s_name = params[:sell]
               
                        #where_p = " POSITION('" + s_name + "' IN RIGHT(LEFT(procurement_boms.p_name_mom,9),7)) = 6 and RIGHT(LEFT(procurement_boms.p_name_mom,9),1) REGEXP '^[0-9]+$' "
                        where_p = " ((POSITION('" + s_name + "' IN RIGHT(LEFT(procurement_boms.p_name_mom,9),7)) = 6 and RIGHT(LEFT(procurement_boms.p_name_mom,9),1) REGEXP '^[0-9]+$') or (POSITION('" + s_name + "' IN RIGHT(LEFT(procurement_boms.p_name_mom,9),7)) = 7 and RIGHT(LEFT(procurement_boms.p_name_mom,10),1) REGEXP '^[0-9]+$' and RIGHT(LEFT(procurement_boms.p_name_mom,8),1) REGEXP '^[0-9]+$'))"
                    elsif params[:sell].size == 2
                        s_name = params[:sell]
               
                        #where_p = "  POSITION('" + s_name + "' IN procurement_boms.p_name_mom) = 8 "
                        where_p = "  (POSITION('" + s_name + "' IN procurement_boms.p_name_mom) = 8 or POSITION('" + s_name + "' IN procurement_boms.p_name_mom) = 9)  "
                    end
                end
            end
            if params[:start_date] != "" and  params[:start_date] != nil
                where_date += " AND procurement_boms.created_at > '#{params[:start_date]}'"
            end
            if params[:end_date] != "" and  params[:end_date] != nil
                where_date += " AND procurement_boms.created_at < '#{params[:end_date]}'"
            end
            @quate = ProcurementBom.find_by_sql("SELECT *,SUM(procurement_boms.t_p) AS sum_t_p FROM `procurement_boms` WHERE #{where_p + where_date + where_5star}  GROUP BY procurement_boms.p_name_mom ORDER BY created_at DESC").paginate(:page => params[:page], :per_page => 10)
        else
            if params[:start_date] != "" and  params[:start_date] != nil
                where_date += " procurement_boms.created_at > '#{params[:start_date]}'"
            end
            if params[:end_date] != "" and  params[:start_date] != nil
                where_date += " AND procurement_boms.created_at < '#{params[:end_date]}'"
            end
            if where_date != ""
                @quate = ProcurementBom.find_by_sql("SELECT *,SUM(procurement_boms.t_p) AS sum_t_p FROM `procurement_boms` WHERE #{where_date + where_5star}  GROUP BY procurement_boms.p_name_mom ORDER BY created_at DESC").paginate(:page => params[:page], :per_page => 10)
            else
                if params[:complete]
                    @quate = ProcurementBom.find_by_sql("SELECT *,SUM(procurement_boms.t_p) AS sum_t_p FROM `procurement_boms` WHERE procurement_boms.star = 5   GROUP BY procurement_boms.p_name_mom ORDER BY created_at DESC").paginate(:page => params[:page], :per_page => 10)
                else
                    @quate = ProcurementBom.find_by_sql("SELECT *,SUM(procurement_boms.t_p) AS sum_t_p FROM `procurement_boms`   GROUP BY procurement_boms.p_name_mom ORDER BY created_at DESC").paginate(:page => params[:page], :per_page => 10)
                end
            end
        end
        
        #@quate = ProcurementBom.find_by_sql("SELECT * FROM `procurement_boms` WHERE #{where_p + where_date}  ").paginate(:page => params[:page], :per_page => 10)
    end

    def edit_pmc_add_buy_user
        if can? :work_d, :all or can? :work_admin, :all 
            if not params[:item_id].blank?
                get_item_data = PiPmcAddItem.find_by_id(params[:item_id])
                if not get_item_data.blank?
                    if get_item_data.state == "new"
                        get_item_data.buy_user = params[:buy_user]
                        get_item_data.moko_part = params[:moko_part]
                        get_item_data.moko_des = params[:moko_des]
                        get_item_data.pmc_qty = params[:pmc_qty]
                        get_item_data.remark = params[:remark]
                        get_item_data.save
                    end
                end
            end
        end
        redirect_to :back
    end

    def del_add_pmc_add_item
        if can? :work_a, :all or can? :work_admin, :all
            get_data = PiPmcAddItem.find_by_id(params[:id])
            if not get_data.blank?
                get_data.destroy
            end
        end
        redirect_to :back
    end
    
    def send_to_pi_pmc_item
        if can? :work_a, :all or can? :work_admin, :all
            get_data = PiPmcAddItem.where(state: "new",pi_pmc_add_info_id: params[:pi_pmc_add_info_id])
            if not get_data.blank?
                get_data.each do |item|
                    new_pmc_item = PiPmcItem.new
                    new_pmc_item.pmc_flag = "pmc"
                    new_pmc_item.state = "pass"
                    new_pmc_item.pass_at = Time.new
                    new_pmc_item.erp_no = item.pi_pmc_add_info_no
                    new_pmc_item.erp_no_son = item.pi_pmc_add_info_no
                    new_pmc_item.moko_part = item.moko_part
                    new_pmc_item.moko_des = item.moko_des
                    new_pmc_item.qty = item.pmc_qty
                    new_pmc_item.pmc_qty = item.pmc_qty
                    new_pmc_item.qty_in = item.pmc_qty
                    new_pmc_item.remark = item.remark
                    new_pmc_item.buy_user = item.buy_user
                    new_pmc_item.buy_qty = item.pmc_qty

                    if new_pmc_item.save
                        item.state = "done"
                        item.save
                        wh_data = WarehouseInfo.find_by_moko_part(item.moko_part)
                        if not wh_data.blank?
                            wh_data.temp_buy_qty = wh_data.temp_buy_qty + item.pmc_qty
                            wh_data.true_buy_qty = wh_data.true_buy_qty + item.pmc_qty
                            wh_data.save
                        end
                    end
                end
            end
        end
        redirect_to :back
    end

    def add_pmc_add_item
        if params[:add_pmc_add_item]
            all_order = params[:add_pmc_add_item].split("\r\n");
            all_order.each do |item|
                pmc_add = item.split(" ")
                if pmc_add.size == 2
                    pmc_add_item = PiPmcAddItem.new
                    pmc_add_item.state = "new"
                    pmc_add_item.pi_pmc_add_info_id = params[:pi_pmc_add_info_id]
                    pmc_add_item.pi_pmc_add_info_no = params[:pi_pmc_add_info_no]
                    pmc_add_item.moko_part = pmc_add[0]
                    pmc_add_item.moko_des = Product.find_by_name(pmc_add[0]).description
                    pmc_add_item.pmc_qty = pmc_add[1]
                    package1 = Product.find_by_name(pmc_add[0]).package1
                    if package1 == "D" or package1 == "Q"
                        pmc_add_item.buy_user = "A"
                    elsif package1 == "PZ"
                        pmc_add_item.buy_user = "B"
                    else 
                        pmc_add_item.buy_user = "NULL"
                    end
                    pmc_add_item.save
                else
                    redirect_to edit_pmc_add_order_path(pi_pmc_add_info_id: params[:pi_pmc_add_info_id]), :flash => {:error => item+"--------数据上传失败，请检查上传数据格式！"}
                    return false
                end
            end
        end
        redirect_to edit_pmc_add_order_path(pi_pmc_add_info_id: params[:pi_pmc_add_info_id]) and return 
    end

    def pmc_add_list
        @pmc_add_list = PiPmcAddInfo.where(state: "new").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
    end

    def new_pmc_add_order
        if params[:pi_pmc_add_info_no] == "" or params[:pi_pmc_add_info_no] == nil
            if PiPmcAddInfo.find_by_sql('SELECT no FROM pi_pmc_add_infos WHERE to_days(pi_pmc_add_infos.created_at) = to_days(NOW())').blank?
                pi_n =1
            else
                pi_n = PiPmcAddInfo.find_by_sql('SELECT no FROM pi_pmc_add_infos WHERE to_days(pi_pmc_add_infos.created_at) = to_days(NOW())').last.no.split("PMC")[-1].to_i + 1
            end
            @pi_pmc_add_info_no = "MO"+ Time.new.strftime('%y').to_s + Time.new.strftime('%m%d').to_s + "PMC"+ pi_n.to_s
            pi_pmc_add_info = PiPmcAddInfo.new()
            pi_pmc_add_info.no = @pi_pmc_add_info_no
            pi_pmc_add_info.user = current_user.email
            pi_pmc_add_info.state = "new"
            pi_pmc_add_info.save
            pi_pmc_add_info_id = pi_pmc_add_info.id
        else
            pi_pmc_add_info_id = params[:pi_pmc_add_info_id]
        end
        redirect_to edit_pmc_add_order_path(pi_pmc_add_info_id: pi_pmc_add_info_id) and return 
    end

    def edit_pmc_add_order
        @get_info = PiPmcAddInfo.find_by_id(params[:pi_pmc_add_info_id])
        @get_item = PiPmcAddItem.where(pi_pmc_add_info_id: params[:pi_pmc_add_info_id])
    end

    def edit_buy_user
        if can? :work_d, :all or can? :work_admin, :all or can? :work_a, :all
            if not params[:item_id].blank?
                get_item_data = PiPmcItem.find_by_id(params[:item_id])
                if not get_item_data.blank?
                    get_item_data.buy_user = params[:buy_user]
                    get_item_data.save
                end
            end
        end
        redirect_to :back
    end



    def wh_draft_change
        wh_order = PiWhChangeInfo.find_by_pi_wh_change_no(params[:wh_no])
        if not wh_order.blank?
            if wh_order.state == "new" or wh_order.state == "fail"
                wh_order.state = "checking"
                wh_order.save
            elsif wh_order.state == "checking"
                if params[:commit] == "PASS"
                    wh_order.state = "checked"
                elsif params[:commit] == "FAIL"
                    wh_order.state = "fail"
                end
                wh_order.save
            end
            if wh_order.state == "checked"
            #if wh_order.state == "new"
                wh_in_data = PiWhChangeItem.where(pi_wh_change_info_no: params[:wh_no])
                if not wh_in_data.blank?
                    wh_in_data.each do |wh_in|
                        wh_data = WarehouseInfo.find_by_moko_part(wh_in.moko_part)
                        if not wh_data.blank?
                            wh_data.wh_c_qty = wh_data.wh_c_qty + wh_in.qty_in
                            wh_data.wh_f_qty = wh_data.wh_f_qty - wh_in.qty_in
                            #wh_data.save
                        end
                        if wh_data.save
                            wh_in.state = "done"
                            wh_in.save
                        end
                    end
                    wh_order.state = "done"
                    wh_order.save
                end
            end            
        end
        redirect_to wh_draft_change_list_path()
    end

    def wh_material_flow

    end

    def add_wh_change_item
        pi_wh_change_info = PiWhChangeInfo.find_by_pi_wh_change_no(params[:pi_wh_change_no])
        wh_item = PiWhChangeItem.new
        @wh_data = WarehouseInfo.find_by_moko_part(params[:moko_part])
        wh_item.pi_wh_change_info_id = pi_wh_change_info.id
        wh_item.pi_wh_change_info_no = params[:pi_wh_change_no]
        wh_item.moko_part = params[:moko_part]
        wh_item.moko_des = @wh_data.moko_des
        wh_item.qty_in = params[:wh_qty_in]
        wh_item.save
        @wh_wait = ''
        wh_item_all = PiWhChangeItem.where(pi_wh_change_info_no: params[:pi_wh_change_no])
        if not wh_item_all.blank?
            wh_item_all.each do |item|
                @wh_wait += '<tr>'
                @wh_wait += '<td>'+item.moko_part.to_s+'</td>'
                @wh_wait += '<td>'+item.moko_des.to_s+'</td>'
                @wh_wait += '<td>'+item.qty_in.to_s+'</td>'
                @wh_wait += '<td><a class="glyphicon glyphicon-remove" href="/del_wh_change_item?del_wh_item_id='+item.id.to_s+'" data-confirm="确定要删除?"></a></td>'
                @wh_wait += '</tr>'
            end
        end
    end

    def add_wh_item
        pi_buy_item = PiBuyItem.find_by_id(params[:pi_buy_item_id])
        get_wh_info_data = PiWhInfo.find_by_id(params[:wh_order_id])
        get_wh_info_data.dn = pi_buy_item.dn
        get_wh_info_data.dn_long = pi_buy_item.dn_long
        get_wh_info_data.save

        wh_item = PiWhItem.new
        wh_item.dn_id = pi_buy_item.dn_id
        wh_item.dn = pi_buy_item.dn
        wh_item.dn_long = pi_buy_item.dn_long
        wh_item.supplier_list_id = pi_buy_item.supplier_list_id
        wh_item.pmc_flag = pi_buy_item.pmc_flag
        wh_item.pi_pmc_item_id = pi_buy_item.pi_pmc_item_id
        wh_item.buy_user = pi_buy_item.buy_user
        wh_item.pi_wh_info_no = params[:wh_order_no]
        wh_item.pi_wh_info_id = params[:wh_order_id]
        wh_item.pi_buy_item_id = params[:pi_buy_item_id]
        wh_item.moko_part = pi_buy_item.moko_part
        wh_item.moko_des = pi_buy_item.moko_des
        wh_item.qty_in = params[:wh_qty_in]
        wh_item.p_item_id = pi_buy_item.p_item_id
        wh_item.erp_id = pi_buy_item.erp_id
        wh_item.erp_no = pi_buy_item.erp_no
        wh_item.pi_buy_info_id = pi_buy_item.pi_buy_info_id
        wh_item.procurement_bom_id = pi_buy_item.procurement_bom_id
        if wh_item.save
            pi_buy_item.qty_wait = pi_buy_item.qty_wait + wh_item.qty_in
            pi_buy_item.save
            if (pi_buy_item.qty_wait + pi_buy_item.qty_done) >= pi_buy_item.buy_qty 
                pi_buy_item.state = "done"
                pi_buy_item.save
            end         
        end
        @wh_wait = ''
        wh_item_all = PiWhItem.where(pi_wh_info_no: params[:wh_order_no])
        if not wh_item_all.blank?
            wh_item_all.each do |item|
                @wh_wait += '<tr>'
                @wh_wait += '<td>'+PiBuyInfo.find_by_id(item.pi_buy_info_id).dn_long.to_s+'</td>'
                @wh_wait += '<td>'+PiBuyInfo.find_by_id(item.pi_buy_info_id).pi_buy_no.to_s+'</td>'
                @wh_wait += '<td>'+item.erp_no.to_s+'</td>'
                @wh_wait += '<td>'+item.moko_part.to_s+'</td>'
                @wh_wait += '<td>'+item.moko_des.to_s+'</td>'
                @wh_wait += '<td>'+item.qty_in.to_s+'</td>'
                @wh_wait += '<td><a class="glyphicon glyphicon-remove" href="/del_wh_item?del_wh_item_id='+item.id.to_s+'" data-confirm="确定要删除?"></a></td>'
                @wh_wait += '</tr>'
            end
        end
    end

    def del_wh_item
        del_wh_item = PiWhItem.find_by_id(params[:del_wh_item_id])
        pi_buy_item = PiBuyItem.find_by_id(del_wh_item.pi_buy_item_id)
        pi_buy_item.qty_wait = pi_buy_item.qty_wait - del_wh_item.qty_in
        if (pi_buy_item.qty_wait + pi_buy_item.qty_done) >= pi_buy_item.buy_qty 
            pi_buy_item.state = "done"
        else
            pi_buy_item.state = "buying"
        end
        if del_wh_item.destroy
            pi_buy_item.save
        end
        redirect_to :back
    end

    def edit_pi_buy  
        @pi_buy_find = PiInfo.find_by_sql("SELECT pi_infos.pi_no, pi_items.pi_no, p_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.pi_no = pi_items.pi_no INNER JOIN p_items ON pi_items.bom_id = p_items.procurement_bom_id WHERE pi_infos.state = 'checked' AND p_items.buy IS NULL")   
        @pi_buy_info = PiBuyInfo.find_by_pi_buy_no(params[:pi_buy_no])
        @pi_buy = PiBuyItem.where(pi_buy_info_id: @pi_buy_info.id).order("moko_part")
        @all_dn = "[&quot;"
        #all_s_dn = AllDn.find_by_sql("SELECT DISTINCT all_dns.dn, all_dns.dn_long FROM all_dns GROUP BY all_dns.dn")
        all_s_dn = SupplierList.find_by_sql("SELECT  supplier_name, supplier_name_long FROM supplier_lists ")
        all_s_dn.each do |dn|
            @all_dn += "&quot;,&quot;" + dn.supplier_name.to_s + "&#{dn.supplier_name_long.to_s}"
        end
        @all_dn += "&quot;]"
        if @pi_buy_info.state == "check"
            render "edit_pi_buy_check.html.erb" and return
        elsif @pi_buy_info.state == "checked"
            render "edit_pi_buy_checked.html.erb" and return
        end
    end

    def pi_buy_history
        @w_wh = PiBuyInfo.where(state: "buy")
    end

    def pi_buy_check_list
        #@w_wh = PiBuyInfo.where(state: "check")
        @w_wh = PiBuyInfo.find_by_sql("SELECT pi_buy_infos.*,SUM(pi_buy_items.buy_qty*pi_buy_items.cost) AS t_p_sum FROM pi_buy_infos LEFT JOIN pi_buy_items ON pi_buy_infos.id = pi_buy_items.pi_buy_info_id WHERE pi_buy_infos.state = 'check' OR pi_buy_infos.state = 'uncheck' GROUP BY pi_buy_infos.id").paginate(:page => params[:page], :per_page => 20)
    end

    def pi_buy_checked_list
        #@w_wh = PiBuyInfo.where(state: "checked")
        @w_wh = PiBuyInfo.find_by_sql("SELECT pi_buy_infos.*,SUM(pi_buy_items.buy_qty*pi_buy_items.cost) AS t_p_sum FROM pi_buy_infos LEFT JOIN pi_buy_items ON pi_buy_infos.id = pi_buy_items.pi_buy_info_id WHERE pi_buy_infos.state = 'checked' GROUP BY pi_buy_infos.id").paginate(:page => params[:page], :per_page => 20)
    end

    def send_pi_buy_check
        up_state = PiBuyInfo.find_by_pi_buy_no(params[:pi_buy_no])
        if not up_state.blank?
            
            up_state.state = "check"
            up_state.save
            PiBuyItem.where(pi_buy_info_id: up_state.id).each do |item|
                item.state = "checking"
                item.save
                pmc_data = PiPmcItem.find_by_id(item.pi_pmc_item_id)
                #pmc_data.buy_qty = item.qty
                pmc_data.state = "checking" 
                pmc_data.save
            end
        end
        redirect_to pi_buy_check_list_path()
    end

    def send_pi_buy_checked
        up_state = PiBuyInfo.find_by_pi_buy_no(params[:pi_buy_no])
        if not up_state.blank?
            if params[:commit] == "反审核"
                up_state.state = "uncheck"
            else
                up_state.state = "checked"
            end
            up_state.save
            PiBuyItem.where(pi_buy_info_id: up_state.id).each do |item|
                if params[:commit] == "反审核"
                    item.state = "checking"
                else
                    item.state = "checked"
                end
                item.save
                pmc_data = PiPmcItem.find_by_id(item.pi_pmc_item_id)
                #pmc_data.buy_qty = item.qty
                if params[:commit] == "反审核"
                    pmc_data.state = "checking"
                else
                    pmc_data.state = "checked" 
                end
                pmc_data.save
            end
        end
        redirect_to pi_buy_checked_list_path()
    end

    def del_pi_buy_item
        buy_data = PiBuyItem.find_by_id(params[:id])
        if not buy_data.blank?
            pmc_data = PiPmcItem.find_by_id(buy_data.pi_pmc_item_id)
            if not pmc_data.blank?
                pmc_data.state = "pass"
                if pmc_data.save
                    buy_data.destroy
                    pitem_data = PItem.find_by_id(pmc_data.p_item_id)
                    if not pitem_data.blank? 
                        pitem_data.buy = "pmc"
                        pitem_data.save
                    end
                end
            end
        end
        redirect_to :back
    end

    def send_pi_buy
        up_state = PiBuyInfo.find_by_pi_buy_no(params[:pi_buy_no])
        if not up_state.blank?
            if params[:commit] == "反审核"
                up_state.state = "uncheck"
                up_state.save
                redirect_to pi_buy_checked_list_path() and return
            else
                up_state.state = "buy"
                up_state.save
                t_p = 0
                PiBuyItem.where(pi_buy_info_id: up_state.id).each do |item|
                    item.state = "buying"
                    item.save
                    t_p = t_p + item.buy_qty*item.cost
                    pmc_data = PiPmcItem.find_by_id(item.pi_pmc_item_id)
                    #pmc_data.buy_qty = item.qty
                    pmc_data.state = "buying" 
                    pmc_data.save

                    if item.save
                        get_pmc_data = PiPmcItem.find_by_id(item.pi_pmc_item_id)
                        if not get_pmc_data.blank?
                            get_wh = WarehouseInfo.find_by_moko_part(item.moko_part)
                            if not get_wh.blank?
                                #get_wh.true_buy_qty = get_wh.true_buy_qty + (params[:buy_qty].to_i - get_pmc_data.buy_qty)
                            
                                get_wh.true_buy_qty = get_wh.true_buy_qty + (item.buy_qty - item.pmc_qty)
                                if item.pmc_flag == "pmc"
                                    get_wh.future_qty = get_wh.future_qty + item.buy_qty
                                else
                                    get_wh.future_qty = get_wh.future_qty + (item.buy_qty - item.pmc_qty)
                                end
                                get_wh.save
                            end
                            get_pmc_data.buy_qty = item.buy_qty
                            get_pmc_data.cost = item.cost
                            get_pmc_data.dn = item.dn
                            get_pmc_data.dn_long = item.dn_long
                            get_pmc_data.save
                        end
                
                        put_pdn = PDn.new
                        put_pdn.email = current_user.email
                        put_pdn.p_item_id = item.p_item_id
                        put_pdn.part_code = item.moko_part
                        put_pdn.date = Time.new
                        put_pdn.dn = item.dn
                        put_pdn.dn_long = item.dn_long
                        put_pdn.cost = item.cost
                        put_pdn.qty = item.buy_qty
                        put_pdn.dn_type = "B"
                        put_pdn.save
                        #更新所有价格
                        change_pmc_cost = PiPmcItem.where("moko_part = '#{item.moko_part}' AND (state = 'buy_adding' OR state = 'new' OR state = 'pass')")
                        if not change_pmc_cost.blank?
                            change_pmc_cost.update_all "cost = '#{item.cost}'"
                        end
                        change_buy_cost = PiBuyItem.where("moko_part = '#{item.moko_part}' AND state = 'new'").update_all "cost = '#{item.cost}'"
                    end

                end
                up_state.t_p = t_p
                up_state.save
            end
        end
        redirect_to pi_buy_checked_list_path()
    end

    def edit_pi_buy_qty_cost
        get_item = PiBuyItem.find_by_id(params[:buy_id])
        if not get_item.blank?
            get_item.buy_qty = params[:buy_qty]
            get_item.cost = params[:buy_cost]
            get_item.dn = params[:buy_dn]
            get_item.dn_long = params[:buy_dn_long]
            get_item.delivery_date = params[:delivery_date]
            #get_item.type = "B"
            get_item.save

        end
        redirect_to :back
    end

    def cost_history_buy
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
        @history_list = PDn.where(part_code: params[:part_code],state: "").order(order_set)
        if not @history_list.blank?
            @c_table = '<br>'
            @c_table += '<small>'
            @c_table += '<table class="table table-bordered">'
            @c_table += '<thead>'
            @c_table += '<tr class="active">'
            @c_table += '<th width="100"><a class="text-primary" data-method="get" data-remote="true" href="/cost_history_buy?part_code='+params[:part_code].to_s+'&item_id='+params[:item_id].to_s+'&order_by=time">询价时间</a><span class="caret"></span></th>'
            @c_table += '<th>MOKO代码</th>' 
            @c_table += '<th width="120"><a class="text-primary" data-method="get" data-remote="true" href="/cost_history_buy?part_code='+params[:part_code].to_s+'&item_id='+params[:item_id].to_s+'&order_by=dn">供应商代码</a><span class="caret"></span></th>'
            @c_table += '<th>供应商全称</th>'    
            @c_table += '<th width="100"><a class="text-primary" data-method="get" data-remote="true" href="/cost_history_buy?part_code='+params[:part_code].to_s+'&item_id='+params[:item_id].to_s+'&order_by=qty">数量</a><span class="caret"></span></th>'        
            @c_table += '<th width="100"><a class="text-primary" data-method="get" data-remote="true" href="/cost_history_buy?part_code='+params[:part_code].to_s+'&item_id='+params[:item_id].to_s+'&order_by=cost">价格</a><span class="caret"></span></th>' 
            @c_table += '<tr>'
            @c_table += '</thead>'
            @c_table += '<tbody>'
            @history_list.each do |item|
                if item.dn_type == "B"
                    @c_table += '<tr class="danger">'
                else
                    @c_table += '<tr>'
                end
                if not item.created_at.blank?
                    @c_table += '<td>' + item.created_at.localtime.strftime('%Y-%m-%d').to_s + '</td>'
                else
                    @c_table += '<td>' + item.date.strftime('%Y-%m-%d').to_s + '</td>'
                end
         
=begin
                @c_table += '<td><small><a rel="nofollow" data-method="get" data-remote="true" href="/pi_buy_item_edit?item_id=' + params[:item_id].to_s + '&cost=' + item.cost.to_s + '&dn= ' + item.dn.to_s + '&dn_long= ' + item.dn_long.to_s + '&part_code=' + item.part_code.to_s + '" ><div>' + item.part_code.to_s + '</div></a></small></td>'
                @c_table += '<td><small><a rel="nofollow" data-method="get" data-remote="true" href="/pi_buy_item_edit?item_id=' + params[:item_id].to_s + '&cost=' + item.cost.to_s + '&dn= ' + item.dn.to_s + '&dn_long= ' + item.dn_long.to_s + '&part_code=' + item.part_code.to_s + '" ><div>' + item.dn.to_s + '</div></a></small></td>'
                @c_table += '<td><small><a rel="nofollow" data-method="get" data-remote="true" href="/pi_buy_item_edit?item_id=' + params[:item_id].to_s + '&cost=' + item.cost.to_s + '&dn= ' + item.dn.to_s + '&dn_long= ' + item.dn_long.to_s + '&part_code=' + item.part_code.to_s + '" ><div>' + item.dn_long.to_s + '</div></a></small></td>'
                @c_table += '<td><small><a rel="nofollow" data-method="get" data-remote="true" href="/pi_buy_item_edit?item_id=' + params[:item_id].to_s + '&cost=' + item.cost.to_s + '&dn= ' + item.dn.to_s + '&dn_long= ' + item.dn_long.to_s + '&part_code=' + item.part_code.to_s + '" ><div>' + item.qty.to_s + '</div></a></small></td>'
                @c_table += '<td><small><a rel="nofollow" data-method="get" data-remote="true" href="/pi_buy_item_edit?item_id=' + params[:item_id].to_s + '&cost=' + item.cost.to_s + '&dn= ' + item.dn.to_s + '&dn_long= ' + item.dn_long.to_s + '&part_code=' + item.part_code.to_s + '" ><div>' + item.cost.to_s + '</div></a></small></td>'
=end
                @c_table += '<td><small><div>' + item.part_code.to_s + '</div></small></td>'
                @c_table += '<td><small><div>' + item.dn.to_s + '</div></small></td>'
                @c_table += '<td><small><div>' + item.dn_long.to_s + '</div></small></td>'
                @c_table += '<td><small><div>' + item.qty.to_s + '</div></small></td>'
                @c_table += '<td><small><div>' + item.cost.to_s + '</div></small></td>'
                @c_table += '</tr>'
            end
            @c_table += '</tbody>'
            @c_table += '</table>'
            @c_table += '</small>'
        end
    end

    def find_dn_ch
        get_supplier_data = SupplierList.find_by_id(params[:id])
        up_dn = PiBuyInfo.find_by(pi_buy_no: params[:pi_buy_no])
        up_dn.dn = get_supplier_data.supplier_name
        up_dn.dn_long = get_supplier_data.supplier_name_long
        up_dn.supplier_list_id = get_supplier_data.id
        up_dn.supplier_clearing = get_supplier_data.supplier_clearing
        up_dn.supplier_address = get_supplier_data.supplier_address
        up_dn.supplier_contacts = get_supplier_data.supplier_contacts
        up_dn.supplier_phone = get_supplier_data.supplier_phone
        up_dn.save 
        item_data = PiBuyItem.where(pi_buy_info_id: up_dn.id)
        if not item_data.blank?
            item_data.update_all "supplier_list_id = '#{up_dn.supplier_list_id}'"

        end
=begin
        pmc_data = PiPmcItem.where(dn: up_dn.dn,state: "pass")
        if not pmc_data.blank?
            pmc_data.each do |item_data|
                find_buy_data = PiBuyItem.find_by_pi_pmc_item_id(item_data.id)
                if find_buy_data.blank?
                    add_buy_data = PiBuyItem.new
                    add_buy_data.pmc_flag = item_data.pmc_flag
                    add_buy_data.buy_user = item_data.buy_user
                    add_buy_data.state = "new"
                    add_buy_data.pi_pmc_item_id = item_data.id 
                    add_buy_data.p_item_id = item_data.p_item_id
                    add_buy_data.erp_id = item_data.erp_id
                    add_buy_data.erp_no = item_data.erp_no
                    add_buy_data.erp_no_son = item_data.erp_no_son
                    add_buy_data.user_do = item_data.user_do
                    add_buy_data.user_do_change = item_data.user_do_change
                    add_buy_data.check = item_data.check
                    add_buy_data.pi_buy_info_id = up_dn.id
                    add_buy_data.procurement_bom_id = item_data.procurement_bom_id
                    add_buy_data.quantity = item_data.quantity
                    add_buy_data.qty = item_data.qty
                    add_buy_data.pmc_qty = item_data.pmc_qty
                    add_buy_data.buy_qty = item_data.buy_qty
                    add_buy_data.description = item_data.description
                    add_buy_data.part_code = item_data.part_code
                    add_buy_data.fengzhuang = item_data.fengzhuang
                    add_buy_data.link = item_data.link
                    add_buy_data.cost = item_data.cost
                    add_buy_data.info = item_data.info
                    add_buy_data.product_id = item_data.product_id
                    add_buy_data.moko_part = item_data.moko_part
                    add_buy_data.moko_des = item_data.moko_des
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
                    add_buy_data.remark = item_data.remark
                    add_buy_data.color = item_data.color
                    add_buy_data.supplier_tag = item_data.supplier_tag
                    add_buy_data.supplier_out_tag = item_data.supplier_out_tag
                    add_buy_data.sell_feed_back_tag = item_data.sell_feed_back_tag
                    if add_buy_data.save
                        item_data.state = "buy_adding"
                        item_data.save
                        pitem_data = PItem.find_by_id(add_buy_data.p_item_id)
                        if not pitem_data.blank? 
                            pitem_data.buy = "buy_adding"
                            pitem_data.save
                        end
                    end
                end
            end
        end
=end
        redirect_to edit_pi_buy_path(pi_buy_no: params[:pi_buy_no])
    end

    def add_pi_buy_item
        if params[:roles]
            params[:roles].each do |item_id|
                #item_data = PItem.find_by_id(item_id)
                
                item_data = PiPmcItem.find_by_id(item_id)
                if not item_data.blank?
                    if item_data.state == "pass" or item_data.state == "new_new"
                    #if item_data.state == "new" or item_data.state == "new_new"
                        find_buy_data = PiBuyItem.find_by_pi_pmc_item_id(item_id)
                        if find_buy_data.blank?
                            add_buy_data = PiBuyItem.new
                            add_buy_data.pi_bom_qty_info_item_id = item_data.pi_bom_qty_info_item_id
                            add_buy_data.pi_info_id = item_data.pi_info_id
                            add_buy_data.pi_item_id = item_data.pi_item_id
                            add_buy_data.pmc_flag = item_data.pmc_flag
                            add_buy_data.buy_user = item_data.buy_user
                            add_buy_data.state = "new"
                            add_buy_data.pi_pmc_item_id = item_data.id 
                            add_buy_data.p_item_id = item_data.p_item_id
                            add_buy_data.erp_id = item_data.erp_id
                            add_buy_data.erp_no = item_data.erp_no
                            add_buy_data.erp_no_son = item_data.erp_no_son
                            add_buy_data.user_do = item_data.user_do
                            add_buy_data.user_do_change = item_data.user_do_change
                            add_buy_data.check = item_data.check
                            add_buy_data.pi_buy_info_id = params[:pi_buy_id]
                            add_buy_data.supplier_list_id = PiBuyInfo.find_by_id(params[:pi_buy_id]).supplier_list_id
                            add_buy_data.procurement_bom_id = item_data.procurement_bom_id
                            add_buy_data.quantity = item_data.quantity
                            add_buy_data.qty = item_data.qty
                            add_buy_data.pmc_qty = item_data.pmc_qty
                            add_buy_data.buy_qty = item_data.buy_qty
                            add_buy_data.description = item_data.description
                            add_buy_data.part_code = item_data.part_code
                            add_buy_data.fengzhuang = item_data.fengzhuang
                            add_buy_data.link = item_data.link
                            add_buy_data.cost = item_data.cost

                            add_buy_data.tax_cost = item_data.cost
                            add_buy_data.tax = item_data.cost
                            add_buy_data.tax_t_p = item_data.cost
                            #add_buy_data.delivery_date = item_data.created_at

                            add_buy_data.info = item_data.info
                            add_buy_data.product_id = item_data.product_id
                            add_buy_data.moko_part = item_data.moko_part
                            add_buy_data.moko_des = item_data.moko_des
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
                            add_buy_data.remark = item_data.remark
                            add_buy_data.color = item_data.color
                            add_buy_data.supplier_tag = item_data.supplier_tag
                            add_buy_data.supplier_out_tag = item_data.supplier_out_tag
                            add_buy_data.sell_feed_back_tag = item_data.sell_feed_back_tag
                            if add_buy_data.save
                                item_data.state = "buy_adding"
                                item_data.save
                                pitem_data = PItem.find_by_id(add_buy_data.p_item_id)
                                if not pitem_data.blank? 
                                    pitem_data.buy = "buy_adding"
                                    pitem_data.save
                                end
                                get_piitem_data = PiBomQtyInfoItem.find_by_id(add_buy_data.pi_bom_qty_info_item_id)
                                get_piitem_data.pmc_back_state = "lock"
                                get_piitem_data.save
                            end
                        end
                    end
                end
            end
        end
        redirect_to :back
    end

    def pmc_check_pass
        if can? :work_a, :all or can? :work_admin, :all
            item_data = PiPmcItem.find_by_id(params[:id])
            if not item_data.blank?
                if item_data.buy_user == ""
                    redirect_to :back, :flash => {:error => "请填写采购工程师！！！"} and return false
                end
                item_data.state = "pass"
                item_data.pass_at = Time.new
                item_data.save
                if item_data.buy_user == "CUSTOMER"
                    if PiBuyInfo.find_by_sql('SELECT pi_buy_no FROM pi_buy_infos WHERE to_days(pi_buy_infos.created_at) = to_days(NOW())').blank?
                        pi_n =1
                    else
                        pi_n = PiBuyInfo.find_by_sql('SELECT pi_buy_no FROM pi_buy_infos WHERE to_days(pi_buy_infos.created_at) = to_days(NOW())').last.pi_buy_no.split("BUY")[-1].to_i + 1
                    end
                    @pi_buy_no = "MO"+ Time.new.strftime('%y').to_s + Time.new.strftime('%m%d').to_s + "BUY"+ pi_n.to_s
                    pi_buy_info = PiBuyInfo.new()
                    pi_buy_info.pi_buy_no = @pi_buy_no
                    pi_buy_info.user = "CUSTOMER"
                    pi_buy_info.state = "buy"
                    if pi_buy_info.save
                        add_buy_data = PiBuyItem.new
                        add_buy_data.pmc_flag = item_data.pmc_flag
                        add_buy_data.buy_user = "CUSTOMER"
                        add_buy_data.state = "buying"
                        add_buy_data.pi_pmc_item_id = item_data.id 
                        add_buy_data.p_item_id = item_data.p_item_id
                        add_buy_data.erp_id = item_data.erp_id
                        add_buy_data.erp_no = item_data.erp_no
                        add_buy_data.erp_no_son = item_data.erp_no_son
                        add_buy_data.user_do = item_data.user_do
                        add_buy_data.user_do_change = item_data.user_do_change
                        add_buy_data.check = item_data.check
                        add_buy_data.pi_buy_info_id = pi_buy_info.id
                        add_buy_data.procurement_bom_id = item_data.procurement_bom_id
                        add_buy_data.quantity = item_data.quantity
                        add_buy_data.qty = item_data.qty
                        add_buy_data.pmc_qty = item_data.pmc_qty
                        add_buy_data.buy_qty = item_data.buy_qty
                        add_buy_data.description = item_data.description
                        add_buy_data.part_code = item_data.part_code
                        add_buy_data.fengzhuang = item_data.fengzhuang
                        add_buy_data.link = item_data.link
                        add_buy_data.cost = item_data.cost
                        add_buy_data.info = item_data.info
                        add_buy_data.product_id = item_data.product_id
                        add_buy_data.moko_part = item_data.moko_part
                        add_buy_data.moko_des = item_data.moko_des
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
                        add_buy_data.remark = item_data.remark
                        add_buy_data.color = item_data.color
                        add_buy_data.supplier_tag = item_data.supplier_tag
                        add_buy_data.supplier_out_tag = item_data.supplier_out_tag
                        add_buy_data.sell_feed_back_tag = item_data.sell_feed_back_tag
                        if add_buy_data.save
                            item_data.state = "buying"
                            item_data.save
=begin
                            pitem_data = PItem.find_by_id(add_buy_data.p_item_id)
                            if not pitem_data.blank? 
                                pitem_data.buy = "buy_adding"
                                pitem_data.save
                            end
=end
                        end
                    end
                end
                #redirect_to pmc_h_path() and return
            end
        end
        redirect_to :back
    end

    def pmc_check_pass_all
        if can? :work_a, :all or can? :work_admin, :all
            if not params[:checkpass_item].blank?
                params[:checkpass_item].each do |id|
                    item_data = PiPmcItem.find_by_id(id)
                    if not item_data.blank?
                        if item_data.buy_user == ""
                            redirect_to :back, :flash => {:error => "请填写采购工程师！！！"} and return false
                        end
                        item_data.state = "pass"
                        item_data.pass_at = Time.new
                        item_data.save
                        if item_data.buy_user == "CUSTOMER"
                            if PiBuyInfo.find_by_sql('SELECT pi_buy_no FROM pi_buy_infos WHERE to_days(pi_buy_infos.created_at) = to_days(NOW())').blank?
                                pi_n =1
                            else
                                pi_n = PiBuyInfo.find_by_sql('SELECT pi_buy_no FROM pi_buy_infos WHERE to_days(pi_buy_infos.created_at) = to_days(NOW())').last.pi_buy_no.split("BUY")[-1].to_i + 1
                            end
                            @pi_buy_no = "MO"+ Time.new.strftime('%y').to_s + Time.new.strftime('%m%d').to_s + "BUY"+ pi_n.to_s
                            pi_buy_info = PiBuyInfo.new()
                            pi_buy_info.pi_buy_no = @pi_buy_no
                            pi_buy_info.user = "CUSTOMER"
                            pi_buy_info.state = "buy"
                            if pi_buy_info.save
                                add_buy_data = PiBuyItem.new
                                add_buy_data.pmc_flag = item_data.pmc_flag
                                add_buy_data.buy_user = "CUSTOMER"
                                add_buy_data.state = "buying"
                                add_buy_data.pi_pmc_item_id = item_data.id 
                                add_buy_data.p_item_id = item_data.p_item_id
                                add_buy_data.erp_id = item_data.erp_id
                                add_buy_data.erp_no = item_data.erp_no
                                add_buy_data.erp_no_son = item_data.erp_no_son
                                add_buy_data.user_do = item_data.user_do
                                add_buy_data.user_do_change = item_data.user_do_change
                                add_buy_data.check = item_data.check
                                add_buy_data.pi_buy_info_id = pi_buy_info.id
                                add_buy_data.procurement_bom_id = item_data.procurement_bom_id
                                add_buy_data.quantity = item_data.quantity
                                add_buy_data.qty = item_data.qty
                                add_buy_data.pmc_qty = item_data.pmc_qty
                                add_buy_data.buy_qty = item_data.buy_qty
                                add_buy_data.description = item_data.description
                                add_buy_data.part_code = item_data.part_code
                                add_buy_data.fengzhuang = item_data.fengzhuang
                                add_buy_data.link = item_data.link
                                add_buy_data.cost = item_data.cost
                                add_buy_data.info = item_data.info
                                add_buy_data.product_id = item_data.product_id
                                add_buy_data.moko_part = item_data.moko_part
                                add_buy_data.moko_des = item_data.moko_des
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
                                add_buy_data.remark = item_data.remark
                                add_buy_data.color = item_data.color
                                add_buy_data.supplier_tag = item_data.supplier_tag
                                add_buy_data.supplier_out_tag = item_data.supplier_out_tag
                                add_buy_data.sell_feed_back_tag = item_data.sell_feed_back_tag
                                if add_buy_data.save
                                    item_data.state = "buying"
                                    item_data.save
=begin
                                    pitem_data = PItem.find_by_id(add_buy_data.p_item_id)
                                    if not pitem_data.blank? 
                                        pitem_data.buy = "buy_adding"
                                        pitem_data.save
                                    end
=end
                                end
                            end
                        end
                        #redirect_to pmc_h_path() and return
                    end
                end
            end
        end
        redirect_to :back
    end

    def del_pmc_wh_check_pass
        if can? :work_a, :all or can? :work_admin, :all
            get_data = PiPmcItem.find_by_id(params[:id])
            if not get_data.blank?
                #判断是否MOKO料
                if get_data.buy_user == "MOKO"
                    #如果是moko料
                    #qty_data = WhChkInfo.find_by_pi_pmc_iten_id(params[:id])
                    #还原库存
                    wh_data = WarehouseInfo.find_by_moko_part(get_data.moko_part)
                    if not wh_data.blank?
                        wh_data.qty = wh_data.qty + get_data.pmc_qty
                        wh_data.wh_qty = wh_data.wh_qty + get_data.pmc_qty
                        wh_data.wh_f_qty = wh_data.wh_f_qty + get_data.pmc_qty
                        wh_data.temp_moko_qty = wh_data.temp_moko_qty - get_data.pmc_qty
                        wh_data.temp_buy_qty = wh_data.temp_buy_qty + get_data.pmc_qty
                        wh_data.true_buy_qty = wh_data.true_buy_qty + get_data.pmc_qty
                        #wh_data.wh_qty = wh_data.wh_qty + get_data.qty
                        #wh_data.wh_f_qty = wh_data.wh_f_qty + get_data.qty
                        wh_data.save
                    end
                    #还原请料
                    #判断是否有两条请料
                    #chk_qty = PiPmcItem.find_by_sql("SELECT COUNT(id) AS c_q FROM pi_pcm_items WHERE pi_pcm_items.p_item_id = '#{get_data.p_item_id}'")
                    if PiPmcItem.where(p_item_id: get_data.p_item_id).count > 1
                        #如果大于1,先还原请料后删除
                        change_data = PiPmcItem.where("p_item_id = '#{get_data.p_item_id}' AND id <> '#{params[:id]}'").first
   
                        change_data.pmc_qty = change_data.pmc_qty + get_data.pmc_qty
                        change_data.buy_qty = change_data.buy_qty + get_data.buy_qty
                        change_data.check = "GREEN"
                        change_data.save
                        get_data.destroy
                    else
                        #如果只有1,更改为外购
                        package1 = Product.find_by_name(get_data.moko_part).package1
                        if package1 == "D" or package1 == "Q"
                            get_data.buy_user = "A"
                        elsif package1 == "PZ"
                            get_data.buy_user = "B"
                        else 
                            get_data.buy_user = "NULL"
                        end
                        get_data.check = "GREEN"
                        get_data.save
                    end
                else
                    #如果不是moko料
                    #还原库存
                    wh_data = WarehouseInfo.find_by_moko_part(get_data.moko_part)
                    if not wh_data.blank?
                        wh_data.temp_buy_qty = wh_data.temp_buy_qty - get_data.pmc_qty
                        wh_data.true_buy_qty = wh_data.true_buy_qty - get_data.pmc_qty
                        wh_data.save
                    end
                    get_data.buy_user = "NULL"
                    get_data.state = "del"
                    get_data.save
                end
            end
        end
        redirect_to :back
    end

    def pmc_wh_check_apply_for_list
        @wh_chk = WhChkInfo.where(state: "new")
    end

    def pmc_wh_check_apply_for
        wh_chk = WhChkInfo.find_by(id: params[:chk_id],state: "new")
        if not wh_chk.blank?
            wh_chk.apply_for_qty = params[:apply_for_qty]
            wh_chk.state = "applying"
            wh_chk.save
        end
        redirect_to :back
    end

    def pmc_wh_check_list
        @wh_chk = WhChkInfo.where(state: "applying")
    end

#库存盘点审核 修改库存 分配采购方按
    def pmc_wh_check_pass
        wh_chk = WhChkInfo.find_by(id: params[:chk_id],state: "applying")
        if not wh_chk.blank?
            wh_data = WarehouseInfo.find_by_moko_part(wh_chk.moko_part)
            wh_data.qty = wh_data.qty - (wh_data.wh_qty - wh_chk.apply_for_qty)


            wh_chk.loss_qty = wh_data.wh_qty - wh_chk.apply_for_qty
            wh_data.loss_qty = wh_data.wh_qty - wh_chk.apply_for_qty + wh_data.loss_qty

            wh_data.wh_qty = wh_data.wh_qty - (wh_data.wh_f_qty - wh_chk.apply_for_qty)
            wh_data.wh_f_qty = wh_chk.apply_for_qty
             
            wh_chk.save
            if wh_data.save
                all_pmc_data = PiPmcItem.where(moko_part: wh_chk.moko_part,buy_user: "CHK")
                #pmc_data = PiPmcItem.find_by_id(wh_chk.pi_pmc_item_id)
                all_pmc_data.each do |pmc_data|
                    temp_qty = pmc_data.qty
                    #1先减去实际库存
                    if wh_data.qty.to_i > 0
                        pmc_data.buy_user = "MOKO"
                        #如果实际库存满足需求
                        if wh_data.qty.to_i - pmc_data.qty.to_i >= 0
                            pmc_data.buy_qty = pmc_data.qty
                            pmc_data.pmc_qty = pmc_data.qty
                            wh_data.qty = wh_data.qty.to_i - pmc_data.qty.to_i
                            wh_data.temp_moko_qty = wh_data.temp_moko_qty.to_i + pmc_data.qty.to_i
                            #wh_data.wh_qty = wh_data.wh_qty - pmc_data.qty
                            #wh_data.wh_f_qty = wh_data.wh_f_qty - pmc_data.qty
                        #如果实际库存不满足需求
                        else wh_data.qty.to_i - pmc_data.qty.to_i < 0
                            pmc_data.buy_qty = wh_data.qty
                            pmc_data.pmc_qty = wh_data.qty
                            wh_data.temp_moko_qty = wh_data.temp_moko_qty.to_i + wh_data.qty.to_i
                            #wh_data.wh_qty = wh_data.wh_qty - wh_data.qty
                            #wh_data.wh_f_qty = wh_data.wh_f_qty - wh_data.qty
                            wh_data.qty = 0
                        end
                        pmc_data.save
                        wh_data.save
                        temp_qty = temp_qty.to_i - pmc_data.buy_qty.to_i
                    end
                    #2再判断是否要减去虚拟库存 
                    if temp_qty > 0 and wh_data.future_qty > 0
                        if temp_qty == pmc_data.qty
                            pmc_data.buy_user = "MOKO_TEMP"
                            #如果虚拟库存满足需求
                            if wh_data.future_qty - pmc_data.qty >= 0
                                pmc_data.buy_qty = pmc_data.qty
                                pmc_data.pmc_qty = pmc_data.qty
                                wh_data.future_qty = wh_data.future_qty.to_i - pmc_data.qty.to_i
                                wh_data.temp_future_qty = wh_data.temp_future_qty.to_i + pmc_data.qty.to_i
                            #如果虚拟库存不满足需求
                            else wh_data.future_qty - pmc_data.qty < 0
                                pmc_data.buy_qty = wh_data.future_qty
                                pmc_data.pmc_qty = wh_data.future_qty
                                wh_data.future_qty = 0
                                wh_data.temp_future_qty = wh_data.temp_future_qty.to_i + wh_data.future_qty.to_i
                            end
                            pmc_data.save
                            wh_data.save
                            temp_qty = temp_qty - pmc_data.buy_qty
                        else
                            add_future_data = PiPmcItem.new
                            add_future_data.pi_info_id = pmc_data.pi_info_id
                            add_future_data.pi_item_id = pmc_data.pi_item_id
                            add_future_data.pi_bom_qty_info_item_id = pmc_data.pi_bom_qty_info_item_id
                            add_future_data.pmc_type = "CHK"
                            add_future_data.state = "new"
                            add_future_data.erp_no = pmc_data.erp_no
                            add_future_data.erp_no_son = pmc_data.erp_no_son
                            add_future_data.moko_part = pmc_data.moko_part
                            add_future_data.moko_des = pmc_data.moko_des
                            add_future_data.part_code = pmc_data.part_code

                            add_future_data.qty = pmc_data.qty
                            add_future_data.qty_in = pmc_data.qty
                            add_future_data.buy_user = "MOKO_TEMP"
                            #如果虚拟库存满足需求
                            if wh_data.future_qty.to_i - temp_qty.to_i >= 0
                                add_future_data.buy_qty = temp_qty
                                add_future_data.pmc_qty = temp_qty
                                wh_data.future_qty = wh_data.future_qty.to_i - pmc_data.qty.to_i
                                wh_data.temp_future_qty = wh_data.temp_future_qt.to_iy + pmc_data.qty.to_i
                            #如果虚拟库存不满足需求
                            else wh_data.future_qty.to_i - temp_qty.to_i < 0
                                add_future_data.buy_qty = wh_data.future_qty
                                add_future_data.pmc_qty = wh_data.future_qty
                                wh_data.future_qty = 0
                                wh_data.temp_future_qty = wh_data.temp_future_qty.to_i + wh_data.future_qty.to_i
                            end
                            add_future_data.remark = pmc_data.remark
                            add_future_data.p_item_id = pmc_data.p_item_id
                            add_future_data.erp_id = pmc_data.erp_id
                            add_future_data.user_do = pmc_data.user_do
                            add_future_data.user_do_change = pmc_data.user_do_change
                            add_future_data.check = pmc_data.check
                            add_future_data.pi_buy_info_id = pmc_data.pi_buy_info_id
                            add_future_data.procurement_bom_id = pmc_data.procurement_bom_id
                            add_future_data.quantity = pmc_data.quantity
                            add_future_data.description = pmc_data.description
                            add_future_data.fengzhuang = pmc_data.fengzhuang
                            add_future_data.link = pmc_data.link
                            add_future_data.cost = pmc_data.cost
                            add_future_data.info = pmc_data.info
                            add_future_data.product_id = pmc_data.product_id
                            add_future_data.warn = pmc_data.warn
                            add_future_data.user_id = pmc_data.user_id
                            add_future_data.danger = pmc_data.danger
                            add_future_data.manual = pmc_data.manual
                            add_future_data.mark = pmc_data.mark
                            add_future_data.mpn = pmc_data.mpn
                            add_future_data.mpn_id = pmc_data.mpn_id
                            add_future_data.price = pmc_data.price
                            add_future_data.mf = pmc_data.mf
                            add_future_data.dn = pmc_data.dn
                            add_future_data.dn_id = pmc_data.dn_id
                            add_future_data.dn_long = pmc_data.dn_long
                            add_future_data.other = pmc_data.other
                            add_future_data.all_info = pmc_data.all_info
                            add_future_data.color = pmc_data.color
                            add_future_data.supplier_tag = pmc_data.supplier_tag
                            add_future_data.supplier_out_tag = pmc_data.supplier_out_tag
                            add_future_data.sell_feed_back_tag = pmc_data.sell_feed_back_tag
                            add_future_data.save
                            wh_data.save
                            temp_qty = temp_qty.to_i - add_future_data.buy_qty.to_i
                        end
                    end
                    #3再判断是否要外购
                    if temp_qty > 0
                        if temp_qty == pmc_data.qty
                            package1 = Product.find_by_name(wh_chk.moko_part).package1
                            if package1 == "D" or package1 == "Q"
                                pmc_data.buy_user = "A"
                            elsif package1 == "PZ"
                                pmc_data.buy_user = "B"
                            else 
                                pmc_data.buy_user = "NULL"
                            end
                            pmc_data.save
                        else
                            add_buy_data = PiPmcItem.new
                            add_buy_data.pi_info_id = pmc_data.pi_info_id
                            add_buy_data.pi_item_id = pmc_data.pi_item_id
                            add_buy_data.pi_bom_qty_info_item_id = pmc_data.pi_bom_qty_info_item_id
                            add_buy_data.pmc_type = "CHK"
                            add_buy_data.state = "new"
                            add_buy_data.erp_no = pmc_data.erp_no
                            add_buy_data.erp_no_son = pmc_data.erp_no_son
                            add_buy_data.moko_part = pmc_data.moko_part
                            add_buy_data.moko_des = pmc_data.moko_des
                            add_buy_data.part_code = pmc_data.part_code
                            add_buy_data.qty = pmc_data.qty
                            add_buy_data.qty_in = pmc_data.qty
                            package1 = Product.find_by_name(wh_chk.moko_part).package1
                            if package1 == "D" or package1 == "Q"
                                add_buy_data.buy_user = "A"
                            elsif package1 == "PZ"
                                add_buy_data.buy_user = "B"
                            else 
                                add_buy_data.buy_user = "NULL"
                            end
                            add_buy_data.buy_qty = temp_qty
                            add_buy_data.pmc_qty = temp_qty  
                            add_buy_data.remark = pmc_data.remark
                            add_buy_data.p_item_id = pmc_data.p_item_id
                            add_buy_data.erp_id = pmc_data.erp_id
                            add_buy_data.user_do = pmc_data.user_do
                            add_buy_data.user_do_change = pmc_data.user_do_change
                            add_buy_data.check = pmc_data.check
                            add_buy_data.pi_buy_info_id = pmc_data.pi_buy_info_id
                            add_buy_data.procurement_bom_id = pmc_data.procurement_bom_id
                            add_buy_data.quantity = pmc_data.quantity
                            add_buy_data.description = pmc_data.description
                            add_buy_data.fengzhuang = pmc_data.fengzhuang
                            add_buy_data.link = pmc_data.link
                            add_buy_data.cost = pmc_data.cost
                            add_buy_data.info = pmc_data.info
                            add_buy_data.product_id = pmc_data.product_id
                            add_buy_data.warn = pmc_data.warn
                            add_buy_data.user_id = pmc_data.user_id
                            add_buy_data.danger = pmc_data.danger
                            add_buy_data.manual = pmc_data.manual
                            add_buy_data.mark = pmc_data.mark
                            add_buy_data.mpn = pmc_data.mpn
                            add_buy_data.mpn_id = pmc_data.mpn_id
                            add_buy_data.price = pmc_data.price
                            add_buy_data.mf = pmc_data.mf
                            add_buy_data.dn = pmc_data.dn
                            add_buy_data.dn_id = pmc_data.dn_id
                            add_buy_data.dn_long = pmc_data.dn_long
                            add_buy_data.other = pmc_data.other
                            add_buy_data.all_info = pmc_data.all_info
                            add_buy_data.color = pmc_data.color
                            add_buy_data.supplier_tag = pmc_data.supplier_tag
                            add_buy_data.supplier_out_tag = pmc_data.supplier_out_tag
                            add_buy_data.sell_feed_back_tag = pmc_data.sell_feed_back_tag
                            add_buy_data.save
                        end
                        #wh_data.temp_buy_qty = wh_data.temp_buy_qty + pmc_data.qty
                        #wh_data.true_buy_qty = wh_data.true_buy_qty + pmc_data.qty
                        wh_data.temp_buy_qty = wh_data.temp_buy_qty.to_i + temp_qty.to_i
                        wh_data.true_buy_qty = wh_data.true_buy_qty.to_i + temp_qty.to_i
                        wh_data.save
                    end
                    wh_chk.state = "pass"
                    wh_chk.save
                end
            end
        end
        redirect_to :back
    end

    def pmc_h
        pmc_where = "state NOT LIKE '%new%'"
        if not params[:pass_date].blank?
            if not pmc_where.blank?
            pmc_where += " AND "
            end
            pmc_where += "pass_at LIKE '#{params[:pass_date]}%'"
        end
        if not params[:order_no].blank?
            if not pmc_where.blank?
            pmc_where += " AND "
            end
            pmc_where += "erp_no_son LIKE '%#{params[:order_no].to_s.strip}%'"
        end
        if not params[:moko_part].blank?
            if not pmc_where.blank?
            pmc_where += " AND "
            end
            pmc_where += "moko_part LIKE '%#{params[:moko_part].to_s.strip}%'"
        end
        if not params[:moko_des].blank?
            if not pmc_where.blank?
            pmc_where += " AND "
            end
            pmc_where += "moko_des LIKE '%#{params[:moko_des].to_s.strip}%'"
        end
        if not params[:part_code].blank?
            if not pmc_where.blank?
            pmc_where += " AND "
            end
            pmc_where += "part_code LIKE '%#{params[:part_code].to_s.strip}%'"
        end
        if not params[:buy_user].blank?
            if not pmc_where.blank?
            pmc_where += " AND "
            end
            pmc_where += "buy_user LIKE '%#{params[:buy_user].to_s.strip}%'"
        end
        sort_data = "pass_at"
        if not params[:sort_data].blank?
            sort_data = params[:sort_data]
        end
        @pi_buy = PiPmcItem.where("#{pmc_where}").order("#{sort_data} DESC").paginate(:page => params[:page], :per_page => 30)
    end

    def new_moko_part
        @part_name_main = ""
        @part_name_type_a_no = ""
        @part_name_type_c_no = "" 
        @moko_part_number = ""
        @part_name_type_c_name = ""
        @type_b = "[&quot;"
        all_type_b = MokoPartsType.find_by_sql("SELECT moko_parts_types.part_name_type_b_name,moko_parts_types.part_name_type_b_sname FROM moko_parts_types GROUP BY moko_parts_types.part_name_type_b_name")
        all_type_b.each do |type_b|
            @type_b += "&quot;,&quot;" + type_b.part_name_type_b_name.to_s
        end
        @type_b += "&quot;]"
        
        if params[:type_b]
            all_type_c = MokoPartsType.find_by_sql("SELECT moko_parts_types.part_name_type_c_no, moko_parts_types.part_name_type_a_no, moko_parts_types.part_name_main, moko_parts_types.part_name_type_c_name FROM moko_parts_types WHERE moko_parts_types.part_name_type_b_name = '#{params[:type_b]}'")
            @type_c = '<lable for="type_c" class="col-sm-1 control-label"><strong>三级类型</strong></lable>'
            @type_c += '<div class="col-sm-8">'
            if all_type_c.blank?
                @type_c += '<code class="control-label">没有找到二级类型--->' + params[:type_b].to_s + '</code>'
            else
                @part_name_main = all_type_c.first.part_name_main.to_s
                @part_name_type_a_no = all_type_c.first.part_name_type_a_no.to_s

                all_type_c.each do |type_c|
                    @type_c += '<a data-remote="true" class="btn btn-link" href="/new_moko_part?type_b=' + params[:type_b].to_s + '&type_c=' + type_c.part_name_type_c_name.to_s + '&type_c_no=' + type_c.part_name_type_c_no.to_s + '" >' + type_c.part_name_type_c_name + '</a>'
                end   
            end
            @type_c += '</div>'
            if params[:type_c]
                @part_name_type_c_no = params[:type_c_no].to_s
                @part_name_type_c_name = params[:type_c].to_s
                @selected = MokoPartsType.find_by(part_name_type_b_name: params[:type_b],part_name_type_c_name: params[:type_c])
                @moko_des_show = ''
                @selected.all_des_cn.split("|").each_with_index do |moko_des,index|
                    @moko_des_show += '<div class="form-group">'
                    @moko_des_show += '<lable for="' + moko_des.to_s + '" class="col-sm-1 control-label"><strong>' + moko_des.to_s + '</strong></lable>'
                    @moko_des_show += '<div class="col-sm-2">'
                    @moko_des_show += '<input id="value_' + (index+1).to_s + '" name="value_' + (index+1).to_s + '" type="text" class="form-control input-sm" style="padding: 0px;margin: 0px;" size="20">'
                    @moko_des_show += '</div>'
                    @moko_des_show += '<div class="col-sm-9"></div>'
                    @moko_des_show += '</div>'
                end
                moko_part_number = Product.find_by_sql("SELECT MAX(products.part_no) AS num FROM products WHERE products.part_name = '#{params[:type_b]}' AND products.package2 = '#{params[:type_c]}'")
                if not moko_part_number.blank?
                    @moko_part_number_new = moko_part_number.first.num + 1
                    @moko_part_number_new_show = "%04d"%(moko_part_number.first.num + 1)
                end
                render "new_moko_part_type_c.js.erb" and return
            else
                render "new_moko_part_type_b.js.erb" and return
            end
        end
         
    end

    def add_new_moko_part
        add_des = ""
        if not params[:value_1].blank?
            add_des += params[:value_1].to_s + " "
        end
        if not params[:value_2].blank?
            add_des += params[:value_2].to_s + " "
        end
        if not params[:value_3].blank?
            add_des += params[:value_3].to_s + " "
        end
        if not params[:value_4].blank?
            add_des += params[:value_4].to_s + " "
        end
        if not params[:value_5].blank?
            add_des += params[:value_5].to_s + " "
        end
        if not params[:value_6].blank?
            add_des += params[:value_6].to_s + " "
        end
        if not params[:value_7].blank?
            add_des += params[:value_7].to_s + " "
        end
        if not params[:value_8].blank?
            add_des += params[:value_8].to_s + " "
        end
        if not params[:value_9].blank?
            add_des += params[:value_9].to_s + " "
        end
        if not params[:value_10].blank?
            add_des += params[:value_10].to_s + " "
        end
        check_data = Product.find_by_description(add_des)
        if check_data.blank?
            add_part = Product.new
            add_part.part_no = params[:moko_part_number_new]
            add_part.name = params[:part_name_main] + "." + params[:part_name_type_a_no] + "." + params[:part_name_type_c_no] + "." + "%04d"%params[:moko_part_number_new] + "-" + params[:part_name_type_c_name]
            add_part.description = add_des
            add_part.part_name = params[:value_1]
            add_part.part_name_en = params[:part_name_type_b_name_en]
            add_part.ptype = params[:part_name_type_a_sname]
            add_part.package1 = params[:part_name_type_c_no]
            add_part.package2 = params[:part_name_type_c_name]
            if params[:value_1]
                add_part.value1 = params[:value_1]
            end
            if params[:value_2]
                add_part.value2 = params[:value_2]
            end
            if params[:value_3]
                add_part.value3 = params[:value_3]
            end
            if params[:value_4]
                add_part.value4 = params[:value_4]
            end
            if params[:value_5]
                add_part.value5 = params[:value_5]
            end
            if params[:value_6]
                add_part.value6 = params[:value_6]
            end
            if params[:value_7]
                add_part.value7 = params[:value_7]
            end
            if params[:value_8]
                add_part.value8 = params[:value_8]
            end
            if params[:value_9]
                add_part.value9 = params[:value_9]
            end
            if params[:value_10]
                add_part.value10 = params[:value_10]
            end
            if add_part.save
                if not params[:item_id].blank?
                    get_p_item_data = PItem.find_by_id(params[:item_id])
                    if not get_p_item_data.blank?
                        get_p_item_data.product_id = add_part.id
                        get_p_item_data.moko_part = add_part.name
                        get_p_item_data.moko_des = add_part.description
                        get_p_item_data.save
                    end
                end
            end
        end  
        
        redirect_to :back 
    end

    def pi_print
        @pi_info = PiInfo.find_by_id(params[:id])
        @pi_info_c = PcbCustomer.find_by_id(@pi_info.pcb_customer_id)
        @pi_item = PiItem.where(pi_info_id: params[:id])
        @find_pcb = PiItem.where(pi_info_id: params[:id], p_type: "PCB")
        #if not @find_pcb.blank?
            #@pi_pcb = PcbItemInfo.find_by_pcb_order_item_id(find_pcb.first.find_pcb.order_item_id)
        #end
        #@pi_other_item = PiOtherItem.where(pi_no: @pi_info.pi_no)
        @pi_other_item = PiOtherItem.where(pi_info_id: @pi_info.id)
        @total_p = PiItem.where(pi_info_id: params[:id]).sum("t_p") + PiOtherItem.where(pi_no: @pi_info.pi_no).sum("t_p")
        if params[:type] == '1'
            render "pi_print_1.html.erb" and return
        elsif params[:type] == '2'
            render "pi_print_2.html.erb" and return
        elsif params[:type] == '3'
            render "pi_print_3.html.erb" and return
        elsif params[:type] == '4'
            render "pi_print_4.html.erb" and return
        end
    end

    def supplier_dn_excel
        if can? :work_suppliers, :all
            if params[:out_tag]
                @bom = PItem.where(user_do: '999',supplier_tag: nil,supplier_out_tag: nil).order("mpn")
            else
                @bom = PItem.where(user_do: '999',supplier_tag: nil).order("mpn")
            end
            file_name = "supplier_out.xls"
            path = Rails.root.to_s+"/public/uploads/bom/excel_file/"
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
                ff.write (path+file_name)              
                send_file(path+file_name, type: "application/vnd.ms-excel") and return
        else
            render plain: "You don't have permission to view this page !"
        end
                #send_file(path,filename: file_name, type: "application/vnd.ms-excel")    
    end

    def pi_out_xlsx_moko_a
        @pi_info = PiInfo.find_by_id(params[:id])
        @pi_info_c = PcbCustomer.find_by_id(@pi_info.pcb_customer_id)
        @pi_item = PiItem.where(pi_info_id: params[:id])
        @find_pcb = PiItem.where(pi_info_id: params[:id], p_type: "PCB")

        @pi_other_item = PiOtherItem.where(pi_no: @pi_info.pi_no)
        @total_p = PiItem.where(pi_info_id: params[:id]).sum("t_p") + PiOtherItem.where(pi_no: @pi_info.pi_no).sum("t_p")
        
        file_name = @pi_info.pi_no.to_s + "_out.xlsx"
        path = Rails.root.to_s+"/public/uploads/bom/pi_excel_file/"


        p = Axlsx::Package.new
        p.workbook do |wb|
            wb.styles do |s|
                a_text = s.add_style :b => true,
                                     :sz => 24,
                                     :alignment => { :horizontal => :center,
                                                     :vertical => :center }
                b_text = s.add_style :b => true,
                                     :sz => 20,
                                     :alignment => { :horizontal => :center,
                                                     :vertical => :center }
                c_text = s.add_style :alignment => { :horizontal => :left,
                                                     :vertical => :center,
                                                     :wrap_text => true  }
                d_text = s.add_style :fg_color => "00",
                                     :bg_color => "EEEEEE",
                                     :border => { :style => :thin, :color => "00" },
                                     :alignment => { :horizontal => :center,
                                                     :vertical => :center,
                                                     :wrap_text => true }
                e_text = s.add_style :border => { :style => :thin, :color => "00" },
                                     :alignment => { :horizontal => :center,
                                                     :vertical => :center,
                                                     :wrap_text => true }
                f_text = s.add_style :border => { :style => :thin, :color => "00" },
                                     :alignment => { :horizontal => :left,
                                                     :vertical => :center,
                                                     :wrap_text => true }
                g_text = s.add_style :b => true,
                                     :sz => 12,
                                     :border => { :style => :thin, :color => "00" },
                                     :alignment => { :horizontal => :left,
                                                     :vertical => :center}
                h_text = s.add_style :border => { :style => :thin, :color => "00" },
                                     :alignment => { :horizontal => :left,
                                                     :vertical => :center}
                i_text = s.add_style :b => true,
                                     :sz => 12,
                                     :alignment => { :horizontal => :left,
                                                     :vertical => :center}
                wb.add_worksheet(:name => 'moko') do |sheet|
                    
                    img = File.expand_path(Rails.root.to_s+'/public/uploads/logo.jpg', __FILE__)
                    sheet.add_image(:image_src => img,:alignment => { :horizontal => :right, :vertical => :right }) do |image|
                        image.width=60
                        image.height=60
                        #image.hyperlink.tooltip = "MOKO"
                        image.start_at 3, 0
                    end
                    sheet.add_row ['MOKO Technology Ltd'], :height => 50, :style => a_text
                    sheet.merge_cells("A1:J1")


                    sheet.add_row ['Proforma Invoice'], :style => b_text
                    sheet.merge_cells("A2:J2")


                    all_ii = []
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "P.I NO.:"
                    all_ii << @pi_info.pi_no.to_s
                    all_ii << ""
                    all_ii << "Date:"
                    all_ii << @pi_info.updated_at.localtime.strftime('%Y/%m/%d').to_s
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b3:d3")
                    sheet.merge_cells("g3:h3")
                    


                    all_ii = []
                    all_ii << "To:"
                    all_ii << @pi_info_c.customer.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "From:"
                    all_ii << current_user.en_name.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b4:d4")
                    sheet.merge_cells("g4:i4")


                    all_ii = []
                    all_ii << "Company:"
                    all_ii << @pi_info_c.customer_com.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "Company:"
                    all_ii << "MOKO TECHNOLOGY LTD"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b5:d5")
                    sheet.merge_cells("g5:i5")


                    all_ii = []
                    all_ii << "Tel:"
                    all_ii << @pi_info_c.tel.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "Tel:"
                    all_ii << current_user.tel
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b6:d6")
                    sheet.merge_cells("g6:i6")


                    all_ii = []
                    all_ii << "Fax:"
                    all_ii << @pi_info_c.fax.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "Fax:"
                    all_ii << current_user.fax
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b7:d7")
                    sheet.merge_cells("g7:i7")


                    all_ii = []
                    all_ii << "E-mail:"
                    all_ii << @pi_info_c.email.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "E-mail:"
                    all_ii << current_user.email
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b8:d8")
                    sheet.merge_cells("g8:i8")




                    all_ii = []
                    all_ii << "Add:"
                    all_ii << @pi_info_c.shipping_address.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "Add:"
                    all_ii << current_user.add
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b9:d9")
                    sheet.merge_cells("g9:j9")



                    all_ii = []
                    all_ii << "NO."
                    all_ii << "Customer Part No."
                    all_ii << "PCB Size(mm)"
                    all_ii << "Quantity(PCS)"
                    all_ii << "Layer"
                    all_ii << "Description"
                    all_ii << "Unit Price"
                    all_ii << ""
                    all_ii << ""
                    all_ii << "Total Price(USD)"
                    sheet.add_row all_ii, :style => d_text
                    sheet.merge_cells("g10:i10")

                    row_set = 10
                    if not @pi_item.blank?     
                        @pi_item.each_with_index do |item,index|
                            row_set = row_set +1
                            all_ii = []
                            all_ii << index + 1
                            all_ii << item.c_p_no.to_s
                            all_ii << item.pcb_size.to_s
                            all_ii << item.qty.to_s
                            all_ii << item.layer.to_s
                            all_ii << item.des.to_s
                            all_ii << item.unit_price.to_s
                            all_ii << ""
                            all_ii << ""
                            all_ii << item.t_p.to_s
                            sheet.add_row all_ii, :style => e_text
                            sheet.merge_cells("g#{row_set}:i#{row_set}")
                        end


                        row_set = row_set +1
                        all_ii = []
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << "Shipping Cost"
                        all_ii << ""
                        all_ii << ""
                        all_ii << @pi_info.pi_shipping_cost.to_s
                        sheet.add_row all_ii, :style => e_text
                        sheet.merge_cells("g#{row_set}:i#{row_set}")
            

                        row_set = row_set +1
                        all_ii = []
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << "Bank Fee"
                        all_ii << ""
                        all_ii << ""
                        all_ii << @pi_info.pi_bank_fee.to_s
                        sheet.add_row all_ii, :style => e_text
                        sheet.merge_cells("g#{row_set}:i#{row_set}")
            

                        row_set = row_set +1
                        all_ii = []
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << "Total"
                        all_ii << ""
                        all_ii << ""
                        all_ii << @pi_info.t_p.to_s
                        sheet.add_row all_ii, :style => e_text
                        sheet.merge_cells("g#{row_set}:i#{row_set}")

                    end
             
                    row_set = row_set +1
                    all_ii = []
                        all_ii << "Leadtime: The lead time for PCBA is 20 working days."
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                    sheet.add_row all_ii, :style => f_text
                    sheet.merge_cells("a#{row_set}:j#{row_set}")
                    

                    row_set = row_set +1
                    sheet.add_row


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Bank information:"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => g_text
                    sheet.merge_cells("a#{row_set}:g#{row_set}")


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Account Name : MOKO TECHNOLOGY LIMITED"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => h_text
                    img = File.expand_path(Rails.root.to_s+'/public/uploads/MOKO_bank.png', __FILE__)
                    sheet.add_image(:image_src => img) do |image|
                        image.width=400
                        image.height=200
                        #image.hyperlink.tooltip = "MOKO"
                        image.start_at 3, row_set-3
                    end
                    sheet.merge_cells("a#{row_set}:g#{row_set}")


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Bank Account Number ：801144007838"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => h_text
                    sheet.merge_cells("a#{row_set}:g#{row_set}")


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Swift code:HSBCHKHHHKH"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => h_text
                    sheet.merge_cells("a#{row_set}:g#{row_set}")


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Bank  Name ：The Hongkong and Shanghai Banking Corporation Limited"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => h_text
                    sheet.merge_cells("a#{row_set}:g#{row_set}")

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Bank Adress:No.1 Queen’s Road Central ,Hong Kong"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => h_text
                    sheet.merge_cells("a#{row_set}:g#{row_set}")


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Bank Code :  004"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => h_text
                    sheet.merge_cells("a#{row_set}:g#{row_set}")

                    row_set = row_set +1
                    sheet.add_row

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Remark:"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => i_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "The above quotation is based on the following conditions:"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "1.Payment Terms: T/T in advance."
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "2.Cetificate :ROHS.ISO9001."
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "3.The outline tolerance is +/-0.2mm."
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "4.The quotation is valid for 10days."
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")

                    sheet.column_widths 10, 15, 15, 15, 10, 25, 10, 10, 10, 25
                end
            end
        end


        p.serialize(path+file_name)
        send_file(path+file_name, type: "application/vnd.ms-excel") and return

    end

    def pi_out_xlsx_moko_b
        @pi_info = PiInfo.find_by_id(params[:id])
        @pi_info_c = PcbCustomer.find_by_id(@pi_info.pcb_customer_id)
        @pi_item = PiItem.where(pi_info_id: params[:id])
        @find_pcb = PiItem.where(pi_info_id: params[:id], p_type: "PCB")

        @pi_other_item = PiOtherItem.where(pi_no: @pi_info.pi_no)
        @total_p = PiItem.where(pi_info_id: params[:id]).sum("t_p") + PiOtherItem.where(pi_no: @pi_info.pi_no).sum("t_p")
        
        file_name = @pi_info.pi_no.to_s + "_out.xlsx"
        path = Rails.root.to_s+"/public/uploads/bom/pi_excel_file/"


        p = Axlsx::Package.new
        p.workbook do |wb|
            wb.styles do |s|
                a_text = s.add_style :b => true,
                                     :sz => 24,
                                     :alignment => { :horizontal => :center,
                                                     :vertical => :center }
                b_text = s.add_style :b => true,
                                     :sz => 20,
                                     :alignment => { :horizontal => :center,
                                                     :vertical => :center }
                c_text = s.add_style :alignment => { :horizontal => :left,
                                                     :vertical => :center,
                                                     :wrap_text => true  }
                d_text = s.add_style :fg_color => "00",
                                     :bg_color => "EEEEEE",
                                     :border => { :style => :thin, :color => "00" },
                                     :alignment => { :horizontal => :center,
                                                     :vertical => :center,
                                                     :wrap_text => true }
                e_text = s.add_style :border => { :style => :thin, :color => "00" },
                                     :alignment => { :horizontal => :center,
                                                     :vertical => :center,
                                                     :wrap_text => true }
                f_text = s.add_style :border => { :style => :thin, :color => "00" },
                                     :alignment => { :horizontal => :left,
                                                     :vertical => :center,
                                                     :wrap_text => true }
                g_text = s.add_style :b => true,
                                     :sz => 12,
                                     :border => { :style => :thin, :color => "00" },
                                     :alignment => { :horizontal => :left,
                                                     :vertical => :center}
                h_text = s.add_style :border => { :style => :thin, :color => "00" },
                                     :alignment => { :horizontal => :left,
                                                     :vertical => :center}
                i_text = s.add_style :b => true,
                                     :sz => 12,
                                     :alignment => { :horizontal => :left,
                                                     :vertical => :center}
                wb.add_worksheet(:name => 'moko') do |sheet|
                    
                    img = File.expand_path(Rails.root.to_s+'/public/uploads/logo.jpg', __FILE__)
                    sheet.add_image(:image_src => img,:alignment => { :horizontal => :right, :vertical => :right }) do |image|
                        image.width=60
                        image.height=60
                        #image.hyperlink.tooltip = "MOKO"
                        image.start_at 3, 0
                    end
                    sheet.add_row ['MOKO Technology Ltd'], :height => 50, :style => a_text
                    sheet.merge_cells("A1:J1")


                    sheet.add_row ['Proforma Invoice'], :style => b_text
                    sheet.merge_cells("A2:J2")


                    all_ii = []
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "P.I NO.:"
                    all_ii << @pi_info.pi_no.to_s
                    all_ii << ""
                    all_ii << "Date:"
                    all_ii << @pi_info.updated_at.localtime.strftime('%Y/%m/%d').to_s
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b3:d3")
                    sheet.merge_cells("g3:h3")
                    


                    all_ii = []
                    all_ii << "To:"
                    all_ii << @pi_info_c.customer.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "From:"
                    all_ii << current_user.en_name.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b4:d4")
                    sheet.merge_cells("g4:i4")


                    all_ii = []
                    all_ii << "Company:"
                    all_ii << @pi_info_c.customer_com.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "Company:"
                    all_ii << "MOKO TECHNOLOGY LTD"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b5:d5")
                    sheet.merge_cells("g5:i5")


                    all_ii = []
                    all_ii << "Tel:"
                    all_ii << @pi_info_c.tel.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "Tel:"
                    all_ii << current_user.tel
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b6:d6")
                    sheet.merge_cells("g6:i6")


                    all_ii = []
                    all_ii << "Fax:"
                    all_ii << @pi_info_c.fax.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "Fax:"
                    all_ii << current_user.fax
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b7:d7")
                    sheet.merge_cells("g7:i7")


                    all_ii = []
                    all_ii << "E-mail:"
                    all_ii << @pi_info_c.email.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "E-mail:"
                    all_ii << current_user.email
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b8:d8")
                    sheet.merge_cells("g8:i8")




                    all_ii = []
                    all_ii << "Add:"
                    all_ii << @pi_info_c.shipping_address.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "Add:"
                    all_ii << current_user.add
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b9:d9")
                    sheet.merge_cells("g9:j9")



                    all_ii = []
                    all_ii << "NO."
                    all_ii << "Customer Part No."
                    all_ii << "PCB Size(mm)"
                    all_ii << "Quantity(PCS)"
                    all_ii << "Layer"
                    all_ii << "Description"
                    all_ii << "PCB Price"
                    all_ii << "Components Price"
                    all_ii << "PCBA"
                    all_ii << "Total Price(USD)"
                    sheet.add_row all_ii, :style => d_text
                    #sheet.merge_cells("g10:i10")

                    row_set = 10
                    if not @pi_item.blank?     
                        @pi_item.each_with_index do |item,index|
                            row_set = row_set +1
                            all_ii = []
                            all_ii << index + 1
                            all_ii << item.c_p_no.to_s
                            all_ii << item.pcb_size.to_s
                            all_ii << item.qty.to_s
                            all_ii << item.layer.to_s
                            all_ii << item.des.to_s
                            all_ii << item.pcb_price.to_s
                            all_ii << item.com_cost.to_s
                            all_ii << item.pcba.to_s
                            all_ii << item.t_p.to_s
                            sheet.add_row all_ii, :style => e_text
                            #sheet.merge_cells("g#{row_set}:i#{row_set}")
                        end


                        row_set = row_set +1
                        all_ii = []
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << "Shipping Cost"
                        all_ii << ""
                        all_ii << ""
                        all_ii << @pi_info.pi_shipping_cost.to_s
                        sheet.add_row all_ii, :style => e_text
                        sheet.merge_cells("g#{row_set}:i#{row_set}")
            

                        row_set = row_set +1
                        all_ii = []
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << "Bank Fee"
                        all_ii << ""
                        all_ii << ""
                        all_ii << @pi_info.pi_bank_fee.to_s
                        sheet.add_row all_ii, :style => e_text
                        sheet.merge_cells("g#{row_set}:i#{row_set}")
            

                        row_set = row_set +1
                        all_ii = []
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << "Total"
                        all_ii << ""
                        all_ii << ""
                        all_ii << @pi_info.t_p.to_s
                        sheet.add_row all_ii, :style => e_text
                        sheet.merge_cells("g#{row_set}:i#{row_set}")

                    end
             
                    row_set = row_set +1
                    all_ii = []
                        all_ii << "Leadtime: The lead time for PCBA is 20 working days."
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                    sheet.add_row all_ii, :style => f_text
                    sheet.merge_cells("a#{row_set}:j#{row_set}")
                    

                    row_set = row_set +1
                    sheet.add_row


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Bank RMB Information:"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => g_text
                    sheet.merge_cells("a#{row_set}:g#{row_set}")


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Bank account:	6241 8578 0704 4682"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => h_text
                    img = File.expand_path(Rails.root.to_s+'/public/uploads/MOKO_bank.png', __FILE__)
                    sheet.add_image(:image_src => img) do |image|
                        image.width=400
                        image.height=200
                        #image.hyperlink.tooltip = "MOKO"
                        image.start_at 3, row_set-5
                    end
                    sheet.merge_cells("a#{row_set}:g#{row_set}")


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Name:	黄丽娟 Huang Li Juan"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => h_text
                    sheet.merge_cells("a#{row_set}:g#{row_set}")


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Bank Name: 深圳招行梅龙支行"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => h_text
                    sheet.merge_cells("a#{row_set}:g#{row_set}")

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Remark:"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => i_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "The above quotation is based on the following conditions:"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "1.Payment Terms: T/T in advance."
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "2.Cetificate :ROHS.ISO9001."
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "3.The outline tolerance is +/-0.2mm."
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "4.The quotation is valid for 10days."
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "5.Delivery Term:EXW"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")

                    sheet.column_widths 10, 15, 15, 15, 10, 25, 10, 10, 10, 25
                end
            end
        end


        p.serialize(path+file_name)
        send_file(path+file_name, type: "application/vnd.ms-excel") and return

    end

    def pi_out_xlsx_moko_c
        @pi_info = PiInfo.find_by_id(params[:id])
        @pi_info_c = PcbCustomer.find_by_id(@pi_info.pcb_customer_id)
        @pi_item = PiItem.where(pi_info_id: params[:id])
        @find_pcb = PiItem.where(pi_info_id: params[:id], p_type: "PCB")

        @pi_other_item = PiOtherItem.where(pi_no: @pi_info.pi_no)
        @total_p = PiItem.where(pi_info_id: params[:id]).sum("t_p") + PiOtherItem.where(pi_no: @pi_info.pi_no).sum("t_p")
        
        file_name = @pi_info.pi_no.to_s + "_out.xlsx"
        path = Rails.root.to_s+"/public/uploads/bom/pi_excel_file/"


        p = Axlsx::Package.new
        p.workbook do |wb|
            wb.styles do |s|
                a_text = s.add_style :b => true,
                                     :sz => 24,
                                     :alignment => { :horizontal => :center,
                                                     :vertical => :center }
                b_text = s.add_style :b => true,
                                     :sz => 20,
                                     :alignment => { :horizontal => :center,
                                                     :vertical => :center }
                c_text = s.add_style :alignment => { :horizontal => :left,
                                                     :vertical => :center,
                                                     :wrap_text => true  }
                d_text = s.add_style :fg_color => "00",
                                     :bg_color => "EEEEEE",
                                     :border => { :style => :thin, :color => "00" },
                                     :alignment => { :horizontal => :center,
                                                     :vertical => :center,
                                                     :wrap_text => true }
                e_text = s.add_style :border => { :style => :thin, :color => "00" },
                                     :alignment => { :horizontal => :center,
                                                     :vertical => :center,
                                                     :wrap_text => true }
                f_text = s.add_style :border => { :style => :thin, :color => "00" },
                                     :alignment => { :horizontal => :left,
                                                     :vertical => :center,
                                                     :wrap_text => true }
                g_text = s.add_style :b => true,
                                     :sz => 12,
                                     :border => { :style => :thin, :color => "00" },
                                     :alignment => { :horizontal => :left,
                                                     :vertical => :center}
                h_text = s.add_style :border => { :style => :thin, :color => "00" },
                                     :alignment => { :horizontal => :left,
                                                     :vertical => :center}
                i_text = s.add_style :b => true,
                                     :sz => 12,
                                     :alignment => { :horizontal => :left,
                                                     :vertical => :center}
                wb.add_worksheet(:name => 'Eastwin') do |sheet|
                    
                    img = File.expand_path(Rails.root.to_s+'/public/uploads/eastwin.png', __FILE__)
                    sheet.add_image(:image_src => img,:alignment => { :horizontal => :right, :vertical => :right }) do |image|
                        image.width=60
                        image.height=60
                        #image.hyperlink.tooltip = "MOKO"
                        image.start_at 2, 0
                    end
                    sheet.add_row ['Shenzhen Eastwin Trading Ltd'], :height => 50, :style => a_text
                    sheet.merge_cells("A1:J1")


                    sheet.add_row ['Proforma Invoice'], :style => b_text
                    sheet.merge_cells("A2:J2")


                    all_ii = []
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "P.I NO.:"
                    all_ii << @pi_info.pi_no.to_s
                    all_ii << ""
                    all_ii << "Date:"
                    all_ii << @pi_info.updated_at.localtime.strftime('%Y/%m/%d').to_s
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b3:d3")
                    sheet.merge_cells("g3:h3")
                    


                    all_ii = []
                    all_ii << "To:"
                    all_ii << @pi_info_c.customer.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "From:"
                    all_ii << current_user.en_name.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b4:d4")
                    sheet.merge_cells("g4:i4")


                    all_ii = []
                    all_ii << "Company:"
                    all_ii << @pi_info_c.customer_com.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "Company:"
                    all_ii << "MOKO TECHNOLOGY LTD"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b5:d5")
                    sheet.merge_cells("g5:i5")


                    all_ii = []
                    all_ii << "Tel:"
                    all_ii << @pi_info_c.tel.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "Tel:"
                    all_ii << current_user.tel
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b6:d6")
                    sheet.merge_cells("g6:i6")


                    all_ii = []
                    all_ii << "Fax:"
                    all_ii << @pi_info_c.fax.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "Fax:"
                    all_ii << current_user.fax
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b7:d7")
                    sheet.merge_cells("g7:i7")


                    all_ii = []
                    all_ii << "E-mail:"
                    all_ii << @pi_info_c.email.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "E-mail:"
                    all_ii << current_user.email
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b8:d8")
                    sheet.merge_cells("g8:i8")




                    all_ii = []
                    all_ii << "Add:"
                    all_ii << @pi_info_c.shipping_address.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "Add:"
                    all_ii << current_user.add
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b9:d9")
                    sheet.merge_cells("g9:j9")



                    all_ii = []
                    all_ii << "NO."
                    all_ii << "Customer Part No."
                    all_ii << "PCB Size(mm)"
                    all_ii << "Quantity(PCS)"
                    all_ii << "Layer"
                    all_ii << "Description"
                    all_ii << "Unit Price"
                    all_ii << ""
                    all_ii << ""
                    all_ii << "Total Price(USD)"
                    sheet.add_row all_ii, :style => d_text
                    sheet.merge_cells("g10:i10")

                    row_set = 10
                    if not @pi_item.blank?     
                        @pi_item.each_with_index do |item,index|
                            row_set = row_set +1
                            all_ii = []
                            all_ii << index + 1
                            all_ii << item.c_p_no.to_s
                            all_ii << item.pcb_size.to_s
                            all_ii << item.qty.to_s
                            all_ii << item.layer.to_s
                            all_ii << item.des.to_s
                            all_ii << item.unit_price.to_s
                            all_ii << ""
                            all_ii << ""
                            all_ii << item.t_p.to_s
                            sheet.add_row all_ii, :style => e_text
                            sheet.merge_cells("g#{row_set}:i#{row_set}")
                        end


                        row_set = row_set +1
                        all_ii = []
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << "Shipping Cost"
                        all_ii << ""
                        all_ii << ""
                        all_ii << @pi_info.pi_shipping_cost.to_s
                        sheet.add_row all_ii, :style => e_text
                        sheet.merge_cells("g#{row_set}:i#{row_set}")
            

                        row_set = row_set +1
                        all_ii = []
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << "Bank Fee"
                        all_ii << ""
                        all_ii << ""
                        all_ii << @pi_info.pi_bank_fee.to_s
                        sheet.add_row all_ii, :style => e_text
                        sheet.merge_cells("g#{row_set}:i#{row_set}")
            

                        row_set = row_set +1
                        all_ii = []
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << "In Total"
                        all_ii << ""
                        all_ii << ""
                        all_ii << @pi_info.t_p.to_s
                        sheet.add_row all_ii, :style => e_text
                        sheet.merge_cells("g#{row_set}:i#{row_set}")

                        row_set = row_set +1
                        all_ii = []
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << "In Total RMB"
                        all_ii << ""
                        all_ii << ""
                        all_ii << @pi_info.t_p_rmb.to_s
                        sheet.add_row all_ii, :style => e_text
                        sheet.merge_cells("g#{row_set}:i#{row_set}")

                    end
             
                    row_set = row_set +1
                    all_ii = []
                        all_ii << "Leadtime: The lead time for PCBA is 20 working days."
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                    sheet.add_row all_ii, :style => f_text
                    sheet.merge_cells("a#{row_set}:j#{row_set}")
                    

                    row_set = row_set +1
                    sheet.add_row


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Bank information:"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => g_text
                    sheet.merge_cells("a#{row_set}:g#{row_set}")


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Account Name : MOKO TECHNOLOGY LIMITED"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => h_text
                    img = File.expand_path(Rails.root.to_s+'/public/uploads/EASTWIN_bank.png', __FILE__)
                    sheet.add_image(:image_src => img) do |image|
                        image.width=400
                        image.height=200
                        #image.hyperlink.tooltip = "MOKO"
                        image.start_at 3, row_set-3
                    end
                    sheet.merge_cells("a#{row_set}:g#{row_set}")


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Bank Account Number ：801144007838"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => h_text
                    sheet.merge_cells("a#{row_set}:g#{row_set}")


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Swift code:HSBCHKHHHKH"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => h_text
                    sheet.merge_cells("a#{row_set}:g#{row_set}")


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Bank  Name ：The Hongkong and Shanghai Banking Corporation Limited"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => h_text
                    sheet.merge_cells("a#{row_set}:g#{row_set}")

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Bank Adress:No.1 Queen’s Road Central ,Hong Kong"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => h_text
                    sheet.merge_cells("a#{row_set}:g#{row_set}")


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Bank Code :  004"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => h_text
                    sheet.merge_cells("a#{row_set}:g#{row_set}")

                    row_set = row_set +1
                    sheet.add_row

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Remark:"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => i_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "The above quotation is based on the following conditions:"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "1.Payment Terms: T/T in advance."
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "2.Cetificate :ROHS.ISO9001."
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "3.The outline tolerance is +/-0.2mm."
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "4.The quotation is valid for 10days."
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")

                    sheet.column_widths 10, 15, 15, 15, 10, 25, 10, 10, 10, 25
                end
            end
        end


        p.serialize(path+file_name)
        send_file(path+file_name, type: "application/vnd.ms-excel") and return

    end

    def pi_out_xlsx_moko_d
        @pi_info = PiInfo.find_by_id(params[:id])
        @pi_info_c = PcbCustomer.find_by_id(@pi_info.pcb_customer_id)
        @pi_item = PiItem.where(pi_info_id: params[:id])
        @find_pcb = PiItem.where(pi_info_id: params[:id], p_type: "PCB")

        @pi_other_item = PiOtherItem.where(pi_no: @pi_info.pi_no)
        @total_p = PiItem.where(pi_info_id: params[:id]).sum("t_p") + PiOtherItem.where(pi_no: @pi_info.pi_no).sum("t_p")
        
        file_name = @pi_info.pi_no.to_s + "_out.xlsx"
        path = Rails.root.to_s+"/public/uploads/bom/pi_excel_file/"


        p = Axlsx::Package.new
        p.workbook do |wb|
            wb.styles do |s|
                a_text = s.add_style :b => true,
                                     :sz => 24,
                                     :alignment => { :horizontal => :center,
                                                     :vertical => :center }
                b_text = s.add_style :b => true,
                                     :sz => 20,
                                     :alignment => { :horizontal => :center,
                                                     :vertical => :center }
                c_text = s.add_style :alignment => { :horizontal => :left,
                                                     :vertical => :center,
                                                     :wrap_text => true  }
                d_text = s.add_style :fg_color => "00",
                                     :bg_color => "EEEEEE",
                                     :border => { :style => :thin, :color => "00" },
                                     :alignment => { :horizontal => :center,
                                                     :vertical => :center,
                                                     :wrap_text => true }
                e_text = s.add_style :border => { :style => :thin, :color => "00" },
                                     :alignment => { :horizontal => :center,
                                                     :vertical => :center,
                                                     :wrap_text => true }
                f_text = s.add_style :border => { :style => :thin, :color => "00" },
                                     :alignment => { :horizontal => :left,
                                                     :vertical => :center,
                                                     :wrap_text => true }
                g_text = s.add_style :b => true,
                                     :sz => 12,
                                     :border => { :style => :thin, :color => "00" },
                                     :alignment => { :horizontal => :left,
                                                     :vertical => :center}
                h_text = s.add_style :border => { :style => :thin, :color => "00" },
                                     :alignment => { :horizontal => :left,
                                                     :vertical => :center}
                i_text = s.add_style :b => true,
                                     :sz => 12,
                                     :alignment => { :horizontal => :left,
                                                     :vertical => :center}
                wb.add_worksheet(:name => 'Eastwin') do |sheet|
                    
                    img = File.expand_path(Rails.root.to_s+'/public/uploads/eastwin.png', __FILE__)
                    sheet.add_image(:image_src => img,:alignment => { :horizontal => :right, :vertical => :right }) do |image|
                        image.width=60
                        image.height=60
                        #image.hyperlink.tooltip = "MOKO"
                        image.start_at 2, 0
                    end
                    sheet.add_row ['Shenzhen Eastwin Trading Ltd'], :height => 50, :style => a_text
                    sheet.merge_cells("A1:J1")


                    sheet.add_row ['Proforma Invoice'], :style => b_text
                    sheet.merge_cells("A2:J2")


                    all_ii = []
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "P.I NO.:"
                    all_ii << @pi_info.pi_no.to_s
                    all_ii << ""
                    all_ii << "Date:"
                    all_ii << @pi_info.updated_at.localtime.strftime('%Y/%m/%d').to_s
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b3:d3")
                    sheet.merge_cells("g3:h3")
                    


                    all_ii = []
                    all_ii << "To:"
                    all_ii << @pi_info_c.customer.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "From:"
                    all_ii << current_user.en_name.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b4:d4")
                    sheet.merge_cells("g4:i4")


                    all_ii = []
                    all_ii << "Company:"
                    all_ii << @pi_info_c.customer_com.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "Company:"
                    all_ii << "MOKO TECHNOLOGY LTD"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b5:d5")
                    sheet.merge_cells("g5:i5")


                    all_ii = []
                    all_ii << "Tel:"
                    all_ii << @pi_info_c.tel.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "Tel:"
                    all_ii << current_user.tel
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b6:d6")
                    sheet.merge_cells("g6:i6")


                    all_ii = []
                    all_ii << "Fax:"
                    all_ii << @pi_info_c.fax.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "Fax:"
                    all_ii << current_user.fax
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b7:d7")
                    sheet.merge_cells("g7:i7")


                    all_ii = []
                    all_ii << "E-mail:"
                    all_ii << @pi_info_c.email.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "E-mail:"
                    all_ii << current_user.email
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b8:d8")
                    sheet.merge_cells("g8:i8")




                    all_ii = []
                    all_ii << "Add:"
                    all_ii << @pi_info_c.shipping_address.to_s
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << "Add:"
                    all_ii << current_user.add
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("b9:d9")
                    sheet.merge_cells("g9:j9")



                    all_ii = []
                    all_ii << "NO."
                    all_ii << "Customer Part No."
                    all_ii << "PCB Size(mm)"
                    all_ii << "Quantity(PCS)"
                    all_ii << "Layer"
                    all_ii << "Description"
                    all_ii << "PCB Price"
                    all_ii << "Components Price"
                    all_ii << "PCBA"
                    all_ii << "Total Price(USD)"
                    sheet.add_row all_ii, :style => d_text
                    #sheet.merge_cells("g10:i10")

                    row_set = 10
                    if not @pi_item.blank?     
                        @pi_item.each_with_index do |item,index|
                            row_set = row_set +1
                            all_ii = []
                            all_ii << index + 1
                            all_ii << item.c_p_no.to_s
                            all_ii << item.pcb_size.to_s
                            all_ii << item.qty.to_s
                            all_ii << item.layer.to_s
                            all_ii << item.des.to_s
                            all_ii << item.pcb_price.to_s
                            all_ii << item.com_cost.to_s
                            all_ii << item.pcba.to_s
                            all_ii << item.t_p.to_s
                            sheet.add_row all_ii, :style => e_text
                            #sheet.merge_cells("g#{row_set}:i#{row_set}")
                        end

=begin
                        row_set = row_set +1
                        all_ii = []
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << "Shipping Cost"
                        all_ii << ""
                        all_ii << ""
                        all_ii << @pi_info.pi_shipping_cost.to_s
                        sheet.add_row all_ii, :style => e_text
                        sheet.merge_cells("g#{row_set}:i#{row_set}")
            

                        row_set = row_set +1
                        all_ii = []
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << "Bank Fee"
                        all_ii << ""
                        all_ii << ""
                        all_ii << @pi_info.pi_bank_fee.to_s
                        sheet.add_row all_ii, :style => e_text
                        sheet.merge_cells("g#{row_set}:i#{row_set}")
=end            

                        row_set = row_set +1
                        all_ii = []
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << "In Total USD"
                        all_ii << ""
                        all_ii << ""
                        all_ii << @pi_info.t_p.to_s
                        sheet.add_row all_ii, :style => e_text
                        sheet.merge_cells("g#{row_set}:i#{row_set}")

                        row_set = row_set +1
                        all_ii = []
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << "In Total RMB"
                        all_ii << ""
                        all_ii << ""
                        all_ii << @pi_info.t_p_rmb.to_s
                        sheet.add_row all_ii, :style => e_text
                        sheet.merge_cells("g#{row_set}:i#{row_set}")
                    end
             
                    row_set = row_set +1
                    all_ii = []
                        all_ii << "Leadtime: The lead time for PCBA is 20 working days."
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                        all_ii << ""
                    sheet.add_row all_ii, :style => f_text
                    sheet.merge_cells("a#{row_set}:j#{row_set}")
                    

                    row_set = row_set +1
                    sheet.add_row


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Bank RMB Information:"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => g_text
                    sheet.merge_cells("a#{row_set}:g#{row_set}")


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Bank account:	6241 8578 0704 4682"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => h_text
                    img = File.expand_path(Rails.root.to_s+'/public/uploads/EASTWIN_bank.png', __FILE__)
                    sheet.add_image(:image_src => img) do |image|
                        image.width=400
                        image.height=200
                        #image.hyperlink.tooltip = "MOKO"
                        image.start_at 3, row_set-5
                    end
                    sheet.merge_cells("a#{row_set}:g#{row_set}")


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Name:	黄丽娟 Huang Li Juan"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => h_text
                    sheet.merge_cells("a#{row_set}:g#{row_set}")


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Bank Name: 深圳招行梅龙支行"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => h_text
                    sheet.merge_cells("a#{row_set}:g#{row_set}")

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "Remark:"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => i_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "The above quotation is based on the following conditions:"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")


                    row_set = row_set +1
                    all_ii = []
                    all_ii << "1.Payment Terms: T/T in advance."
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "2.Cetificate :ROHS.ISO9001."
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "3.The outline tolerance is +/-0.2mm."
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "4.The quotation is valid for 10days."
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")

                    row_set = row_set +1
                    all_ii = []
                    all_ii << "5.Delivery Term:EXW"
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    all_ii << ""
                    sheet.add_row all_ii, :style => c_text
                    sheet.merge_cells("a#{row_set}:d#{row_set}")

                    sheet.column_widths 10, 15, 15, 15, 10, 25, 10, 10, 10, 25
                end
            end
        end


        p.serialize(path+file_name)
        send_file(path+file_name, type: "application/vnd.ms-excel") and return

    end

    def pi_out_excel
        @pi_info = PiInfo.find_by_id(params[:id])
        @pi_info_c = PcbCustomer.find_by_id(@pi_info.pcb_customer_id)
        @pi_item = PiItem.where(pi_info_id: params[:id])
        @find_pcb = PiItem.where(pi_info_id: params[:id], p_type: "PCB")
        #if not @find_pcb.blank?
            #@pi_pcb = PcbItemInfo.find_by_pcb_order_item_id(find_pcb.first.find_pcb.order_item_id)
        #end
        @pi_other_item = PiOtherItem.where(pi_no: @pi_info.pi_no)
        @total_p = PiItem.where(pi_info_id: params[:id]).sum("t_p") + PiOtherItem.where(pi_no: @pi_info.pi_no).sum("t_p")
        
        file_name = @pi_info.pi_no.to_s + "_out.xls"
        path = Rails.root.to_s+"/public/uploads/bom/pi_excel_file/"
        Spreadsheet.client_encoding = 'UTF-8'
	ff = Spreadsheet::Workbook.new
        sheet1 = ff.create_worksheet
 
        #all_title = [] 
        #all_title << "MPN"
        #sheet1.row(0).concat all_title   
        top_format = Spreadsheet::Format.new(:horizontal_align => :centre,:size => 24,:weight => :bold)
        sheet1.merge_cells(0,0,0,9)  
        sheet1.row(0).push("MOKO Technology Ltd") 
        sheet1.row(0).default_format = top_format 

        two_format = Spreadsheet::Format.new(:horizontal_align => :centre,:size => 20,:weight => :bold)
        sheet1.merge_cells(1,0,1,9)  
        sheet1.row(1).push("Proforma Invoice") 
        sheet1.row(1).default_format = two_format 

        sheet1.merge_cells(2,1,2,3)
        sheet1.merge_cells(2,6,2,7)
        all_ii = []
        all_ii << ""
        all_ii << ""
        all_ii << ""
        all_ii << ""
        all_ii << ""
        all_ii << "P.I NO.:"
        all_ii << @pi_info.pi_no.to_s
        all_ii << ""
        all_ii << "Date:"
        all_ii << @pi_info.updated_at.localtime.strftime('%Y/%m/%d').to_s
        sheet1.row(2).concat all_ii


        sheet1.merge_cells(3,1,3,3)
        sheet1.merge_cells(3,6,3,8)
        all_ii = []
        all_ii << "To:"
        all_ii << @pi_info_c.customer.to_s
        all_ii << ""
        all_ii << ""
        all_ii << ""
        all_ii << "From:"
        all_ii << current_user.en_name.to_s
        all_ii << ""
        all_ii << ""
        all_ii << ""
        sheet1.row(3).concat all_ii

        sheet1.merge_cells(4,1,4,3)
        sheet1.merge_cells(4,6,4,7)
        all_ii = []
        all_ii << "Company:"
        all_ii << @pi_info_c.customer_com.to_s
        all_ii << ""
        all_ii << ""
        all_ii << ""
        all_ii << "Company:"
        all_ii << "MOKO TECHNOLOGY LTD"
        all_ii << ""
        all_ii << ""
        all_ii << ""
        sheet1.row(4).concat all_ii

        sheet1.merge_cells(5,1,5,3)
        sheet1.merge_cells(5,6,5,8)
        all_ii = []
        all_ii << "Tel:"
        all_ii << @pi_info_c.tel.to_s
        all_ii << ""
        all_ii << ""
        all_ii << ""
        all_ii << "Tel:"
        all_ii << current_user.tel
        all_ii << ""
        all_ii << ""
        all_ii << ""
        sheet1.row(5).concat all_ii


        sheet1.merge_cells(6,1,6,3)
        sheet1.merge_cells(6,6,6,8)
        all_ii = []
        all_ii << "Fax:"
        all_ii << @pi_info_c.fax.to_s
        all_ii << ""
        all_ii << ""
        all_ii << ""
        all_ii << "Fax:"
        all_ii << current_user.fax
        all_ii << ""
        all_ii << ""
        all_ii << ""
        sheet1.row(6).concat all_ii


        sheet1.merge_cells(7,1,7,3)
        sheet1.merge_cells(7,6,7,8)
        all_ii = []
        all_ii << "E-mail:"
        all_ii << @pi_info_c.email.to_s
        all_ii << ""
        all_ii << ""
        all_ii << ""
        all_ii << "E-mail:"
        all_ii << current_user.email
        all_ii << ""
        all_ii << ""
        all_ii << ""
        sheet1.row(7).concat all_ii

        sheet1.merge_cells(8,1,8,3)
        sheet1.merge_cells(8,6,8,9)
        all_ii = []
        all_ii << "Add:"
        all_ii << @pi_info_c.shipping_address.to_s
        all_ii << ""
        all_ii << ""
        all_ii << ""
        all_ii << "Add:"
        all_ii << current_user.add
        all_ii << ""
        all_ii << ""
        all_ii << ""
        sheet1.row(8).concat all_ii
        sheet1.row(8).height = 40
        eight_format = Spreadsheet::Format.new(:text_wrap => 1,:align => :left,:vertical_align => :middle)  
        sheet1.row(8).default_format = eight_format


        sheet1.merge_cells(9,6,9,8)
        all_ii = []
        all_ii << "NO."
        all_ii << "Customer Part No."
        all_ii << "PCB Size(mm)"
        all_ii << "Quantity(PCS)"
        all_ii << "Layer"
        all_ii << "Description"
        all_ii << "Unit Price"
        all_ii << ""
        all_ii << ""
        all_ii << "Total Price(USD)"
        sheet1.row(9).concat all_ii
        sheet1.row(9).height = 20
        sheet1.column(1).width = 20
        sheet1.column(2).width = 20
        sheet1.column(3).width = 20
        sheet1.column(5).width = 25
        sheet1.column(9).width = 25
        night_format = Spreadsheet::Format.new(:horizontal_align => :centre,:vertical_align => :middle,:pattern_fg_color => :silver,:color => :black,:pattern => 1,:border => :thin,:border_color => :black)  
        #sheet1.row(9).default_format = night_format
        sheet1.row(9).set_format(0,night_format)
        sheet1.row(9).set_format(1,night_format)
        sheet1.row(9).set_format(2,night_format)
        sheet1.row(9).set_format(3,night_format)
        sheet1.row(9).set_format(4,night_format)
        sheet1.row(9).set_format(5,night_format)
        sheet1.row(9).set_format(6,night_format)
        sheet1.row(9).set_format(7,night_format)
        sheet1.row(9).set_format(8,night_format)
        sheet1.row(9).set_format(9,night_format)
        
        row_set = 9
        if not @pi_item.blank?     
            @pi_item.each_with_index do |item,index|
                row_set = row_set +1
                sheet1.merge_cells(row_set,6,row_set,8)
                all_ii = []
                all_ii << index + 1
                all_ii << item.c_p_no.to_s
                all_ii << item.pcb_size.to_s
                all_ii << item.qty.to_s
                all_ii << item.layer.to_s
                all_ii << item.des.to_s
                all_ii << item.unit_price.to_s
                all_ii << ""
                all_ii << ""
                all_ii << item.t_p.to_s
                sheet1.row(row_set).concat all_ii
                ss_format = Spreadsheet::Format.new(:horizontal_align => :centre,:vertical_align => :middle,:pattern_fg_color => :white,:color => :black,:pattern => 1,:border => :thin,:border_color => :black,:text_wrap => 1)
                sheet1.row(row_set).set_format(0,ss_format)
                sheet1.row(row_set).set_format(1,ss_format)
                sheet1.row(row_set).set_format(2,ss_format)
                sheet1.row(row_set).set_format(3,ss_format)
                sheet1.row(row_set).set_format(4,ss_format)
                sheet1.row(row_set).set_format(5,ss_format)
                sheet1.row(row_set).set_format(6,ss_format)
                sheet1.row(row_set).set_format(7,ss_format)
                sheet1.row(row_set).set_format(8,ss_format)
                sheet1.row(row_set).set_format(9,ss_format)
            end
            row_set = row_set +1
            sheet1.merge_cells(row_set,6,row_set,8)
            all_ii = []
            all_ii << ""
            all_ii << ""
            all_ii << ""
            all_ii << ""
            all_ii << ""
            all_ii << ""
            all_ii << "Shipping Cost"
            all_ii << ""
            all_ii << ""
            all_ii << @pi_info.pi_shipping_cost.to_s
            sheet1.row(row_set).concat all_ii
            ss_format = Spreadsheet::Format.new(:horizontal_align => :centre,:vertical_align => :middle,:pattern_fg_color => :white,:color => :black,:pattern => 1,:border => :thin,:border_color => :black,:text_wrap => 1)
            sheet1.row(row_set).set_format(0,ss_format)
            sheet1.row(row_set).set_format(1,ss_format)
            sheet1.row(row_set).set_format(2,ss_format)
            sheet1.row(row_set).set_format(3,ss_format)
            sheet1.row(row_set).set_format(4,ss_format)
            sheet1.row(row_set).set_format(5,ss_format)
            sheet1.row(row_set).set_format(6,ss_format)
            sheet1.row(row_set).set_format(7,ss_format)
            sheet1.row(row_set).set_format(8,ss_format)
            sheet1.row(row_set).set_format(9,ss_format)

            row_set = row_set +1
            sheet1.merge_cells(row_set,6,row_set,8)
            all_ii = []
            all_ii << ""
            all_ii << ""
            all_ii << ""
            all_ii << ""
            all_ii << ""
            all_ii << ""
            all_ii << "Bank Fee"
            all_ii << ""
            all_ii << ""
            all_ii << @pi_info.pi_bank_fee.to_s
            sheet1.row(row_set).concat all_ii
            ss_format = Spreadsheet::Format.new(:horizontal_align => :centre,:vertical_align => :middle,:pattern_fg_color => :white,:color => :black,:pattern => 1,:border => :thin,:border_color => :black,:text_wrap => 1)
            sheet1.row(row_set).set_format(0,ss_format)
            sheet1.row(row_set).set_format(1,ss_format)
            sheet1.row(row_set).set_format(2,ss_format)
            sheet1.row(row_set).set_format(3,ss_format)
            sheet1.row(row_set).set_format(4,ss_format)
            sheet1.row(row_set).set_format(5,ss_format)
            sheet1.row(row_set).set_format(6,ss_format)
            sheet1.row(row_set).set_format(7,ss_format)
            sheet1.row(row_set).set_format(8,ss_format)
            sheet1.row(row_set).set_format(9,ss_format)

            row_set = row_set +1
            sheet1.merge_cells(row_set,6,row_set,8)
            all_ii = []
            all_ii << ""
            all_ii << ""
            all_ii << ""
            all_ii << ""
            all_ii << ""
            all_ii << ""
            all_ii << "Total"
            all_ii << ""
            all_ii << ""
            all_ii << @pi_info.t_p.to_s
            sheet1.row(row_set).concat all_ii
            ss_format = Spreadsheet::Format.new(:horizontal_align => :centre,:vertical_align => :middle,:pattern_fg_color => :white,:color => :black,:pattern => 1,:border => :thin,:border_color => :black,:text_wrap => 1)
            sheet1.row(row_set).set_format(0,ss_format)
            sheet1.row(row_set).set_format(1,ss_format)
            sheet1.row(row_set).set_format(2,ss_format)
            sheet1.row(row_set).set_format(3,ss_format)
            sheet1.row(row_set).set_format(4,ss_format)
            sheet1.row(row_set).set_format(5,ss_format)
            sheet1.row(row_set).set_format(6,ss_format)
            sheet1.row(row_set).set_format(7,ss_format)
            sheet1.row(row_set).set_format(8,ss_format)
            sheet1.row(row_set).set_format(9,ss_format)
        end
        
        row_set = row_set +1
        ss_format = Spreadsheet::Format.new(:pattern_fg_color => :white,:color => :black,:pattern => 1,:border => :thin,:border_color => :black,:text_wrap => 1,:vertical_align => :middle)
        sheet1.merge_cells(row_set,0,row_set,9)  
        sheet1.row(row_set).push("Leadtime: The lead time for PCBA is 20 working days.")
        sheet1.row(row_set).set_format(0,ss_format)
        sheet1.row(row_set).set_format(1,ss_format)
        sheet1.row(row_set).set_format(2,ss_format)
        sheet1.row(row_set).set_format(3,ss_format)
        sheet1.row(row_set).set_format(4,ss_format)
        sheet1.row(row_set).set_format(5,ss_format)
        sheet1.row(row_set).set_format(6,ss_format)
        sheet1.row(row_set).set_format(7,ss_format)
        sheet1.row(row_set).set_format(8,ss_format)
        sheet1.row(row_set).set_format(9,ss_format)

        row_set = row_set +1

        row_set = row_set +1
        ss_format = Spreadsheet::Format.new(:pattern_fg_color => :white,:color => :black,:pattern => 1,:border => :thin,:border_color => :black,:text_wrap => 1,:vertical_align => :middle,:size => 12,:weight => :bold)
        sheet1.merge_cells(row_set,0,row_set,6)  
        sheet1.row(row_set).push("Bank information:")
        sheet1.row(row_set).set_format(0,ss_format)
        sheet1.row(row_set).set_format(1,ss_format)
        sheet1.row(row_set).set_format(2,ss_format)
        sheet1.row(row_set).set_format(3,ss_format)
        sheet1.row(row_set).set_format(4,ss_format)
        sheet1.row(row_set).set_format(5,ss_format)
        sheet1.row(row_set).set_format(6,ss_format)

        row_set = row_set +1
        ss_format = Spreadsheet::Format.new(:pattern_fg_color => :white,:color => :black,:pattern => 1,:border => :thin,:border_color => :black,:text_wrap => 1,:vertical_align => :middle,:size => 10)
        sheet1.merge_cells(row_set,0,row_set,6)  
        sheet1.row(row_set).push("Account Name : MOKO TECHNOLOGY LIMITED")
        sheet1.row(row_set).set_format(0,ss_format)
        sheet1.row(row_set).set_format(1,ss_format)
        sheet1.row(row_set).set_format(2,ss_format)
        sheet1.row(row_set).set_format(3,ss_format)
        sheet1.row(row_set).set_format(4,ss_format)
        sheet1.row(row_set).set_format(5,ss_format)
        sheet1.row(row_set).set_format(6,ss_format)

        row_set = row_set +1
        ss_format = Spreadsheet::Format.new(:pattern_fg_color => :white,:color => :black,:pattern => 1,:border => :thin,:border_color => :black,:text_wrap => 1,:vertical_align => :middle,:size => 10)
        sheet1.merge_cells(row_set,0,row_set,6)  
        sheet1.row(row_set).push("Bank Account Number ：801144007838")
        sheet1.row(row_set).set_format(0,ss_format)
        sheet1.row(row_set).set_format(1,ss_format)
        sheet1.row(row_set).set_format(2,ss_format)
        sheet1.row(row_set).set_format(3,ss_format)
        sheet1.row(row_set).set_format(4,ss_format)
        sheet1.row(row_set).set_format(5,ss_format)
        sheet1.row(row_set).set_format(6,ss_format)

        row_set = row_set +1
        ss_format = Spreadsheet::Format.new(:pattern_fg_color => :white,:color => :black,:pattern => 1,:border => :thin,:border_color => :black,:text_wrap => 1,:vertical_align => :middle,:size => 10)
        sheet1.merge_cells(row_set,0,row_set,6)  
        sheet1.row(row_set).push("Swift code:HSBCHKHHHKH")
        sheet1.row(row_set).set_format(0,ss_format)
        sheet1.row(row_set).set_format(1,ss_format)
        sheet1.row(row_set).set_format(2,ss_format)
        sheet1.row(row_set).set_format(3,ss_format)
        sheet1.row(row_set).set_format(4,ss_format)
        sheet1.row(row_set).set_format(5,ss_format)
        sheet1.row(row_set).set_format(6,ss_format)

        row_set = row_set +1
        ss_format = Spreadsheet::Format.new(:pattern_fg_color => :white,:color => :black,:pattern => 1,:border => :thin,:border_color => :black,:text_wrap => 1,:vertical_align => :middle,:size => 10)
        sheet1.merge_cells(row_set,0,row_set,6)  
        sheet1.row(row_set).push("Bank  Name ：The Hongkong and Shanghai Banking Corporation Limited")
        sheet1.row(row_set).set_format(0,ss_format)
        sheet1.row(row_set).set_format(1,ss_format)
        sheet1.row(row_set).set_format(2,ss_format)
        sheet1.row(row_set).set_format(3,ss_format)
        sheet1.row(row_set).set_format(4,ss_format)
        sheet1.row(row_set).set_format(5,ss_format)
        sheet1.row(row_set).set_format(6,ss_format)

        row_set = row_set +1
        ss_format = Spreadsheet::Format.new(:pattern_fg_color => :white,:color => :black,:pattern => 1,:border => :thin,:border_color => :black,:text_wrap => 1,:vertical_align => :middle,:size => 10)
        sheet1.merge_cells(row_set,0,row_set,6)  
        sheet1.row(row_set).push("Bank Adress:No.1 Queen’s Road Central ,Hong Kong")
        sheet1.row(row_set).set_format(0,ss_format)
        sheet1.row(row_set).set_format(1,ss_format)
        sheet1.row(row_set).set_format(2,ss_format)
        sheet1.row(row_set).set_format(3,ss_format)
        sheet1.row(row_set).set_format(4,ss_format)
        sheet1.row(row_set).set_format(5,ss_format)
        sheet1.row(row_set).set_format(6,ss_format)


        row_set = row_set +1
        ss_format = Spreadsheet::Format.new(:pattern_fg_color => :white,:color => :black,:pattern => 1,:border => :thin,:border_color => :black,:text_wrap => 1,:vertical_align => :middle,:size => 10)
        sheet1.merge_cells(row_set,0,row_set,6)  
        sheet1.row(row_set).push("Bank Code :  004")
        sheet1.row(row_set).set_format(0,ss_format)
        sheet1.row(row_set).set_format(1,ss_format)
        sheet1.row(row_set).set_format(2,ss_format)
        sheet1.row(row_set).set_format(3,ss_format)
        sheet1.row(row_set).set_format(4,ss_format)
        sheet1.row(row_set).set_format(5,ss_format)
        sheet1.row(row_set).set_format(6,ss_format)

        row_set = row_set +1

        row_set = row_set +1
        ss_format = Spreadsheet::Format.new(:text_wrap => 1,:size => 12,:weight => :bold)
        sheet1.merge_cells(row_set,0,row_set,3)  
        sheet1.row(row_set).push("Remark:")
        sheet1.row(row_set).set_format(0,ss_format)
        sheet1.row(row_set).set_format(1,ss_format)
        sheet1.row(row_set).set_format(2,ss_format)
        sheet1.row(row_set).set_format(3,ss_format)
        sheet1.row(row_set).set_format(4,ss_format)
        sheet1.row(row_set).set_format(5,ss_format)
        sheet1.row(row_set).set_format(6,ss_format)

        row_set = row_set +1
        ss_format = Spreadsheet::Format.new(:size => 10)
        sheet1.merge_cells(row_set,0,row_set,3)  
        sheet1.row(row_set).push("The above quotation is based on the following conditions:")
        sheet1.row(row_set).set_format(0,ss_format)
        sheet1.row(row_set).set_format(1,ss_format)
        sheet1.row(row_set).set_format(2,ss_format)
        sheet1.row(row_set).set_format(3,ss_format)
        sheet1.row(row_set).set_format(4,ss_format)
        sheet1.row(row_set).set_format(5,ss_format)
        sheet1.row(row_set).set_format(6,ss_format)

        row_set = row_set +1
        ss_format = Spreadsheet::Format.new(:size => 10)
        sheet1.merge_cells(row_set,0,row_set,3)  
        sheet1.row(row_set).push("1.Payment Terms: T/T in advance.")
        sheet1.row(row_set).set_format(0,ss_format)
        sheet1.row(row_set).set_format(1,ss_format)
        sheet1.row(row_set).set_format(2,ss_format)
        sheet1.row(row_set).set_format(3,ss_format)
        sheet1.row(row_set).set_format(4,ss_format)
        sheet1.row(row_set).set_format(5,ss_format)
        sheet1.row(row_set).set_format(6,ss_format)

        row_set = row_set +1
        ss_format = Spreadsheet::Format.new(:size => 10)
        sheet1.merge_cells(row_set,0,row_set,3)  
        sheet1.row(row_set).push("2.Cetificate :ROHS.ISO9001.")
        sheet1.row(row_set).set_format(0,ss_format)
        sheet1.row(row_set).set_format(1,ss_format)
        sheet1.row(row_set).set_format(2,ss_format)
        sheet1.row(row_set).set_format(3,ss_format)
        sheet1.row(row_set).set_format(4,ss_format)
        sheet1.row(row_set).set_format(5,ss_format)
        sheet1.row(row_set).set_format(6,ss_format)

        row_set = row_set +1
        ss_format = Spreadsheet::Format.new(:size => 10)
        sheet1.merge_cells(row_set,0,row_set,3)  
        sheet1.row(row_set).push("3.The outline tolerance is +/-0.2mm.")
        sheet1.row(row_set).set_format(0,ss_format)
        sheet1.row(row_set).set_format(1,ss_format)
        sheet1.row(row_set).set_format(2,ss_format)
        sheet1.row(row_set).set_format(3,ss_format)
        sheet1.row(row_set).set_format(4,ss_format)
        sheet1.row(row_set).set_format(5,ss_format)
        sheet1.row(row_set).set_format(6,ss_format)

        row_set = row_set +1
        ss_format = Spreadsheet::Format.new(:size => 10)
        sheet1.merge_cells(row_set,0,row_set,3)  
        sheet1.row(row_set).push("4.The quotation is valid for 10days.")
        sheet1.row(row_set).set_format(0,ss_format)
        sheet1.row(row_set).set_format(1,ss_format)
        sheet1.row(row_set).set_format(2,ss_format)
        sheet1.row(row_set).set_format(3,ss_format)
        sheet1.row(row_set).set_format(4,ss_format)
        sheet1.row(row_set).set_format(5,ss_format)
        sheet1.row(row_set).set_format(6,ss_format)



        ff.write (path+file_name)   
        send_file(path+file_name, type: "application/vnd.ms-excel") and return
    end

    def edit_user_info
        get_user = User.find_by_email(current_user.email)
        get_user.en_name = params[:edit_en_name]
        get_user.tel = params[:edit_tel]
        get_user.fax = params[:edit_fax]
        get_user.add = params[:edit_add]
        get_user.save
        redirect_to :back
    end

    def edit_c_info
        get_c = PcbCustomer.find_by_id(params[:edit_c_id])
        get_c.customer = params[:edit_c_customer]
        get_c.customer_com = params[:edit_c_customer_com]
        get_c.tel = params[:edit_c_tel]
        get_c.fax = params[:edit_c_fax]
        get_c.email = params[:edit_c_email]
        get_c.shipping_address = params[:edit_c_add]
        get_c.save
        redirect_to :back
    end

    def wh_in
        
    end



    def wh_query
        if params[:moko_part]
            if params[:moko_part] != ""
                #@find_in_wh = WarehouseInfo.find_by_moko_part(params[:moko_part].strip)
                @find_in_wh = WarehouseInfo.where("moko_des LIKE '%#{params[:moko_part].strip}%'")
            else
                @find_in_wh = WarehouseInfo.all
            end
            
=begin
            if @find_in_wh.blank?
                find_in_product = Product.find_by_name(params[:moko_part].strip)
                if not find_in_product.blank?
                    @find_in_wh = WarehouseInfo.new
                    @find_in_wh.moko_part = find_in_product.name
                    @find_in_wh.moko_des = find_in_product.description
                    @find_in_wh.qty = 0
                    @find_in_wh.save
                    #redirect_to :back and return
                    render "wh_query.html.erb" and return
                else
                    redirect_to wh_query_path, :flash => {:error => params[:moko_part].to_s.strip+"--------请输入正确的MOKO Part,或者联系BOM工程师！"}
                    return false
                end
            else
                #redirect_to :back and return
                render "wh_query.html.erb" and return
            end
=end
        end
    end
  
    def wh_find

    end

    def p_wh_in
        if can? :work_wh, :all          
            Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
            Rails.logger.info(params["qty_in"].inspect)
            Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
            find_wh = PiWhItem.find_by_moko_part(params[:moko_part].strip)
            if not find_wh.blank?
                find_wh.qty = find_wh.qty + params["qty_in"].to_i
                #find_wh.save
            else 
                find_wh = PiWhItem.new
                #find_wh.pmc_flag = ""
                find_wh.moko_part = params[:moko_part].strip
                find_wh.moko_des = params[:moko_des].strip
                find_wh.qty = params[:qty_in]
                #find_wh.save
            end
            if find_wh.save
                item_data = PiBuyItem.find_by_id(params[:buy_id])
                if not item_data.blank?
                    add_buy_data = PiBuyHistoryItem.new
                    add_buy_data.wh_qty_in = params[:qty_in]
                    add_buy_data.p_item_id = item_data.id
                    add_buy_data.erp_id = item_data.erp_id
                    add_buy_data.erp_no = item_data.erp_no
                    add_buy_data.user_do = item_data.user_do
                    add_buy_data.user_do_change = item_data.user_do_change
                    add_buy_data.check = item_data.check
                    add_buy_data.pi_buy_info_id = params[:pi_buy_id]
                    add_buy_data.procurement_bom_id = item_data.procurement_bom_id
                    add_buy_data.quantity = item_data.quantity
                    add_buy_data.qty = item_data.quantity*ProcurementBom.find(item_data.procurement_bom_id).qty
                    add_buy_data.description = item_data.description
                    add_buy_data.part_code = item_data.part_code
                    add_buy_data.fengzhuang = item_data.fengzhuang
                    add_buy_data.link = item_data.link
                    add_buy_data.cost = item_data.cost
                    add_buy_data.info = item_data.info
                    add_buy_data.product_id = item_data.product_id
                    add_buy_data.moko_part = item_data.moko_part
                    add_buy_data.moko_des = item_data.moko_des
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
                    add_buy_data.remark = item_data.remark
                    add_buy_data.color = item_data.color
                    add_buy_data.supplier_tag = item_data.supplier_tag
                    add_buy_data.supplier_out_tag = item_data.supplier_out_tag
                    add_buy_data.sell_feed_back_tag = item_data.sell_feed_back_tag
                end
            end
            render "p_wh_in.js.erb"
        else
            render plain: "You don't have permission to view this page !"
        end
    end

    def wh_draft_list
        #@whlist = PiWhInfo.where(state: "new",wh_user: current_user.email).order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
        @whlist = PiWhInfo.where(wh_user: current_user.email).order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
    end

    def wh_draft_change_list
        @whlist = PiWhChangeInfo.where(wh_user: current_user.email).order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
    end

    def new_wh_change_order
        if params[:wh_no] == "" or params[:wh_no] == nil
            if PiWhChangeInfo.find_by_sql('SELECT pi_wh_change_no FROM pi_wh_change_infos WHERE to_days(pi_wh_change_infos.created_at) = to_days(NOW())').blank?
                pi_n =1
            else
                pi_n = PiWhChangeInfo.find_by_sql('SELECT pi_wh_change_no FROM pi_wh_change_infos WHERE to_days(pi_wh_change_infos.created_at) = to_days(NOW())').last.pi_wh_change_no.split("WH")[-1].to_i + 1
            end
            @wh_no = "MO"+current_user.s_name_self.to_s.upcase  + Time.new.strftime('%y').to_s + Time.new.strftime('%m%d').to_s + "WH"+ pi_n.to_s

            wh_info = PiWhChangeInfo.new
            wh_info.pi_wh_change_no = @wh_no
            wh_info.wh_user = current_user.email
            wh_info.state = "new"
            #wh_info.site = "c"            
            wh_info.save
            pi_wh_change_no = wh_info.pi_wh_change_no
        else
            pi_wh_change_no = params[:wh_no]
        end
        #@pcblist = PcbOrder.where(state: "quotechk").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
        redirect_to edit_wh_change_order_path(pi_wh_change_no: pi_wh_change_no) and return
    end

    def edit_wh_change_order
        @wh_info = PiWhChangeInfo.find_by(pi_wh_change_no: params[:pi_wh_change_no])
        @wh_item = PiWhChangeItem.where(pi_wh_change_info_no: params[:pi_wh_change_no])
        @all_dn = "[&quot;"
        all_s_dn = AllDn.find_by_sql("SELECT DISTINCT all_dns.dn_long FROM all_dns GROUP BY all_dns.dn")
        all_s_dn.each do |dn|
            @all_dn += "&quot;,&quot;" + dn.dn_long.to_s
        end
        @all_dn += "&quot;]"
    end

    def del_wh_change
        wh_order = PiWhChangeInfo.find(params[:wh_change_id])
        if can? :work_wh, :all
            wh_order.destroy
        end
        redirect_to :back
    end

    def del_wh_change_item
        del_wh_item = PiWhChangeItem.find_by_id(params[:del_wh_change_item_id])
        if not del_wh_item.blank?
            if can? :work_wh, :all
                del_wh_item.save
            end
        end
        redirect_to :back
    end

    def find_w_wh_change
        if params[:pi_wh_info] != ""
            where_wh = "moko_part LIKE '%#{params[:pi_wh_info].strip}%' OR moko_des LIKE '%#{params[:pi_wh_info].strip}%'" 
            @w_part = ""
            @w_part += '<small>'
            @w_part += '<table class="table table-bordered">'
            @w_part += '<thead>'
            @w_part += '<tr class="active">'
            @w_part += '<th width="120">物料编码</th>'
            @w_part += '<th >物料描述</th>'
            @w_part += '<th >总量</th>'
            @w_part += '<th >库存</th>'
            @w_part += '<th >工厂数量</th>'
            @w_part += '<th >公司总量</th>'
            @w_part += '<th >流转数量</th>'
            @w_part += '<tr>'
            @w_part += '</thead>'
            @w_part += '<tbody>'
            @w_wh_change = WarehouseInfo.where("#{where_wh}")
            if not @w_wh_change.blank?
                @w_wh_change.each do |wh_change|                                   
                            @w_part += '<tr id="wh_change_'+wh_change.id.to_s+'">'
                            @w_part += '<td>'+wh_change.moko_part.to_s+'</td>'
                            @w_part += '<td>'+wh_change.moko_des.to_s+'</td>'
                            @w_part += '<td>'+wh_change.wh_qty.to_s+'</td>'
                            @w_part += '<td>'+wh_change.qty.to_s+'</td>'
                            @w_part += '<td>'+wh_change.wh_f_qty.to_s+'</td>'
                            @w_part += '<td>'+wh_change.wh_c_qty.to_s+'</td>'
                            @w_part += '<td><div class="input-group input-group-sm">'
                            @w_part += '<form class="form-inline" action="/add_wh_change_item" accept-charset="UTF-8" data-remote="true" method="post">'
                            @w_part += '<input id="pi_wh_change_no"  name="pi_wh_change_no" type="text"  class="sr-only"  value="'+params[:pi_wh_change_no].to_s+'">'
                            @w_part += '<input id="moko_part"  name="moko_part" type="text"  class="sr-only"  value="'+wh_change.moko_part.to_s+'">'
                            @w_part += '<span class="form-inline input-group-btn "><input id="wh_qty_in"  name="wh_qty_in" type="text" size="10" class="form-control input-sm" >'
                            @w_part += '<button type="submit" class="btn btn-link  glyphicon glyphicon-ok " ></button></span>'
                            @w_part += '</form>'
                            @w_part +='</div></td>'
                            @w_part += '</tr>'
                end
            end
            @w_part += '<tbody>'
            @w_part += '<table>'
            @w_part += '<small>'
        end
    end

    def new_wh_order
        if params[:wh_no] == "" or params[:wh_no] == nil
            if PiWhInfo.find_by_sql('SELECT pi_wh_no FROM pi_wh_infos WHERE to_days(pi_wh_infos.created_at) = to_days(NOW())').blank?
                pi_n =1
            else
                pi_n = PiWhInfo.find_by_sql('SELECT pi_wh_no FROM pi_wh_infos WHERE to_days(pi_wh_infos.created_at) = to_days(NOW())').last.pi_wh_no.split("WH")[-1].to_i + 1
            end
            @wh_no = "MO"+current_user.s_name_self.to_s.upcase  + Time.new.strftime('%y').to_s + Time.new.strftime('%m%d').to_s + "WH"+ pi_n.to_s

            wh_info = PiWhInfo.new
            wh_info.pi_wh_no = @wh_no
            wh_info.wh_user = current_user.email
            wh_info.state = "new"
            #wh_info.site = "c"            
            wh_info.save
            pi_wh_no = wh_info.pi_wh_no
        else
            pi_wh_no = params[:wh_no]
        end
        #@pcblist = PcbOrder.where(state: "quotechk").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
        redirect_to edit_wh_order_path(pi_wh_no: pi_wh_no) and return 
    end

    def find_w_wh
        if params[:dn_code] != ""
            if params[:dn_code] =~ /&/i
                key_word = params[:dn_code].strip.split("&")[-1]
            else
                key_word = params[:dn_code]
            end
            where_wh = "dn_long = '#{key_word}' AND state = 'buy'"
            if params[:pi_buy_no] != ""
                where_wh += " AND pi_buy_no = '#{params[:pi_buy_no].strip}'"
            end
        else
            if params[:pi_buy_no] != ""
                where_wh = "pi_buy_no = '#{params[:pi_buy_no].strip}'  AND state = 'buy'"
            end
        end
        @w_part = ""
        if params[:dn_code] != "" or params[:pi_buy_no] != ""
            @w_part += '<small>'
            @w_part += '<table class="table table-bordered">'
            @w_part += '<thead>'
            @w_part += '<tr class="active">'
            @w_part += '<th width="250">供应商</th>'
            @w_part += '<th width="120">采购单号</th>'
            @w_part += '<th width="120">PI订单号</th>'
            @w_part += '<th width="120">物料编码</th>'
            @w_part += '<th >物料描述</th>'
            @w_part += '<th >总量</th>'
            @w_part += '<th >单价</th>'
            @w_part += '<th >总价</th>'
            @w_part += '<th >待入草稿</th>'
            @w_part += '<th >已入</th>'
            @w_part += '<th width="150">操作</th>'
            @w_part += '<tr>'
            @w_part += '</thead>'
            @w_part += '<tbody>'
            @w_wh_order = PiBuyInfo.where("#{where_wh}")
            if not @w_wh_order.blank?
                @w_wh_order.each do |wh_order|
                    wh_order_item = PiBuyItem.where(pi_buy_info_id: wh_order.id,state: "buying")
                    if not wh_order_item.blank?
                        wh_order_item.each do |wh_item|                       
                            @w_part += '<tr id="wh_item_'+wh_item.id.to_s+'">'
                            @w_part += '<td>'+wh_order.dn_long.to_s+'('+wh_order.dn.to_s+')</td>'
                            @w_part += '<td>'+PiBuyInfo.find_by_id(wh_item.pi_buy_info_id).pi_buy_no.to_s+'</td>'
                            @w_part += '<td>'+wh_item.erp_no.to_s+'</td>'
                            @w_part += '<td>'+wh_item.moko_part.to_s+'</td>'
                            @w_part += '<td>'+wh_item.moko_des.to_s+'</td>'
                            @w_part += '<td>'+wh_item.buy_qty.to_s+'</td>'
                            @w_part += '<td>'+wh_item.cost.to_s+'</td>'
                            @w_part += '<td>'+(wh_item.buy_qty*wh_item.cost).to_s+'</td>'
                            @w_part += '<td>'+wh_item.qty_wait.to_s+'</td>'
                            @w_part += '<td>'+wh_item.qty_done.to_s+'</td>'
                            #@w_part += '<td>'+(wh_item.quantity*ProcurementBom.find(wh_item.procurement_bom_id).qty).to_s+'</td>'
                            @w_part += '<td><div class="input-group input-group-sm">'
                            @w_part += '<form class="form-inline" action="/add_wh_item" accept-charset="UTF-8" data-remote="true" method="post">'
                            @w_part += '<input id="wh_order_no"  name="wh_order_no" type="text"  class="sr-only"  value="'+params[:pi_wh_no].to_s+'">'
                            @w_part += '<input id="wh_order_id"  name="wh_order_id" type="text"  class="sr-only"  value="'+params[:pi_wh_info_id].to_s+'">'
                            @w_part += '<input id="pi_buy_item_id"  name="pi_buy_item_id" type="text"  class="sr-only"  value="'+wh_item.id.to_s+'">'
                            @w_part += '<input id="wh_qty_in"  name="wh_qty_in" type="text" size="10" class="form-control input-sm"  value="'+(wh_item.buy_qty-wh_item.qty_wait-wh_item.qty_done).to_s+'">'
                            @w_part += '<span class="input-group-btn "><button type="submit" class="btn btn-link  glyphicon glyphicon-ok " ></button></span>'
                            @w_part += '</form>'
                            @w_part +='</div></td>'
                            @w_part += '</tr>'
                        end
                    end
                end
            end
            @w_part += '<tbody>'
            @w_part += '<table>'
            @w_part += '<small>'
        end
    end

    def del_wh
        wh_order = PiWhInfo.find(params[:wh_id])
        if can? :work_wh, :all
            wh_order.destroy
        end
        redirect_to :back
    end

    def pi_buy_item
        @pi_buy = PiBuyItem.where(pi_buy_info_id: params[:pi_buy_info_id])
    end



    def find_pi_buy
        @table_buy = ''
        @table_buy += '<table class="table table-hover">'
        @table_buy += '<thead>'
        @table_buy += '<tr style="background-color: #eeeeee">'
        @table_buy += '<th width="20"></th>'
        @table_buy += '<th >MOKO DES</th>'
        @table_buy += '<th width="80">申请数量</th>'
        @table_buy += '<th width="80">单价￥</th>'
        @table_buy += '<th width="80">附件</th>'
        @table_buy += '<th >供应商</th>'
        @table_buy += '<th >备注</th>'
        @table_buy += '</tr>'
        @table_buy += '</thead>'
        @table_buy += '<tbody><small>'
        if params[:key_order]
            if not params[:key_order].blank?
                des = params[:key_order].strip.split(" ")
                where_des = ""
                des.each_with_index do |de,index|
                    #where_des += "p_items.moko_des LIKE '%#{de}%'"
                    where_des += "`pi_pmc_items`.`moko_des` LIKE '%#{de}%'"
                    if des.size > (index + 1)
                        where_des += " AND "
                    end
                end 
                @pi_buy = PiPmcItem.find_by_sql("SELECT * FROM `pi_pmc_items` WHERE (`pi_pmc_items`.`moko_part` LIKE '%#{params[:key_order]}%' OR (#{where_des})) AND `pi_pmc_items`.`state` = 'pass' AND `pi_pmc_items`.`buy_user` <> 'MOKO' ORDER BY 'moko_part'")
            else
                @pi_buy = PiPmcItem.where("state = 'pass' AND `buy_user` <> 'MOKO'").order("moko_part")
            end
            #@pi_buy = PiInfo.find_by_sql("SELECT pi_infos.pi_no, pi_items.pi_no, p_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.pi_no = pi_items.pi_no INNER JOIN p_items ON pi_items.bom_id = p_items.procurement_bom_id WHERE (p_items.moko_part LIKE '%#{params[:key_order]}%' OR (#{where_des})) AND pi_infos.state = 'checked' AND p_items.buy IS NULL")    
            #@pi_buy = PiPmcItem.find_by_sql("SELECT * FROM `pi_pmc_items` WHERE (`pi_pmc_items`.`moko_part` LIKE '%#{params[:key_order]}%' OR (#{where_des})) AND `pi_pmc_items`.`state` = 'pass' ") 
            if not @pi_buy.blank?
                @pi_buy.each do |buy|
                    @table_buy += '<tr>'
                    @table_buy += '<td><input class="chk_all" type="checkbox" value="'+buy.id.to_s+'" name="roles[]" id="roles_" checked></td>'
                    @table_buy += '<td>'+buy.moko_des.to_s+'</td>'
                    @table_buy += '<td>'+buy.pmc_qty.to_s+'</td>'
                    @table_buy += '<td>'+buy.cost.to_s+'</td>'
                    if not PDn.find_by_id(buy.dn_id).blank?
                        if not PDn.find_by_id(buy.dn_id).info.blank?
                            @table_buy += '<td><small><a href="'
                            @table_buy += PDn.find_by_id(buy.dn_id).info.to_s
                            @table_buy += '">下载</a></small></td>'
                        else
                            @table_buy += '<td></td>'
                        end
                    else
                        @table_buy += '<td></td>'
                    end
                    @table_buy += '<td>'+buy.dn_long.to_s+'</td>'
                    @table_buy += '<td>'
                    @table_buy += '<div class="row" style="margin: 0px;" >'
                    @table_buy += '<div class="col-md-12 " style="margin: 0px;padding: 0px;background-color: #fcf8e3;" >'
                    PItemRemark.where(p_item_id: buy.p_item_id).each do |remark_item|
                        @table_buy += '<div class="row" style="margin: 0px;" >'
                        @table_buy += '<div class="col-md-12 " style="margin: 0px;padding: 0px;background-color: #fcf8e3;">'
                        @table_buy += '<table style="margin: 0px;" >'
                        @table_buy += '<tr>'
                        @table_buy += '<td style="padding: 0px;margin: 0px;" >'
                        @table_buy += '<p style="padding: 0px;margin: 0px;" >'
                        @table_buy += '<small >'
                        @table_buy += '<strong>'+remark_item.user_name+': </strong>'
                        @table_buy += remark_item.remark
                        @table_buy += '</small>'
                        @table_buy += '</p>'
                        @table_buy += '</td>'
                        @table_buy += '</tr>'
                        @table_buy += '</table>'
                        @table_buy += '</div>'
                        @table_buy += '</div>'
                    end
                    @table_buy += '</div>'
                    if not buy.dn_id.blank?
                        if not PDn.find_by_id(buy.dn_id).blank?
                            if not PDn.find(buy.dn_id).remark.blank? 
                                @table_buy += '<div class="row" style="margin: 0px;" >'
                                @table_buy += '<div class="col-md-12 " style="margin: 0px;padding: 0px;background-color: #fcf8e3;">'
                                @table_buy += '<table style="margin: 0px;" >'
                                @table_buy += '<tr>'
                                @table_buy += '<td style="padding: 0px;margin: 0px;" >'
                                @table_buy += '<p style="padding: 0px;margin: 0px;" >'
                                @table_buy += '<small >'
                                if not PDn.find(buy.dn_id).info.blank?                
                                    @table_buy += '<a class="btn btn-info btn-xs" href="'+PDn.find(buy.dn_id).info.to_s+'" target="_blank">下载</a>'
                                end
                                @table_buy += '<strong>采购工程师: </strong>'+PDn.find(buy.dn_id).remark.to_s
                                @table_buy += '</small>'
                                @table_buy += '</p>'
                                @table_buy += '</td>'
                                @table_buy += '</tr>'
                                @table_buy += '</table>'
                                @table_buy += '</div>'
                                @table_buy += '</div>'
                            end
                        end
                    end
                    @table_buy += '</div>'
                    @table_buy += '</td>'
                    @table_buy += '</tr>'
                end
            end
        end
        @table_buy += '</small></tbody>'
        @table_buy += '</table>'
        #Rails.logger.info(@table_buy.inspect)
    end

    def find_dn
        if params[:dn_code] != ""
            if params[:dn_code] =~ /&/i
                key_word = params[:dn_code].split("&")[0]
            else
                key_word = params[:dn_code]
            end
            #@c_info = AllDn.find_by_sql("SELECT DISTINCT all_dns.dn,all_dns.dn_long,id FROM all_dns WHERE all_dns.dn LIKE '%#{key_word}%' GROUP BY all_dns.dn")
            @c_info = AllDn.find_by_sql("SELECT  supplier_name,supplier_name_long,id FROM supplier_lists WHERE supplier_name LIKE '%#{key_word}%'")
            #@c_info = PcbCustomer.find_by_sql("SELECT * FROM `pcb_customers`  WHERE (`pcb_customers`.`c_no` LIKE '%#{params[:dn_code]}%' OR `pcb_customers`.`customer` LIKE '%#{params[:dn_code]}%' OR `pcb_customers`.`customer_com` LIKE '%#{params[:dn_code]}%' OR `pcb_customers`.`email` LIKE '%#{params[:dn_code]}%') AND `pcb_customers`.`follow` = '#{current_user.email}'")
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
                @c_table += '<th >供应商简称</th>'
                @c_table += '<th>供应商全称</th>'
                @c_table += '<tr>'
                @c_table += '</thead>'
                @c_table += '<tbody>'
                @c_info.each do |cu|
                    @c_table += '<tr>'
                    #@c_table += '<td>' + cu.c_no + '</td>'
                    @c_table += '<td><a rel="nofollow" data-method="get"  href="/find_dn_ch?id='+ cu.id.to_s + '&pi_buy_no=' + params[:pi_buy_no] + '"><div>' + cu.supplier_name + '</div></a></td>'
                    @c_table += '<td><a rel="nofollow" data-method="get"  href="/find_dn_ch?id='+ cu.id.to_s + '&pi_buy_no=' + params[:pi_buy_no] + '"><div>' + cu.supplier_name_long.to_s + '</div></a></td>'
                    @c_table += '</tr>'
                end
                @c_table += '</tbody>'
                @c_table += '</table>'
                @c_table += '</small>'
                Rails.logger.info("add-------------------------------------12")
                Rails.logger.info(@c_table.inspect)
                Rails.logger.info("add-------------------------------------12")
            end
        end
    end

    def new_pi_buy
        if params[:pi_buy_no] == "" or params[:pi_buy_no] == nil
            if PiBuyInfo.find_by_sql('SELECT pi_buy_no FROM pi_buy_infos WHERE to_days(pi_buy_infos.created_at) = to_days(NOW())').blank?
                pi_n =1
            else
                pi_n = PiBuyInfo.find_by_sql('SELECT pi_buy_no FROM pi_buy_infos WHERE to_days(pi_buy_infos.created_at) = to_days(NOW())').last.pi_buy_no.split("BUY")[-1].to_i + 1
            end
            @pi_buy_no = "MO"+ Time.new.strftime('%y').to_s + Time.new.strftime('%m%d').to_s + "BUY"+ pi_n.to_s
            pi_buy_info = PiBuyInfo.new()
            pi_buy_info.pi_buy_no = @pi_buy_no
            pi_buy_info.user = current_user.email
            pi_buy_info.state = "new"
            pi_buy_info.save
            pi_buy_no = pi_buy_info.pi_buy_no
        else
            pi_buy_no = params[:pi_buy_no]
        end
        redirect_to edit_pi_buy_path(pi_buy_no: pi_buy_no) and return    
    end

    def pi_buy_list
        #@pi_buy_list = PiBuyInfo.where(state: "new").paginate(:page => params[:page], :per_page => 20)
        @pi_buy_list = PiBuyInfo.find_by_sql("SELECT pi_buy_infos.*,SUM(pi_buy_items.buy_qty*pi_buy_items.cost) AS t_p_sum FROM pi_buy_infos LEFT JOIN pi_buy_items ON pi_buy_infos.id = pi_buy_items.pi_buy_info_id WHERE pi_buy_infos.state = 'new' OR pi_buy_infos.state = 'uncheck' GROUP BY pi_buy_infos.id").paginate(:page => params[:page], :per_page => 20)
        #@pi_buy = PiInfo.find_by_sql("SELECT pi_infos.pi_no, pi_items.pi_no, p_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.pi_no = pi_items.pi_no INNER JOIN p_items ON pi_items.bom_id = p_items.procurement_bom_id WHERE pi_infos.state = 'checked'").paginate(:page => params[:page], :per_page => 20)
    end

    def pi_waitfor_buy
        @pi_buy = PiPmcItem.where("state = 'pass' AND buy_user<> 'MOKO'").paginate(:page => params[:page], :per_page => 20)
        #@pi_buy = PiInfo.find_by_sql("SELECT pi_infos.pi_no, pi_items.pi_no, p_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.pi_no = pi_items.pi_no INNER JOIN p_items ON pi_items.bom_id = p_items.procurement_bom_id WHERE pi_infos.state = 'checked' AND p_items.buy IS NULL").paginate(:page => params[:page], :per_page => 20)
        
        #@pi_buy = PiInfo.find_by_sql("SELECT pi_infos.pi_no, pi_items.pi_no, p_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.pi_no = pi_items.pi_no INNER JOIN p_items ON pi_items.bom_id = p_items.procurement_bom_id WHERE pi_infos.state = 'checked'").paginate(:page => params[:page], :per_page => 20)
    end

    def pi_draft  
        pi_draft = PiInfo.find_by_id(params[:p_pi])
        if params[:commit] == "提交"
            #if can? :work_admin, :all 
                #pi_draft.state = "checked"
                #pi_draft.bom_state = "checked"
                #pi_draft.finance_state = "checked"
                #pi_draft.save
                #redirect_to pi_list_path() and return
            #end
=begin
            if can? :work_e, :all and pi_draft.state == "new"
                pi_draft.state = "check"
                pi_draft.save
                redirect_to pi_list_path() and return                
            end
=end
            if can? :work_e, :all  and pi_draft.pi_lock != "lock"
                pi_item_data = PiItem.find_by_id(params[:p_item])
                if pi_item_data.qty.blank?
                    flash[:error] = "请填写数量!!!"
                    redirect_to :back and return
                end
                if pi_item_data.state.blank?
                    if not pi_item_data.bom_id.blank?
                        get_bom_data = ProcurementBom.find_by_id(pi_item_data.bom_id)
                        if not get_bom_data.blank?

                            #新建数量申请
                            new_qty_info = PiBomQtyInfo.new
                            new_qty_info.pi_info_id = pi_draft.id
                            new_qty_info.pi_item_id = pi_item_data.id
                            new_qty_info.bom_id = get_bom_data.id
                            new_qty_info.qty = pi_item_data.qty
                            new_qty_info.t_qty = PiItem.find_by_sql("SELECT SUM(pi_items.qty) AS qty FROM pi_items WHERE pi_items.pi_info_id = '#{pi_draft.id}'").first.qty
                            new_qty_info.save



                            get_bom_data.pi_lock = "lock"
                            if get_bom_data.save
                                if not get_bom_data.erp_item_id.blank?
                                    get_otder_item = PcbOrderItem.find_by_id(get_bom_data.erp_item_id) 
                                    if not get_otder_item.blank?
                                        get_otder_item.pi_lock == "lock"
                                        get_otder_item.save
                                    end
                                end
                                #新建数量申请item
                                get_bom_item_data = PItem.where(procurement_bom_id: get_bom_data.id)
                                if not get_bom_item_data.blank?
                                    get_bom_item_data.each do |item|
                                        new_qty_info_item = PiBomQtyInfoItem.new
                                        new_qty_info_item.pi_bom_qty_info_id = new_qty_info.id
                                        new_qty_info_item.pi_info_id = new_qty_info.pi_info_id
                                        new_qty_info_item.pi_item_id = pi_item_data.id
                                        new_qty_info_item.order_item_id = pi_item_data.order_item_id
                                        new_qty_info_item.bom_id = new_qty_info.bom_id
                                        new_qty_info_item.p_item_id = item.id
                                        new_qty_info_item.qty = new_qty_info.qty
                                        new_qty_info_item.t_qty = new_qty_info.t_qty
                                        history_qty_info_item = PiBomQtyInfoItem.find_by_sql("SELECT SUM(qty) AS qty FROM pi_bom_qty_info_items WHERE pi_info_id = '#{pi_draft.id}' AND p_item_id = '#{item.id}'")
                                        h_qty = 0
                                        if not history_qty_info_item.blank?
                                            h_qty = history_qty_info_item.first.qty.to_i
                                        end
                                        history_c_qty_info_item = PiBomQtyInfoItem.find_by_sql("SELECT SUM(qty) AS c_qty FROM pi_bom_qty_info_items WHERE pi_info_id = '#{pi_draft.id}' AND p_item_id = '#{item.id}'")
                                        c_qty = 0
                                        if not history_c_qty_info_item.blank?
                                            c_qty = history_c_qty_info_item.first.c_qty.to_i
                                        end
                                        if not history_qty_info_item.blank?
                                            use_qty = (new_qty_info.t_qty*item.quantity) - h_qty - c_qty
                                            if use_qty >= new_qty_info.qty*item.quantity
                                                new_qty_info_item.bom_ctl_qty = new_qty_info.qty*item.quantity
                                            elsif use_qty < new_qty_info.qty*item.quantity
                                                new_qty_info_item.bom_ctl_qty = use_qty
                                            end
                                        else
                                            new_qty_info_item.bom_ctl_qty = new_qty_info.qty*item.quantity
                                        end
                                        new_qty_info_item.save
                                        
                                    end
                                end
                            end




                        end
                    end
                    pi_draft.pi_lock = "lock"
                    pi_item_data.state = "check"
                    pi_item_data.bom_state = "check"
                    pi_item_data.buy_state = "check"
                    pi_item_data.save
                    pi_draft.state = "check"
                    pi_draft.save
                end
                redirect_to pi_list_path(bom_chk: true) and return                
            end

            if can? :work_d, :all 
                Rails.logger.info("add-------------------------------------5652")
                pi_item_data = PiItem.find_by_id(params[:p_pi_item_id])
                if pi_item_data.finance_state == "checked" and pi_item_data.buy_state == "checked"
                    pi_item_data.state = "checked"
                else
                    pi_item_data.state = "check"
                end
                pi_item_data.bom_state = "checked"
                pi_item_data.bom_at = Time.new()
                pi_item_data.save
                #set_lock = PiItem.where("pi_no = '#{params[:p_pi]}' AND p_type = 'PCBA'")
                set_lock = PiItem.where("pi_info_id = '#{params[:p_pi]}' AND p_type = 'PCBA'")
                if not set_lock.blank?
                    Rails.logger.info("add-------------------------------------565211111")
                    set_lock.each do |item|
                        find_bom = ProcurementBom.find_by_id(item.bom_id)
                        if not find_bom.blank?
                            if find_bom.moko_bom_info_id.blank?

                                up_bom = MokoBomInfo.new
                                up_bom.moko_state = "active"
                            #up_bom.bom_id = find_bom.bom_id
                            #up_bom.bom_version = bom_version
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
                                    up_bom.bom_id = "moko#{up_bom.id}"
                                    up_bom.save
                                    find_bom_item = PItem.where(procurement_bom_id: find_bom.id)
                                    if not find_bom_item.blank?
                                        find_bom_item.each do |item_p|
                                            up_item = up_bom.moko_bom_items.build()
                                            up_item.bom_version = up_bom.bom_version
                                            up_item.p_type = item_p.p_type
                                            #up_item.buy = item.buy
                                            up_item.erp_id = item_p.erp_id
                                            up_item.erp_no = item_p.erp_no
                                            up_item.user_do = item_p.user_do
                                            up_item.user_do_change = item_p.user_do_change
                                            up_item.check = item_p.check

                                            up_item.quantity = item_p.quantity
 
                                            if item.p_type == "COMPONENTS"
                                                up_item.pmc_qty = item_p.quantity
                                            else
                                                up_item.pmc_qty = item.qty*item_p.quantity
                                            end
 
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

                                find_bom.bom_lock = "lock"
                                find_bom.bom_id = up_bom.bom_id
                                find_bom.moko_bom_info_id = up_bom.id
                                find_bom.save
                            end
                        end
                    end
                end
=begin
                if pi_draft.finance_state == "checked"
                    pi_draft.state = "checked"
                else
                    pi_draft.state = "check"
                end
                pi_draft.bom_state = "checked"
                pi_draft.save
=end
                redirect_to pi_list_path() and return
            end
            if can? :work_g, :all 
                Rails.logger.info("add-------------------------------------5652")
                pi_item_data = PiItem.find_by_id(params[:p_pi_item_id])
                if pi_item_data.finance_state == "checked" and pi_item_data.bom_state == "checked"
                    pi_item_data.state = "checked"
                else
                    pi_item_data.state = "check"
                end
                pi_item_data.buy_state = "checked"
                pi_item_data.caigou_at = Time.new()
                pi_item_data.save
                set_lock = PiItem.where("pi_no = '#{params[:p_pi]}' AND p_type = 'PCBA'")
                if not set_lock.blank?
                    set_lock.each do |item|
                        find_bom = ProcurementBom.find_by_id(item.bom_id)
                        if not find_bom.blank?
                            find_bom.bom_lock = "lock"
                            find_bom.save
                        end
                    end
                end
                if pi_draft.bom_state == "checked" and pi_draft.finance_state == "checked"
                    pi_draft.state = "checked"
                else
                    pi_draft.state = "check"
                end
                pi_draft.buy_state = "checked"
                pi_draft.save
                redirect_to pi_list_path() and return
            end
            if can? :work_finance, :all 
                if pi_draft.bom_state == "checked" and pi_draft.buy_state == "checked"
                    pi_draft.state = "checked"
                else
                    pi_draft.state = "check"
                end
                pi_draft.finance_state = "checked"
                pi_draft.save
                pi_item_data = PiItem.find_by_id(params[:p_pi_item_id])

                if pi_item_data.bom_state == "checked" and pi_item_data.buy_state == "checked"
                    pi_item_data.state = "checked"
                else
                    pi_item_data.state = "check"
                end
                pi_item_data.finance_state = "checked"
                pi_item_data.caiwu_at = Time.new()
                pi_item_data.save


                redirect_to pi_list_path() and return
            end
        elsif params[:commit] == "反审核"
            pi_item_data = PiItem.find_by_id(params[:p_pi_item_id])
            if can? :work_d, :all
                pi_item_data.state = "check"
                pi_item_data.bom_state = "uncheck"
                pi_item_data.save
                pi_draft.bom_state = "uncheck"
                pi_draft.state = "check"
                pi_draft.save
            end
            if can? :work_g, :all
                pi_item_data.state = "check"
                pi_item_data.buy_state = "uncheck"
                pi_item_data.save
                pi_draft.buy_state = "uncheck"
                pi_draft.state = "check"
                pi_draft.save
            end
            if can? :work_finance, :all
                pi_item_data.state = "check"
                pi_item_data.finance_state = "uncheck"
                pi_item_data.save
                pi_draft.finance_state = "uncheck"
                pi_draft.state = "check"
                pi_draft.save
            end
        end
        redirect_to pi_list_path() and return
    end

    def bom_edit_order_item
        find_data = PcbOrderItem.find(params[:bom_edit_id])
        find_data.moko_code = params[:bom_edit_moko_code]
        find_data.moko_des = params[:bom_edit_moko_des]
        find_data.save
        redirect_to :back
    end

    def copy_order_item
        find_data = PcbOrderSellItem.find(params[:id])
        copy_data = PcbOrderItem.new
        copy_data.c_id = find_data.c_id
        copy_data.pcb_order_id = find_data.pcb_order_id
        copy_data.pcb_order_sell_item_id = params[:id]
        copy_data.pcb_order_no = find_data.pcb_order_no
        if PcbOrderItem.find_by_pcb_order_no(find_data.pcb_order_no).blank?
            p_n =1
        else
            p_n = PcbOrderItem.where("pcb_order_no = '#{find_data.pcb_order_no}' AND item_pcba_id IS NULL").last.pcb_order_no_son.split('-')[-1].to_i + 1
        end
        #@p_no = "MK" + Time.new.strftime('%y%m%d').to_s + current_user.s_name_self.to_s.upcase + p_n.to_s
        copy_data.pcb_order_no_son = find_data.pcb_order_no + "-" +p_n.to_s
        copy_data.des_en = find_data.des_en
        copy_data.des_cn = find_data.des_cn
        copy_data.qty = find_data.qty
        copy_data.att = find_data.att
        copy_data.remark = find_data.remark
        copy_data.save
        redirect_to :back
    end

    def find_moko_part
        if params[:moko_part] != ""
            if not params[:moko_part].blank?
                des = params[:moko_part].strip.split(" ")
                where_des = ""
                des.each_with_index do |de,index|
                    where_des += "all_dns.des LIKE '%#{de}%'"
                    if des.size > (index + 1)
                        where_des += " AND "
                    end
                end      
            end
            #@c_info = PcbCustomer.find_by(c_no: params[:c_code])
            @moko_part = AllDn.find_by_sql("SELECT * FROM all_dns WHERE (all_dns.part_code LIKE '%#{params[:moko_part]}%' OR (#{where_des})) AND all_dns.qty >= 100 AND all_dns.dn <> '客供' ORDER BY all_dns.date DESC").first
            if @moko_part.blank?
                @moko_part = AllDn.find_by_sql("SELECT * FROM all_dns WHERE (all_dns.part_code LIKE '%#{params[:moko_part]}%' OR all_dns.des LIKE '%#{params[:moko_part]}%') AND all_dns.dn <> '客供' ORDER BY all_dns.date DESC").first
            end
            Rails.logger.info("add-------------------------------------12")
            Rails.logger.info(@moko_part.inspect)
            Rails.logger.info("add-------------------------------------12")
            if not @moko_part.blank?  
                Rails.logger.info("add-------------------------------------12")
                @table_moko_part = '<br>'
                @table_moko_part += '<small>'
                @table_moko_part += '<table class="table table-bordered">'
                @table_moko_part += '<thead>'
                @table_moko_part += '<tr class="active">'
                @table_moko_part += '<th width="100">物料代码</th>'
                @table_moko_part += '<th>描述</th>'
                @table_moko_part += '<th width="70">数量</th>'
                @table_moko_part += '<th width="70">价格</th>'
                @table_moko_part += '<tr>'
                @table_moko_part += '</thead>'
                @table_moko_part += '<tbody>'
                #@moko_part.each do |cu|
                    @table_moko_part += '<tr>'
                    #@c_table += '<td>' + cu.c_no + '</td>'
                    @table_moko_part += '<td><a rel="nofollow" data-method="get" data-remote="true" href="/find_moko_part_ch?id='+ @moko_part.id.to_s + '"><div>' + @moko_part.part_code.to_s + '</div></a></td>'
                    @table_moko_part += '<td><a rel="nofollow" data-method="get" data-remote="true" href="/find_moko_part_ch?id='+ @moko_part.id.to_s + '"><div>' + @moko_part.des.to_s + '</div></a></td>'
                    @table_moko_part += '<td><a rel="nofollow" data-method="get" data-remote="true" href="/find_moko_part_ch?id='+ @moko_part.id.to_s + '"><div>' + @moko_part.qty.to_s + '</div></a></td>'
                    @table_moko_part += '<td><a rel="nofollow" data-method="get" data-remote="true" href="/find_moko_part_ch?id='+ @moko_part.id.to_s + '"><div>' + @moko_part.price.to_s + '</div></a></td>'
                    @table_moko_part += '</tr>'
                #end
                @table_moko_part += '</tbody>'
                @table_moko_part += '</table>'
                @table_moko_part += '</small>'
                Rails.logger.info("add-------------------------------------12")
                Rails.logger.info(@table_moko_part.inspect)
                Rails.logger.info("add-------------------------------------12")
            end
        end
    end

    def find_moko_part_ch
        @moko_part = AllDn.find(params[:id])
    end

    def pi_draft_list
        @pilist = PiInfo.where(state: "new",pi_sell: current_user.email).order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
    end
    
    def del_pcb_pi
        pcb_pi = PiInfo.find(params[:pi_id])
        if can? :work_pcb_business, :all or pcb_pi.state == "new"
            pcb_pi.destroy
        end
        
        redirect_to :back
    end

    def pi_save
        redirect_to :back
    end

    def find_order
        if params[:c_code] != ""
            #@c_info = PcbCustomer.find_by(c_no: params[:c_code])
            @c_info = PcbOrder.find_by_sql("SELECT pcb_orders.*,pcb_customers.c_no,pcb_customers.customer,pcb_customers.customer_com FROM  `pcb_customers` INNER JOIN `pcb_orders` ON pcb_orders.pcb_customer_id = pcb_customers.id WHERE (`pcb_customers`.`c_no` LIKE '%#{params[:c_code]}%' OR `pcb_customers`.`customer` LIKE '%#{params[:c_code]}%' OR `pcb_customers`.`customer_com` LIKE '%#{params[:c_code]}%' OR `pcb_customers`.`email` LIKE '%#{params[:c_code]}%' OR `pcb_orders`.`order_no` LIKE '%#{params[:c_code]}%' OR `pcb_orders`.`p_name` LIKE '%#{params[:c_code]}%')  AND `pcb_orders`.`state` = 'quotechk' AND `pcb_orders`.`order_sell` = '#{current_user.email}'")
            #@c_info = PcbCustomer.find_by_sql("SELECT * FROM `pcb_customers`  WHERE (`pcb_customers`.`c_no` LIKE '%#{params[:c_code]}%' OR `pcb_customers`.`customer` LIKE '%#{params[:c_code]}%' OR `pcb_customers`.`customer_com` LIKE '%#{params[:c_code]}%' OR `pcb_customers`.`email` LIKE '%#{params[:c_code]}%') AND `pcb_customers`.`follow` = '#{current_user.email}'")
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
                @c_table += '<th width="70">项目名称</th>'
                @c_table += '<th width="70">客户代码</th>'
                @c_table += '<th>客户名</th>'
                @c_table += '<th>客户公司名</th>'

                @c_table += '<th  width="120">Order NO.</th>'
                @c_table += '<th  width="70">报价</th>'
                @c_table += '<th >采购备注</th>'
                @c_table += '<th >跟踪备注</th>'
                @c_table += '<th width="45">操作</th>'
                @c_table += '<tr>'
                @c_table += '</thead>'
                @c_table += '<tbody>'
                @c_info.each do |cu|
                    @c_table += '<tr>'
                    #@c_table += '<td>' + cu.c_no + '</td>'
                    @c_table += '<td><div>' + cu.p_name + '</div></td>'
                    @c_table += '<td><div>' + cu.c_no + '</div></td>'
                    @c_table += '<td><div>' + cu.customer.to_s + '</div></td>'
                    @c_table += '<td><div>' + cu.customer_com.to_s + '</div></td>'
                    @c_table += '<td><div>' + cu.order_no.to_s + '</div></td>'
                    @c_table += '<td><div>' + cu.price.to_s + '</div></td>'
                    @c_table += '<td><div>' + cu.remark.to_s + '</div></td>'
                    @c_table += '<td><div>' + cu.follow_remark.to_s + '</div></td>'
                    @c_table += '<td><a rel="nofollow" data-method="get"  href="/find_order_check?id='+ cu.id.to_s + '&pi='+params[:pi].to_s+'"><div>确认</div></a></td>'
                    @c_table += '</tr>'
                end
                @c_table += '</tbody>'
                @c_table += '</table>'
                @c_table += '</small>'
                @c_table = @c_table.gsub(/\r\n/, " ")
                Rails.logger.info("add-------------------------------------33")
                Rails.logger.info(@c_table)
                Rails.logger.info("add-------------------------------------33")
                
            end
        end
    end

    def del_pi_item
        del_item = PiItem.find(params[:del_pi_item_id])
        del_item.destroy
        redirect_to :back
    end

    def del_pi_other_item
        del_item = PiOtherItem.find(params[:del_pi_other_item_id])
        del_item.destroy
        redirect_to :back
    end

    def find_order_check
        @find_order_info = PcbOrder.find(params[:id])
        @find_pi_info = PiInfo.find_by(pi_no: params[:pi])
        if @find_pi_info.pi_lock == "lock"
            redirect_to :back and return
        end
        @find_pi_info.pcb_customer_id = @find_order_info.pcb_customer_id
        @find_pi_info.c_code = @find_order_info.c_code
        @find_pi_info.c_des = @find_order_info.c_des
        @find_pi_info.c_country = @find_order_info.c_country
        @find_pi_info.c_shipping_address = @find_order_info.c_shipping_address
        @find_pi_info.p_name = @find_order_info.p_name
        @find_pi_info.remark = @find_order_info.remark
        @find_pi_info.follow_remark = @find_order_info.follow_remark
        @find_pi_info.save




        PcbOrderItem.where(pcb_order_id: params[:id],p_type: "PCBA").each do |q_item|
            pi_item = PiItem.new
            find_pcb = PcbItemInfo.find_by_pcb_order_item_id(q_item.item_pcb_id) 
                Rails.logger.info("add-------------------------------------33")
                Rails.logger.info(find_pcb.inspect)
                Rails.logger.info("add-------------------------------------33")
            if not find_pcb.blank?       
                pi_item.pcb_size = find_pcb.pcb_length.to_s + '*' + find_pcb.pcb_width.to_s
                pi_item.layer = find_pcb.pcb_layer
                pi_item.pcb_price = find_pcb.t_p
            end
            

            #pi_item.unit_price
=begin
            if not q_item.bom_id.blank?
                find_bom = ProcurementBom.find_by_id(q_item.bom_id)
                if not find_bom.blank?
                    pi_item.com_cost = find_bom.t_p
                end
            end
=end
            #pi_item.pcba


            pi_item.order_item_id = q_item.id
            pi_item.bom_id = q_item.bom_id
            pi_item.c_id = @find_pi_info.pcb_customer_id
            pi_item.pi_info_id = @find_pi_info.id
            pi_item.pi_no = @find_pi_info.pi_no
            pi_item.moko_code = q_item.moko_code
            pi_item.moko_des = q_item.moko_des
            pi_item.des_en = q_item.des_en
            pi_item.des_cn = q_item.des_cn
            #pi_item.qty = q_item.qty
            pi_item.p_type = q_item.p_type
            pi_item.att = q_item.att
            pi_item.remark =  q_item.remark    
            pi_item.save
        end

        PcbOrderItem.where(pcb_order_id: params[:id],p_type: "PCB",item_pcba_id: nil).each do |q_item|
            pi_item = PiItem.new
            find_pcb = PcbItemInfo.find_by_pcb_order_item_id(q_item.id) 
            if not find_pcb.blank?       
                pi_item.pcb_size = find_pcb.pcb_length.to_s + '*' + find_pcb.pcb_width.to_s
                pi_item.layer = find_pcb.pcb_layer
                pi_item.pcb_price = find_pcb.t_p
            end
            

            #pi_item.unit_price
            if not q_item.bom_id.blank?
                find_bom = ProcurementBom.find_by_id(q_item.bom_id)
                if not find_bom.blank?
                    pi_item.com_cost = find_bom.t_p
                end
            end
            #pi_item.pcba


            pi_item.order_item_id = q_item.id
            pi_item.bom_id = q_item.bom_id
            pi_item.c_id = @find_pi_info.pcb_customer_id
            pi_item.pi_info_id = @find_pi_info.id
            pi_item.pi_no = @find_pi_info.pi_no
            pi_item.moko_code = q_item.moko_code
            pi_item.moko_des = q_item.moko_des
            pi_item.des_en = q_item.des_en
            pi_item.des_cn = q_item.des_cn
            pi_item.qty = q_item.qty
            pi_item.p_type = q_item.p_type
            pi_item.att = q_item.att
            pi_item.remark =  q_item.remark    
            pi_item.save
        end

        PcbOrderItem.where(pcb_order_id: params[:id],p_type: "COMPONENTS",item_pcba_id: nil).each do |q_item|
            pi_item = PiItem.new
            find_pcb = PcbItemInfo.find_by_pcb_order_item_id(q_item.id) 
            if not find_pcb.blank?       
                pi_item.pcb_size = find_pcb.pcb_length.to_s + '*' + find_pcb.pcb_width.to_s
                pi_item.layer = find_pcb.pcb_layer
                pi_item.pcb_price = find_pcb.t_p
            end
            

            #pi_item.unit_price
            if not q_item.bom_id.blank?
                find_bom = ProcurementBom.find_by_id(q_item.bom_id)
                if not find_bom.blank?
                    pi_item.com_cost = find_bom.t_p
                end
            end
            #pi_item.pcba


            pi_item.order_item_id = q_item.id
            pi_item.bom_id = q_item.bom_id
            pi_item.c_id = @find_pi_info.pcb_customer_id
            pi_item.pi_info_id = @find_pi_info.id
            pi_item.pi_no = @find_pi_info.pi_no
            pi_item.moko_code = q_item.moko_code
            pi_item.moko_des = q_item.moko_des
            pi_item.des_en = q_item.des_en
            pi_item.des_cn = q_item.des_cn
            pi_item.qty = q_item.qty
            pi_item.p_type = q_item.p_type
            pi_item.att = q_item.att
            pi_item.remark =  q_item.remark    
            pi_item.com_cost = q_item.t_p
            pi_item.save
        end



=begin
        find_pi_item = PiItem.where(pi_no: params[:pi])
        if not find_pi_item.blank?
            #find_pi_item.destroy
            find_pi_item.each do |del_item|
                del_item.destroy
            end
        end
=end      
        @table = ''
=begin
        PcbOrderItem.where(pcb_order_id: params[:id]).each do |q_item|
            pi_item = PiItem.new
            find_pcb = PcbItemInfo.find_by_pcb_order_item_id(q_item.id) 
            if not find_pcb.blank?       
                pi_item.pcb_size = find_pcb.pcb_length.to_s + '*' + find_pcb.pcb_width.to_s
                pi_item.layer = find_pcb.pcb_layer
                pi_item.pcb_price = find_pcb.t_p
            end
            

            #pi_item.unit_price
            if not q_item.bom_id.blank?
                find_bom = ProcurementBom.find_by_id(q_item.bom_id)
                if not find_bom.blank?inspect
                    pi_item.com_cost = find_bom.t_p
                end
            end
            #pi_item.pcba


            pi_item.order_item_id = q_item.id
            pi_item.bom_id = q_item.bom_id
            pi_item.c_id = @find_pi_info.pcb_customer_id
            pi_item.pi_info_id = @find_pi_info.id
            pi_item.pi_no = @find_pi_info.pi_no
            pi_item.moko_code = q_item.moko_code
            pi_item.moko_des = q_item.moko_des
            pi_item.des_en = q_item.des_en
            pi_item.des_cn = q_item.des_cn
            pi_item.qty = q_item.qty
            pi_item.p_type = q_item.p_type
            pi_item.att = q_item.att
            pi_item.remark =  q_item.remark    
            pi_item.save

            @table += '<tr>'
            @table += '<td><a class="glyphicon glyphicon-edit" data-toggle="modal" data-target="#edititem" data-edit_c_item_id="'
            @table += q_item.id.to_s
            @table += '" data-edit_moko_code="'
            @table += q_item.moko_code.to_s
            @table += '" data-edit_moko_des="'
            @table += q_item.moko_des.to_s
            @table += '" data-edit_p_type="'
            @table += q_item.p_type.to_s
            @table += '" data-edit_des_en="'
            @table += q_item.des_en.to_s
            @table += '" data-edit_des_cn="'
            @table += q_item.des_cn.to_s
            @table += '" data-edit_qty="'
            @table +=  q_item.qty.to_s 
            @table += '" data-edit_follow_remark="'
            @table += q_item.remark.to_s
            @table += '"></a></td>'
            @table += '<td>'+q_item.moko_code.to_s+'</td>'
            @table += '<td>'+q_item.moko_des.to_s+'</td>'
            @table += '<td>'+q_item.qty.to_s+'</td>'
            @table += '<td>'+q_item.des_en.to_s+'</td>'
            @table += '<td>'+q_item.des_cn.to_s+'</td>'
            @table += '<td>'+q_item.p_type.to_s+'</td>'
            @table += '<td>'+q_item.t_p.to_s+'</td>'
            @table += '<td>'+q_item.price.to_s+'</td>'
            @table += '<td>'
            if not q_item.att.blank?                
                @table += '<a class="btn btn-info btn-xs" href="'+q_item.att+'" target="_blank">下载</a>'
            end
            @table += '</td>'
            @table += '<td>'+q_item.remark.to_s+'</td>'
            @table += '<td><a class="glyphicon glyphicon-remove" href="/del_pcb_order_item?edit_c_item_id='+q_item.id.to_s+'"  data-confirm="确定要删除?"></a></td>'
            @table += '</tr>'

        end
=end
        redirect_to :back
    end

    def new_pcb_order
       if params[:new]
           if current_user.s_name_self.size == 1
                s_name = current_user.s_name_self
                where_p = "AND POSITION('" + s_name + "' IN RIGHT(LEFT(pcb_orders.order_no,9),8)) = 8 and (RIGHT(LEFT(pcb_orders.order_no,10),1) REGEXP '^[0-9]+$')"
           elsif current_user.s_name_self.size == 2
                s_name = current_user.s_name_self
                where_p = "AND POSITION('" + s_name + "' IN LEFT(pcb_orders.order_no,10)) = 9 and (RIGHT(LEFT(pcb_orders.order_no,11),1) REGEXP '^[0-9]+$') "
           end

           if PcbOrder.find_by_sql("SELECT order_no FROM pcb_orders WHERE to_days(pcb_orders.created_at) = to_days(NOW()) #{where_p}").blank?
                p_n =1
           else
                p_n = PcbOrder.find_by_sql("SELECT order_no FROM pcb_orders WHERE to_days(pcb_orders.created_at) = to_days(NOW()) #{where_p}").last.order_no.to_s.chop.split(current_user.s_name_self.to_s)[-1].to_i + 1
           end
           @p_no = "MK" + Time.new.strftime('%y%m%d').to_s + current_user.s_name_self.to_s.upcase + p_n.to_s + "B"
           @pcb = PcbOrder.new()        
           @pcb.order_no = @p_no
           @pcb.order_sell = current_user.email
           @pcb.team = current_user.team
           @pcb.phone = current_user.phone
           @pcb.state = "new"
           @pcb.save
           redirect_to edit_pcb_order_path(order_no: @p_no) and return
       else
           redirect_to :back and return
       end 
    end

    def new_pcb_pi
        if params[:pi_no] == "" or params[:pi_no] == nil
            if current_user.s_name_self.size == 1
                s_name = current_user.s_name_self
                where_p = "AND POSITION('" + s_name + "' IN RIGHT(LEFT(pi_infos.pi_no,4),2)) = 1 and (RIGHT(LEFT(pi_infos.pi_no,4),1) REGEXP '^[0-9]+$')"
            elsif current_user.s_name_self.size == 2
                s_name = current_user.s_name_self
                where_p = "AND POSITION('" + s_name + "' IN RIGHT(LEFT(pi_infos.pi_no,4),2)) = 1 and (RIGHT(LEFT(pi_infos.pi_no,5),1) REGEXP '^[0-9]+$') "
            end

            if PiInfo.find_by_sql("SELECT pi_no FROM pi_infos WHERE to_days(pi_infos.created_at) = to_days(NOW()) #{where_p}").blank?
                pi_n =1
            else
                pi_n = PiInfo.find_by_sql('SELECT pi_no FROM pi_infos WHERE to_days(pi_infos.created_at) = to_days(NOW()) #{where_p}').last.pi_no.split("PI")[-1].to_i + 1
            end

            @pi_no = "MO"+current_user.s_name_self.to_s.upcase  + Time.new.strftime('%y').to_s + Time.new.strftime('%m%d').to_s + "PI"+ pi_n.to_s
            pi_info = PiInfo.new()
            pi_info.pi_no = @pi_no
            pi_info.pi_sell = current_user.email
            pi_info.team = current_user.team
            pi_info.phone = current_user.phone
            pi_info.state = "new"
            pi_info.save
            pi_no = pi_info.pi_no
            pi_id = pi_info.id
        else
            pi_no = params[:pi_no]
        end
        #@pcblist = PcbOrder.where(state: "quotechk").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
        redirect_to edit_pcb_pi_path(pi_info_id: pi_id,pi_no: pi_no) and return    
    end

    def del_pcb_follow
        followd = PcbCustomerRemark.find(params[:id])
        followd.destroy
        @c_id = params[:itemp_id]
        @follow_remark = ""
        PcbCustomerRemark.where(pcb_c_id: @c_id).order("created_at DESC").each do |follow|
            @follow_remark += '<div><p class="bg-warning"><small><a class="glyphicon glyphicon-trash" data-method="get" data-remote="true" href="/del_pcb_follow?id='+follow.id.to_s+'&itemp_id='+ follow.pcb_c_id.to_s+'" data-confirm="确定要删除?"></a></small>'+follow.created_at.localtime.strftime('%Y-%m-%d %H:%M:%S')+' <strong>'+follow.user_name.to_s+': </strong>'+follow.remark.to_s+'</p></div>'
        end
        render "edit_pcb_customer.js.erb" and return
    end

    def back_pcb_to_order
        pcb = PcbOrder.find(params[:bom_id])
        pcb.state = "new"
        pcb.save
        redirect_to pcb_order_list_path(new: true)
    end

    def find_c_ch
        @c_info = PcbCustomer.find(params[:id])
        up_c = PcbOrder.find_by(order_no: params[:c_order_no])
        up_c.pcb_customer_id = @c_info.id
        up_c.c_code = @c_info.c_no
        up_c.c_des = @c_info.customer
        up_c.c_country = @c_info.customer_country
        up_c.c_shipping_address = @c_info.shipping_address
        up_c.save
        up_item_c = PcbOrderItem.where(pcb_order_no: params[:c_order_no]).update_all "c_id = '#{params[:id]}'"
        #if not up_item_c.blank?
            #up_item_c
        #end
        redirect_to edit_pcb_order_path(order_no: params[:c_order_no],c_id: params[:id])
    end

    def find_c_pi_ch
        @c_info = PcbCustomer.find(params[:id])
        up_c = PiInfo.find_by(pi_no: params[:c_pi_no])
        up_c.pcb_customer_id = @c_info.id
        up_c.c_code = @c_info.c_no
        up_c.c_des = @c_info.customer
        up_c.c_country = @c_info.customer_country
        up_c.c_shipping_address = @c_info.shipping_address
        up_c.save
        find_pi_item = PiItem.where(pi_no: params[:c_pi_no])
        if not find_pi_item.blank?
            #find_pi_item.destroy
            find_pi_item.each do |del_item|
                del_item.destroy
            end
        end
        redirect_to edit_pcb_pi_path(pi_info_id: up_c.id,pi_no: params[:c_pi_no],c_id: params[:id])
    end

    def find_linkbom_moko
        if params[:c_code_moko] != ""
            @c_info = MokoBomInfo.find_by_sql("SELECT * FROM `moko_bom_infos`  WHERE `moko_bom_infos`.`moko_state` = 'active' AND `moko_bom_infos`.`erp_no_son` LIKE '%#{params[:c_code_moko].strip}%'")
            if not @c_info.blank?
                @c_table = '<br>'
                @c_table += '<small>'
                @c_table += '<table class="table table-bordered">'
                @c_table += '<thead>'
                @c_table += '<tr class="active">'
                @c_table += '<th>项目名</th>'
                @c_table += '<th>子项目名</th>'
                @c_table += '<tr>'
                @c_table += '</thead>'
                @c_table += '<tbody>'
                @c_info.each do |cu|
                    @c_table += '<tr>'
                    #@c_table += '<td>' + cu.c_no + '</td>'
                    @c_table += '<td>' + cu.p_name_mom.to_s + '</td>'
                    
                    @c_table += '<td>'
                    @c_table += '<form action="/bom_v_up_moko" method="post" >'
                    @c_table += '<input type="text" name="order_id" id="order_id" value="' + params[:find_linkbom_moko_id].to_s + '" class="sr-only" >'
                    @c_table += '<input type="text" name="bom_id" id="bom_id" value="' + cu.id.to_s + '" class="sr-only" >'
                    @c_table += '<button type="submit" class="btn btn-link btn-sm" data-confirm="确定要关联?">' + cu.p_name.to_s + '</button>'
                    @c_table += '</form>'
                    @c_table += '</td>'
                    @c_table += '</tr>'
                end
                @c_table += '</tbody>'
                @c_table += '</table>'
                @c_table += '</small>'
            end
        end
    end

    def find_linkbom
        if params[:c_code] != ""
            @c_info = ProcurementBom.find_by_sql("SELECT * FROM `procurement_boms`  WHERE `procurement_boms`.`erp_no_son` LIKE '%#{params[:c_code].strip}%'")
            if not @c_info.blank?
                @c_table = '<br>'
                @c_table += '<small>'
                @c_table += '<table class="table table-bordered">'
                @c_table += '<thead>'
                @c_table += '<tr class="active">'
                @c_table += '<th>项目名</th>'
                @c_table += '<th>子项目名</th>'
                @c_table += '<tr>'
                @c_table += '</thead>'
                @c_table += '<tbody>'
                @c_info.each do |cu|
                    @c_table += '<tr>'
                    #@c_table += '<td>' + cu.c_no + '</td>'
                    @c_table += '<td>' + cu.p_name_mom.to_s + '</td>'
                    
                    @c_table += '<td>'
                    @c_table += '<form action="/bom_v_up" method="post" >'
                    @c_table += '<input type="text" name="order_id" id="order_id" value="' + params[:find_linkbom_id].to_s + '" class="sr-only" >'
                    @c_table += '<input type="text" name="bom_id" id="bom_id" value="' + cu.id.to_s + '" class="sr-only" >'
                    @c_table += '<button type="submit" class="btn btn-link btn-sm" data-confirm="确定要关联?">' + cu.p_name.to_s + '</button>'
                    @c_table += '</form>'
                    @c_table += '</td>'
                    @c_table += '</tr>'
                end
                @c_table += '</tbody>'
                @c_table += '</table>'
                @c_table += '</small>'
            end
        end
    end

    def find_linkbom_link
        upstart = PcbOrderItem.find_by_id(params[:order_id])
        if params[:state] == "mark"
            upstart.state = "quotechked"
        else
            upstart.state = "quote"
        end
        upstart.p_type = "PCBA"
        upstart.bom_id = params[:id]
        upstart.save
        redirect_to :back
    end

    def find_c_pi
        if params[:c_code] != ""
            #@c_info = PcbCustomer.find_by(c_no: params[:c_code])
            @c_info = PcbCustomer.find_by_sql("SELECT * FROM `pcb_customers`  WHERE (`pcb_customers`.`c_no` LIKE '%#{params[:c_code]}%' OR `pcb_customers`.`customer` LIKE '%#{params[:c_code]}%' OR `pcb_customers`.`customer_com` LIKE '%#{params[:c_code]}%' OR `pcb_customers`.`email` LIKE '%#{params[:c_code]}%') AND `pcb_customers`.`follow` = '#{current_user.email}'")
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
                @c_table += '<th width="70">客户代码</th>'
                @c_table += '<th>客户名</th>'
                @c_table += '<th>客户公司名</th>'
                @c_table += '<th width="70">所属</th>'
                @c_table += '<tr>'
                @c_table += '</thead>'
                @c_table += '<tbody>'
                @c_info.each do |cu|
                    @c_table += '<tr>'
                    #@c_table += '<td>' + cu.c_no + '</td>'
                    @c_table += '<td><a rel="nofollow" data-method="get"  href="/find_c_pi_ch?id='+ cu.id.to_s + '&c_pi_no=' + params[:c_pi_no] + '"><div>' + cu.c_no + '</div></a></td>'
                    @c_table += '<td><a rel="nofollow" data-method="get"  href="/find_c_pi_ch?id='+ cu.id.to_s + '&c_pi_no=' + params[:c_pi_no] + '"><div>' + cu.customer.to_s + '</div></a></td>'
                    @c_table += '<td><a rel="nofollow" data-method="get"  href="/find_c_pi_ch?id='+ cu.id.to_s + '&c_pi_no=' + params[:c_pi_no] + '"><div>' + cu.customer_com.to_s + '</div></a></td>'
                    @c_table += '<td><a rel="nofollow" data-method="get"  href="/find_c_pi_ch?id='+ cu.id.to_s + '&c_pi_no=' + params[:c_pi_no] + '"><div>' + User.find_by(email: cu.sell).full_name.to_s + '</div></a></td>'
                    @c_table += '</tr>'
                end
                @c_table += '</tbody>'
                @c_table += '</table>'
                @c_table += '</small>'
                Rails.logger.info("add-------------------------------------12")
                Rails.logger.info(@c_table.inspect)
                Rails.logger.info("add-------------------------------------12")
            end
        end
    end


    def follow
        select_customer = PcbCustomer.find(params[:id])
        if select_customer
            if params[:cancel]
                select_customer.follow = nil
            else
                select_customer.follow = current_user.email
            end
            select_customer.save
        end
        #redirect_to sell_pcb_baojia_path(follow: true)
        redirect_to :back
    end

    def sell_pcb_baojia
        if can? :work_e, :all
            if params[:follow]
                if can? :work_a, :all
                    @quate = PcbCustomer.find_by_sql("SELECT * FROM `pcb_customers`  WHERE follow IS NOT NULL ORDER BY pcb_customers.created_at DESC").paginate(:page => params[:page], :per_page => 10) 
                else
                    @quate = PcbCustomer.find_by_sql("SELECT * FROM `pcb_customers` WHERE follow LIKE '%#{current_user.email}%'  ORDER BY pcb_customers.created_at DESC").paginate(:page => params[:page], :per_page => 10) 
                end
                render "sell_pcb_baojia_follow.html.erb"
            else
                where_date = ""
                where_p = "pcb_customers.c_no LIKE '%%'"
                if params[:start_date] != "" and params[:start_date] != nil
                    where_date += " AND pcb_customers.created_at > '#{params[:start_date]}'"
                end
                if params[:end_date] != "" and params[:end_date] != nil
                    where_date += " AND pcb_customers.created_at < '#{params[:end_date]}'"
                end
                if can? :work_top, :all
                    @quate = PcbCustomer.find_by_sql("SELECT * FROM `pcb_customers` WHERE #{where_p + where_date}  ORDER BY pcb_customers.created_at DESC").paginate(:page => params[:page], :per_page => 10) 
                else
                    @quate = PcbCustomer.find_by_sql("SELECT * FROM `pcb_customers` WHERE #{where_p + where_date} AND pcb_customers.sell = '#{current_user.email}'  ORDER BY pcb_customers.created_at DESC").paginate(:page => params[:page], :per_page => 10) 
                end
                render "sell_pcb_baojia.html.erb"
            end
        else
            render plain: "You don't have permission to view this page !"
        end
    end

    def select_pcbcustomer_ajax
        select_customer = PcbCustomer.find(params[:id])
        if select_customer
            @sell = select_customer.sell
            @c_no = select_customer.c_no
            Rails.logger.info("add-------------------------------------12")
            Rails.logger.info(@c_no.inspect)
            Rails.logger.info("add-------------------------------------12")
        end
    end



    def edit_pcb_order
        @all_dn = "[&quot;"
        all_s_dn = Product.find_by_sql("SELECT DISTINCT products.part_name FROM products GROUP BY products.part_name")
        all_s_dn.each do |dn|
            @all_dn += "&quot;,&quot;" + dn.part_name.to_s
        end
        @all_dn += "&quot;]"
        @q_order = PcbOrder.find_by(order_no: params[:order_no])
        @q_order_item = PcbOrderItem.where(pcb_order_id: @q_order.id)
        @q_order_sell_item = PcbOrderSellItem.where(pcb_order_id: @q_order.id)
    end

    def update_pcb_order
        if params[:commit] == "保存到草稿"
            q_order = PcbOrder.find_by(order_no: params[:p_no])
            q_order.p_name = params[:p_name]
            q_order.follow_remark = params[:teshu_remark]
            q_order.save
            redirect_to :back and return
        elsif params[:commit] == "提交"
            q_order = PcbOrder.find_by(order_no: params[:p_no])
            q_order.p_name = params[:p_name]
            q_order.follow_remark = params[:teshu_remark]
            if can? :work_admin, :all 
                q_order.state = "quotechk"
            elsif can? :work_e, :all
                q_order.state = "bom_chk"
            elsif can? :work_d, :all
                q_order.state = "quote"
            elsif can? :work_g, :all 
                q_order.state = "quotechk"
            end
            if q_order.save
                if q_order.state == "bom_chk"
                    get_cu = PcbCustomer.find_by_id(q_order.pcb_customer_id)
                    if not get_cu.blank?
                        get_cu.c_time = get_cu.c_time + 1
                        get_cu.save
                    end
                end
            end
            redirect_to pcb_order_list_path(quote: true) and return
        end
    end

    def del_pcb_order
        pcb_order = PcbOrder.find(params[:order_id])
        if can? :work_e, :all or can? :work_d, :all
            pcb_order.del_flag = "inactive"
            if pcb_order.save
            #pcb_order.destroy
                get_cu = PcbCustomer.find_by_id(pcb_order.pcb_customer_id)
                    if not get_cu.blank?
                        get_cu.c_time = get_cu.c_time - 1
                        get_cu.save
                    end
            end
        end
        redirect_to :back
    end

    def update_pcb_price
        pcb = PcbOrder.find_by(order_no: params[:order_no])
        if not params[:price].blank?
            pcb.price = params[:price]
        end
        if not params[:p_name].blank?
            pcb.p_name = params[:p_name]
        end
        if not params[:des_en].blank?
            pcb.des_en = params[:des_en]
        end
        if not params[:des_cn].blank?
            pcb.des_cn = params[:des_cn]
        end
        if not params[:p_name].blank?
            pcb.p_name = params[:p_name]
        end
        if not params[:qty].blank?
            pcb.qty = params[:qty]
        end
        if not params[:remark].blank?
            pcb.remark = params[:remark]
        end
        if not params[:att].blank?
            pcb.att = params[:att]
        end
        if not params[:follow_remark].blank?
            pcb.follow_remark = params[:follow_remark]
        end
        pcb.price_eng = current_user.full_name
        pcb.save
        redirect_to :back
    end    

    def release_pcb_to_order
        pcb = PcbOrder.find_by(order_no: params[:order_no])
        pcb.state = "order"
        pcb.follow_remark = params[:f_remark]
        pcb.qty = params[:qty]
        pcb.save
        redirect_to pcb_order_list_path(place_an_order: true)
    end

    def release_pcb_to_quotechk
        pcb = PcbOrder.find(params[:bom_id])
        pcb.state = "quotechk"
        pcb.save
        redirect_to pcb_order_list_path(quotechk: true)
    end

    def release_pcb_to_quote
        pcb = PcbOrder.find(params[:bom_id])
        pcb.state = "quote"
        pcb.save
        redirect_to pcb_order_list_path(quote: true)
    end

    def pcb_order_list

        if params[:key_order]
            if can? :work_a, :all
                @pcblist = PcbOrder.where("del_flag = 'active' AND (c_code LIKE '%#{params[:key_order]}%' OR c_des LIKE '%#{params[:key_order]}%' OR p_name LIKE '%#{params[:key_order]}%' OR des_cn LIKE '%#{params[:key_order]}%' OR des_en LIKE '%#{params[:key_order]}%' OR order_no LIKE '%#{params[:key_order]}%' OR remark LIKE '%#{params[:key_order]}%' OR follow_remark LIKE '%#{params[:key_order]}%')").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
            elsif can? :work_e, :all
                @pcblist = PcbOrder.where("del_flag = 'active' AND (c_code LIKE '%#{params[:key_order]}%' OR c_des LIKE '%#{params[:key_order]}%' OR p_name LIKE '%#{params[:key_order]}%' OR des_cn LIKE '%#{params[:key_order]}%' OR des_en LIKE '%#{params[:key_order]}%' OR order_no LIKE '%#{params[:key_order]}%' OR remark LIKE '%#{params[:key_order]}%' OR follow_remark LIKE '%#{params[:key_order]}%') AND order_sell = '#{current_user.email}'").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
            else
                @pcblist = PcbOrder.where("del_flag = 'active' AND (c_code LIKE '%#{params[:key_order]}%' OR c_des LIKE '%#{params[:key_order]}%' OR p_name LIKE '%#{params[:key_order]}%' OR des_cn LIKE '%#{params[:key_order]}%' OR des_en LIKE '%#{params[:key_order]}%' OR order_no LIKE '%#{params[:key_order]}%' OR remark LIKE '%#{params[:key_order]}%' OR follow_remark LIKE '%#{params[:key_order]}%')").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
            end
        else
            if params[:new] 
                if can? :work_a, :all
                    @pcblist = PcbOrder.where(state: "new",del_flag: "active").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                elsif can? :work_e, :all
                    @pcblist = PcbOrder.where(state: "new",order_sell: current_user.email,del_flag: "active").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    @pcblist = PcbOrder.where(state: "new",del_flag: "active").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                end
                render "new_pcb_order_list.html.erb" and return
            elsif params[:quote]
                if can? :work_a, :all
                    @pcblist = PcbOrder.where(state: "quote",del_flag: "active").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                elsif can? :work_e, :all
                    @pcblist = PcbOrder.where(state: "quote",order_sell: current_user.email,del_flag: "active").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    @pcblist = PcbOrder.where(state: "quote",del_flag: "active").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                end
                render "pcb_order_list.html.erb" and return
            elsif params[:bom_chk]
                if can? :work_a, :all
                    @pcblist = PcbOrder.where(state: "bom_chk",del_flag: "active").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                elsif can? :work_e, :all
                    @pcblist = PcbOrder.where(state: "bom_chk",order_sell: current_user.email,del_flag: "active").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    @pcblist = PcbOrder.where(state: "bom_chk",del_flag: "active").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                end
                render "pcb_order_list.html.erb" and return
            elsif params[:place_an_order]
                if can? :work_a, :all
                    @pcblist = PcbOrder.where(state: "order",del_flag: "active").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                elsif can? :work_e, :all
                    @pcblist = PcbOrder.where(state: "order",order_sell: current_user.email,del_flag: "active").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    @pcblist = PcbOrder.where(state: "order",del_flag: "active").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                end
                render "pcb_order_list.html.erb" and return
            elsif params[:quotechk]
                if can? :work_a, :all
                    @pcblist = PcbOrder.where(state: "quotechk",del_flag: "active").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                elsif can? :work_e, :all
                    @pcblist = PcbOrder.where(state: "quotechk",order_sell: current_user.email,del_flag: "active").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    @pcblist = PcbOrder.where(state: "quotechk",del_flag: "active").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                end
                render "pcb_order_list.html.erb" and return
            else
                if can? :work_a, :all
                    @pcblist = PcbOrder.where("del_flag = 'active' AND state <> 'new' ").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                elsif can? :work_e, :all
                    @pcblist = PcbOrder.where("del_flag = 'active' AND state <> 'new' AND order_sell = '#{current_user.email}'").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    @pcblist = PcbOrder.where("del_flag = 'active' AND state <> 'new' ").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                end
            end
        end
    end

    def add_pcb_order_item
        @pcb = PcbOrderItem.new()
        @pcb.pcb_order_id = params[:c_order_id]
        @pcb.pcb_order_no = params[:c_order_no]
        @pcb.c_id = params[:c_id]
        @pcb.moko_code = params[:moko_code]
        @pcb.moko_des = params[:moko_des]
        @pcb.des_en = params[:des_en] 
        @pcb.des_cn = params[:des_cn]
        @pcb.qty = params[:qty]
        @pcb.att = params[:att]
        @pcb.p_type = params[:p_type]    
        @pcb.remark = params[:follow_remark]
        @pcb.save
        redirect_to :back
    end

    def add_pcb_order_sell_item
        find_sell_item = PcbOrderSellItem.where(pcb_order_no: params[:c_order_no_sell])
=begin
        if not find_sell_item.blank?
            find_sell_item.each do |del_item|
                del_item.destroy
            end
        end
=end
        @pcb = PcbOrderSellItem.new
        @pcb.pcb_order_id = params[:c_order_id_sell]
        @pcb.pcb_order_no = params[:c_order_no_sell]
        @pcb.c_id = params[:c_id_sell]
        @pcb.des_en = params[:des_en_sell] 
        @pcb.des_cn = params[:des_cn_sell]
        @pcb.qty = params[:qty_sell]
        @pcb.att = params[:att_sell]   
        @pcb.remark = params[:follow_remark_sell]
        @pcb.save
        redirect_to :back
    end

    def edit_pcb_order_sell_item
        @pcb = PcbOrderSellItem.find(params[:edit_c_item_id_sell])
        @pcb.des_en = params[:edit_des_en_sell] 
        @pcb.des_cn = params[:edit_des_cn_sell]
        @pcb.qty = params[:edit_qty_sell]
        @pcb.att = params[:edit_att_sell] 
        if not params[:edit_att_sell].blank?
            @pcb.att = params[:edit_att_sell]
        end  
        @pcb.remark = params[:edit_follow_remark_sell]
        @pcb.save
        redirect_to :back
    end

    def del_pcb_order_sell_item
        pcb = PcbOrderSellItem.find(params[:id])
        pcb.destroy
        redirect_to :back
    end

    def edit_pcb_order_item
        product_id = nil
        if params[:edit_moko_code] != ""
            product_id = Product.find_by_name(params[:edit_moko_code]).id
        end
        @pcb = PcbOrderItem.find(params[:edit_c_item_id])
        @pcb.moko_code = params[:edit_moko_code]
        @pcb.moko_des = params[:edit_moko_des]
        @pcb.des_en = params[:edit_des_en] 
        @pcb.des_cn = params[:edit_des_cn]
        @pcb.qty = params[:edit_qty]
        if not params[:edit_att].blank?
            @pcb.att = params[:edit_att]
        end
        if params[:edit_p_type] != ""
            @pcb.p_type = params[:edit_p_type] 
            if params[:edit_p_type] == "PCBA"
#创建PCB
                copy_data = PcbOrderItem.new
                copy_data.item_pcba_id = @pcb.id
                copy_data.p_type = "PCB"
                copy_data.c_id = @pcb.c_id
                copy_data.pcb_order_id = @pcb.pcb_order_id
                copy_data.pcb_order_sell_item_id = @pcb.pcb_order_sell_item_id
                copy_data.pcb_order_no = @pcb.pcb_order_no
                #if PcbOrderItem.find_by_pcb_order_no(@pcb.pcb_order_no).blank?
                    #p_n =1
                #else
                    #p_n = PcbOrderItem.where(pcb_order_no: @pcb.pcb_order_no,).last.pcb_order_no_son.split('-')[-1].to_i + 1
                #end
                #@p_no = "MK" + Time.new.strftime('%y%m%d').to_s + current_user.s_name_self.to_s.upcase + p_n.to_s
                copy_data.pcb_order_no_son = @pcb.pcb_order_no_son + "-PCB"
                copy_data.des_en = @pcb.des_en
                copy_data.des_cn = @pcb.des_cn
                copy_data.qty = @pcb.qty
                copy_data.att = @pcb.att
                copy_data.remark = @pcb.remark
                copy_data.save
                @pcb.item_pcb_id = copy_data.id
                q_order = PcbOrder.find_by_id(@pcb.pcb_order_id)
                q_order.state = "quote"
                q_order.save
            end
        end
   
        @pcb.remark = params[:edit_follow_remark]
        if params[:edit_price]
            @pcb.t_p = params[:edit_price]
            @pcb.price = BigDecimal.new(params[:edit_price])/@pcb.qty
        end
        if @pcb.save
            if @pcb.p_type == "COMPONENTS"
                find_in_bomlist = ProcurementBom.find_by_erp_item_id(@pcb.id)
                if find_in_bomlist.blank?
                    @bom = ProcurementBom.new
                    if ProcurementBom.find_by_sql('SELECT no FROM procurement_boms WHERE to_days(procurement_boms.created_at) = to_days(NOW())').blank?
                        order_n =1
                    else      
                        order_n = ProcurementBom.find_by_sql('SELECT no FROM procurement_boms WHERE to_days(procurement_boms.created_at) = to_days(NOW())').last.no.split("B")[-1].to_i + 1
                    end
                    @bom.no = "MB" + Time.new.strftime('%Y').to_s[-1] + Time.new.strftime('%m%d').to_s + "B" + order_n.to_s + "B"
                    @bom.erp_no = @pcb.pcb_order_no
                    @bom.p_name_mom = @pcb.pcb_order_no
                    @bom.erp_no_son = @pcb.pcb_order_no_son
                    @bom.p_name = @pcb.pcb_order_no_son
                    @bom.erp_qty = @pcb.qty
                    @bom.qty = 1
                    @bom.att = @pcb.att
                    @bom.user_id = current_user.id
                    if @bom.save
                        @pcb.bom_id = @bom.id
                        @pcb.save
                        bom_item = @bom.p_items.build()
                        #bom_item.part_code = refa
=begin
                        if refa.blank? 
                            bom_item.user_do = 7
                        else
                            if refa =~ /r/i or refa =~ /c/i or refa =~ /d/i or refa =~ /v/i or refa =~ /q/i or refa =~ /lcd/i or refa =~ /led/i or refa =~ /ic/i or refa =~ /z/i or refa =~ /u/i
                            #bom_item.user_do = 77
                                bom_item.user_do = 7
                            elsif refa =~ /l/i or refa =~ /x/i or refa =~ /sw/i or refa =~ /s/i or refa =~ /vr/i or refa =~ /w/i or refa =~ /k/i or refa =~ /rl/i or refa =~ /fb/i or refa =~ /fr/i or refa =~ /y/i or refa =~ /f/i or refa =~ /pf/i or refa =~ /j/i or refa =~ /con/i or refa =~ /jp/i or refa =~ /bz/i
                                bom_item.user_do = 75
                            else
                                bom_item.user_do = 7
                            end
                        end
=end
                        bom_item.p_type = "COMPONENTS"
		        bom_item.description = @pcb.des_en + "---" + @pcb.des_cn
                        bom_item.quantity = @pcb.qty
                        bom_item.product_id = product_id
                        bom_item.moko_part = @pcb.moko_code
                        bom_item.moko_des = @pcb.moko_des
                        #bom_item.mpn = mpna
                        #bom_item.fengzhuang = fengzhuang
                        #bom_item.link = link
                        #bom_item.other = othera
                        #bom_item.all_info = all_info.chop
                        bom_item.user_id = current_user.id
                        bom_item.erp_id = @bom.erp_id
                        bom_item.erp_no = @bom.erp_no
                        bom_item.save
                        
                    end
                else
                    @bom = find_in_bomlist
                    @bom.erp_no = @pcb.pcb_order_no
                    @bom.p_name_mom = @pcb.pcb_order_no
                    @bom.erp_no_son = @pcb.pcb_order_no_son
                    @bom.p_name = @pcb.pcb_order_no_son
                    @bom.erp_qty = 1
                    @bom.qty = @pcb.qty
                    @bom.att = @pcb.att
                    if @bom.save
                        @pcb.bom_id = @bom.id
                        @pcb.save
                        old_item = PItem.where(procurement_bom_id: @bom.id)
                        old_item.each do |item|
                           item.destroy
                        end
                        bom_item = @bom.p_items.build()
                        #bom_item.part_code = refa
=begin
                        if refa.blank? 
                            bom_item.user_do = 7
                        else
                            if refa =~ /r/i or refa =~ /c/i or refa =~ /d/i or refa =~ /v/i or refa =~ /q/i or refa =~ /lcd/i or refa =~ /led/i or refa =~ /ic/i or refa =~ /z/i or refa =~ /u/i
                            #bom_item.user_do = 77
                                bom_item.user_do = 7
                            elsif refa =~ /l/i or refa =~ /x/i or refa =~ /sw/i or refa =~ /s/i or refa =~ /vr/i or refa =~ /w/i or refa =~ /k/i or refa =~ /rl/i or refa =~ /fb/i or refa =~ /fr/i or refa =~ /y/i or refa =~ /f/i or refa =~ /pf/i or refa =~ /j/i or refa =~ /con/i or refa =~ /jp/i or refa =~ /bz/i
                                bom_item.user_do = 75
                            else
                                bom_item.user_do = 7
                            end
                        end
=end
                        bom_item.p_type = "COMPONENTS"
		        bom_item.description = @pcb.des_en + "---" + @pcb.des_cn
                        bom_item.quantity = @pcb.qty
                        bom_item.product_id = product_id
                        bom_item.moko_part = @pcb.moko_code
                        bom_item.moko_des = @pcb.moko_des
                        #bom_item.mpn = mpna
                        #bom_item.fengzhuang = fengzhuang
                        #bom_item.link = link
                        #bom_item.other = othera
                        #bom_item.all_info = all_info.chop
                        bom_item.user_id = current_user.id
                        bom_item.erp_id = @bom.erp_id
                        bom_item.erp_no = @bom.erp_no
                        bom_item.save
                        
                    end
                end
                q_order = PcbOrder.find_by_id(@pcb.pcb_order_id)
                q_order.state = "quote"
                q_order.save
            
            elsif @pcb.p_type == "PCB"
                @pcb.bom_id = nil
                q_order = PcbOrder.find_by_id(@pcb.pcb_order_id)
                q_order.state = "quote"
                q_order.save
                @pcb.save
            end
        end
        redirect_to :back
    end

    def edit_pi_item
        edit_pi_item = PiItem.find(params[:edit_c_item_id])
=begin
        edit_pi_item.t_p = params[:edit_t_p]
        edit_pi_item.price = params[:edit_price]
        edit_pi_item.des_en = params[:edit_des_en]
        edit_pi_item.des_cn = params[:edit_des_cn]
        edit_pi_item.qty = params[:edit_qty]
        edit_pi_item.remark = params[:edit_follow_remark]
=end
        edit_pi_item.c_p_no = params[:edit_c_p_no]
        edit_pi_item.pcb_size = params[:edit_pcb_size]
        edit_pi_item.qty = params[:edit_qty]  
        edit_pi_item.layer = params[:edit_layer]
        edit_pi_item.des = params[:edit_des]
        edit_pi_item.unit_price = (params[:edit_pcb_price].to_f.round(3) + params[:edit_com_cost].to_f.round(3) + params[:edit_pcba].to_f.round(3))/params[:edit_qty].to_i
        edit_pi_item.pcb_price =params[:edit_pcb_price]
        edit_pi_item.com_cost = params[:edit_com_cost]
        edit_pi_item.pcba = params[:edit_pcba]
        edit_pi_item.t_p = params[:edit_pcb_price].to_f.round(3) + params[:edit_com_cost].to_f.round(3) + params[:edit_pcba].to_f.round(3)
        if edit_pi_item.save
            get_rate_data = SetupFinanceInfo.find_by_id(1).dollar_rate

            all_item_t_p = PiItem.find_by_sql("SELECT t_p FROM pi_items WHERE pi_info_id = #{edit_pi_item.pi_info_id} GROUP BY pi_info_id").first.t_p
            all_other_t_p_data = PiOtherItem.find_by_sql("SELECT t_p FROM pi_other_items WHERE pi_info_id = #{edit_pi_item.pi_info_id} GROUP BY pi_info_id")
            if not all_other_t_p_data.blank?
                all_other_t_p = all_other_t_p_data.first.t_p
            end 
            if all_item_t_p.blank?
                all_item_t_p = 0
            end
            if all_other_t_p.blank?
                all_other_t_p = 0
            end
            get_pi_data = PiInfo.find_by_id(edit_pi_item.pi_info_id)
            if get_pi_data.pi_shipping_cost.blank?
                pi_shipping_cost = 0
            else
                pi_shipping_cost = get_pi_data.pi_shipping_cost
            end
            if get_pi_data.pi_bank_fee.blank?
                pi_bank_fee = 0
            else
                pi_bank_fee = get_pi_data.pi_bank_fee
            end

            get_pi_data.t_p = all_item_t_p + all_other_t_p + pi_shipping_cost + pi_bank_fee
            get_pi_data.t_p_rmb = (all_item_t_p + all_other_t_p + pi_shipping_cost + pi_bank_fee) * get_rate_data
            get_pi_data.save
        end
=begin
        if edit_pi_item.save
            if edit_pi_item.p_type == "PCBA"
                get_bom = ProcurementBom.find_by_id(edit_pi_item.bom_id)
                if not get_bom.blank?
                    if get_bom.pi_lock == "lock"
                        redirect_to :back and return
                    end
                    bom_item = PItem.where(procurement_bom_id: get_bom.id)
                    if not bom_item.blank?
                        t_p = 0
                        bom_item.each do |item|
                            #item.pmc_qty = get_bom.qty.to_i*item.quantity.to_i
                            item.pi_qty = PiItem.find_by_sql("SELECT SUM(qty) AS qty FROM pi_items WHERE pi_info_id = #{edit_pi_item.pi_info_id}").first.qty.to_i*item.quantity.to_i
                            item.save
                            if not item.cost.blank?
                                t_p = t_p + (params[:edit_qty].to_i*item.quantity.to_i*item.cost)
                            end
                        end
                        #get_bom.t_p = t_p
                        if params[:edit_com_cost].blank?
                            edit_pi_item.com_cost = t_p
                        else 
                            edit_pi_item.com_cost = params[:edit_com_cost]
                        end
                        edit_pi_item.save
                    end
                    #get_bom.qty = edit_pi_item.qty
                    #get_bom.save
                end
            end
        end
=end
        redirect_to :back
    end

    def add_pi_other_item
        add_item = PiOtherItem.new
        add_item.pi_info_id = params[:add_pi_info_id_other]
        add_item.c_id = params[:add_c_id_other]
        add_item.pi_no = params[:add_pi_no_other]
        add_item.p_type = params[:add_type_other]
        add_item.remark = params[:add_remark_other]
        add_item.t_p = params[:add_t_p_other]
        add_item.save
        if add_item.save
            get_rate_data = SetupFinanceInfo.find_by_id(1).dollar_rate

            all_item_t_p = PiItem.find_by_sql("SELECT SUM(t_p) AS t_p FROM pi_items WHERE pi_info_id = #{params[:add_pi_info_id_other]} GROUP BY pi_info_id").first.t_p
            all_other_t_p_data = PiOtherItem.find_by_sql("SELECT SUM(t_p) AS t_p FROM pi_other_items WHERE pi_info_id = #{params[:add_pi_info_id_other]} GROUP BY pi_info_id")
            if not all_other_t_p_data.blank?
                all_other_t_p = all_other_t_p_data.first.t_p
            end 
            if all_item_t_p.blank?
                all_item_t_p = 0
            end
            if all_other_t_p.blank?
                all_other_t_p = 0
            end
            get_pi_data = PiInfo.find_by_id(params[:add_pi_info_id_other])
            if get_pi_data.pi_shipping_cost.blank?
                pi_shipping_cost = 0
            else
                pi_shipping_cost = get_pi_data.pi_shipping_cost
            end
            if get_pi_data.pi_bank_fee.blank?
                pi_bank_fee = 0
            else
                pi_bank_fee = get_pi_data.pi_bank_fee
            end

            get_pi_data.t_p = all_item_t_p + all_other_t_p + pi_shipping_cost + pi_bank_fee
            get_pi_data.t_p_rmb = (all_item_t_p + all_other_t_p + pi_shipping_cost + pi_bank_fee) * get_rate_data
            get_pi_data.save
        end
        redirect_to :back
    end

    def add_pi_sb
        get_rate_data = SetupFinanceInfo.find_by_id(1).dollar_rate

        all_item_t_p = PiItem.find_by_sql("SELECT SUM(t_p) AS t_p FROM pi_items WHERE pi_info_id = #{params[:add_pi_sb_id]} GROUP BY pi_info_id").first.t_p
        all_other_t_p_data = PiOtherItem.find_by_sql("SELECT SUM(t_p) AS t_p FROM pi_other_items WHERE pi_info_id = #{params[:add_pi_sb_id]} GROUP BY pi_info_id")
        if not all_other_t_p_data.blank?
           all_other_t_p = all_other_t_p_data.first.t_p
        end 
        if all_item_t_p.blank?
            all_item_t_p = 0
        end
        if all_other_t_p.blank?
            all_other_t_p = 0
        end
        get_pi_data = PiInfo.find_by_id(params[:add_pi_sb_id])

        if params[:add_sc].blank?
            pi_shipping_cost = 0
        else
            pi_shipping_cost = params[:add_sc].to_f
        end
        if params[:add_bf].blank?
            pi_bank_fee = 0
        else
            pi_bank_fee = params[:add_bf].to_f
        end

        get_pi_data.pi_shipping_cost = params[:add_sc]
        get_pi_data.pi_bank_fee = params[:add_bf]

        get_pi_data.t_p = all_item_t_p + all_other_t_p + pi_shipping_cost + pi_bank_fee
        get_pi_data.t_p_rmb = (all_item_t_p + all_other_t_p + pi_shipping_cost + pi_bank_fee) * get_rate_data
        get_pi_data.save




        redirect_to :back
    end

    def edit_pi_other_item
        add_item = PiOtherItem.find(params[:edit_item_id_other])     
        add_item.p_type = params[:edit_p_type_other]
        add_item.remark = params[:edit_remark_other]
        add_item.t_p = params[:edit_t_p_other]
        add_item.save
        redirect_to :back
    end

    def del_pcb_order_item
        pcb = PcbOrderItem.find(params[:edit_c_item_id])
        pcb.destroy
        redirect_to :back
    end

    def add_pcb_customer
        if params[:customer_country].blank?
            redirect_to :back, :flash => {:error => "请填写国家！！！"} and return false
        end
        @pcb = PcbCustomer.new()
        #@pcb.user_id = current_user.id
        if PcbCustomer.maximum("id").blank?
            @pcb.c_no = "pcb1"
        else
            @pcb.c_no = "pcb" + (PcbCustomer.maximum("id") + 1).to_s
        end
        @pcb.customer = params[:customer].to_s.gsub(/'/,'')
        @pcb.customer_com = params[:customer_com].to_s.gsub(/'/,'')
        @pcb.email = params[:email] .to_s.gsub(/'/,'')
        @pcb.sell = current_user.email .to_s.gsub(/'/,'')
        @pcb.qty = params[:qty].to_s.gsub(/'/,'')
        @pcb.att = params[:att].to_s.gsub(/'/,'')
        @pcb.remark= params[:remark].to_s.gsub(/'/,'')
        @pcb.customer_country = params[:customer_country].to_s.gsub(/'/,'')
        @pcb.shipping_address = params[:shipping_address]   .to_s.gsub(/'/,'')   
        if not params[:c_order_no].blank?
            @pcb.follow = current_user.email           
        end
        @pcb.save
        if not params[:c_order_no].blank?
            up_c = PcbOrder.find_by(order_no: params[:c_order_no])
            up_c.pcb_customer_id = @pcb.id
            up_c.c_code = @pcb.c_no
            up_c.c_des = @pcb.customer
            up_c.c_country = @pcb.customer_country
            up_c.c_shipping_address = @pcb.shipping_address
            up_c.save
            redirect_to edit_pcb_order_path(order_no: params[:c_order_no],c_id: up_c.pcb_customer_id) and return
        end
        redirect_to :back
    end

    def edit_pcb_customer
        @pcb = PcbCustomer.find(params[:itemp_id])
        #@pcb.user_id = current_user.id
        if params[:follow_remark]
            follow = PcbCustomerRemark.new()
            follow.pcb_c_id = params[:itemp_id]
            follow.user_id = current_user.id
            follow.user_name = current_user.full_name
            follow.remark = params[:follow_remark].chomp
            
            follow.save
            @c_id = params[:itemp_id]
            @follow_remark = ""
            PcbCustomerRemark.where(pcb_c_id: @c_id).order("created_at DESC").each do |follow|
                @follow_remark += '<div><p class="bg-warning">'+follow.created_at.localtime.strftime('%Y-%m-%d %H:%M:%S')+' <strong>'+follow.user_name.to_s+': </strong>'+follow.remark.to_s+'</p></div>'
            end
            render "edit_pcb_customer.js.erb" and return
        else
            @pcb.customer = params[:customer]
            @pcb.email = params[:email] 
            @pcb.sell = current_user.email 
            @pcb.qty = params[:qty]
            @pcb.att = params[:att]
            @pcb.remark = params[:remark]
            @pcb.customer_country= params[:customer_country]
            @pcb.shipping_address= params[:shipping_address]
        end
        @pcb.save
        redirect_to :back
    end

    def moko_part_manage
        if can? :work_baojia, :all
            start_date = ""
            if params[:start_date] != ""
                start_date = " AND products.created_at > '#{params[:start_date]}'"
            end
            end_date = ""
            if params[:end_date] != ""
                end_date = " AND products.created_at < '#{params[:end_date]}'"
            end
            if params[:order_s]
                if params[:order_s][:order_s].to_i == 1
                    @order_check_1 = true
                    @order_check_2 = false
                    @moko_part = Product.find_by_sql("SELECT * FROM `products` WHERE `products`.`name` LIKE '%#{params[:part_name]}%'" + start_date + end_date ).paginate(:page => params[:page], :per_page => 10)
                elsif params[:order_s][:order_s].to_i == 2
                    where_des = ""
                    if params[:part_name] != ""
                        des = params[:part_name].strip.split(" ")
                        des.each_with_index do |de,index|
                            where_des += "products.description LIKE '%#{de}%'"
                            if des.size > (index + 1)
                                where_des += " AND "
                            end
                        end 
                    else
                        where_des = "products.description LIKE '%%'"
                    end     
                    @order_check_1 = false
                    @order_check_2 = true
                    @moko_part = Product.find_by_sql("SELECT * FROM `products` WHERE #{where_des}" + start_date + end_date ).paginate(:page => params[:page], :per_page => 10)
                end
            end
            render "moko_part_manage.html.erb"
        else
            render plain: "You don't have permission to view this page !"
        end
    end

    def moko_part_update
        Rails.logger.info("add-------------------------------------add")
        Rails.logger.info(params.inspect)
        Rails.logger.info("add-------------------------------------add")
        @item_id = params[:item_id]
        if params[:part_a] == ""  or params[:part_c] == "" or params[:abc] == ""
            #flash[:error] = "Part information can not be empty!!!"
            redirect_to :back and return
            #render "add_moko_part.js.erb" and return
        else
            name_a = "A." + params[:part_a].upcase + "." + params[:part_b].upcase + ".F."
            part_name_find = Product.find_by_sql("SELECT LPAD((MAX(SUBSTRING_INDEX(SUBSTRING_INDEX(products.`name`, '.' ,-1) , '-' ,1))+1 ) ,4,'0') AS part_n   FROM products WHERE `name` LIKE '%"+ name_a +"%'")
            if part_name_find.first.part_n.blank?
               part_name_find = "0001"
            else
               part_name_find = part_name_find.first.part_n.to_s
            end
            @new_part = Product.find(params[:item_id])
            #@new_part.name = name_a + part_name_find.to_s + "-" + params[:package2]
            @new_part.name = params[:mokopart_name]
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
            @new_part.save
        end
        redirect_to :back and return
    end
    
    def unfollow_bom_item
        item = PItem.find(params[:id])
        item.sell_feed_back_tag = nil
        item.save
        redirect_to :back and return
    end

    def unfollow_bom_item_more
        if not params[:unfollow_item].blank?
            params[:unfollow_item].each do |id|
                item = PItem.find(id)
                item.sell_feed_back_tag = nil
                item.save    
            end
        end
        redirect_to :back and return
    end

    def sell_view_baojia
        @dollar_rate = SetupFinanceInfo.find_by_id(1).dollar_rate
        @boms = ProcurementBom.find(params[:bom_id])
        @baojia = PItem.where(procurement_bom_id: params[:bom_id])
    end
    
    def sell_baojia_q
        if can? :work_admin, :all 
            @quate = PItem.find_by_sql("SELECT pcb_orders.order_sell, pcb_order_items.pcb_order_id, pcb_order_items.pcb_order_no_son, p_items.* FROM pcb_order_items INNER JOIN pcb_orders ON pcb_order_items.pcb_order_id = pcb_orders.id INNER JOIN p_items ON p_items.procurement_bom_id = pcb_order_items.bom_id WHERE pcb_order_items.p_type = 'PCBA' AND p_items.sell_feed_back_tag = 'sell'").paginate(:page => params[:page], :per_page => 20)
        else
            @quate = PItem.find_by_sql("SELECT pcb_orders.order_sell, pcb_order_items.pcb_order_id, pcb_order_items.pcb_order_no_son, p_items.* FROM pcb_order_items INNER JOIN pcb_orders ON pcb_order_items.pcb_order_id = pcb_orders.id INNER JOIN p_items ON p_items.procurement_bom_id = pcb_order_items.bom_id WHERE pcb_order_items.p_type = 'PCBA' AND pcb_orders.order_sell = '#{current_user.email}' AND p_items.sell_feed_back_tag = 'sell'").paginate(:page => params[:page], :per_page => 20)
        end
=begin
        where_p = ""
        if not current_user.s_name.blank?
            if current_user.s_name.size == 1
                s_name = current_user.s_name
               
                where_p = " POSITION('" + s_name + "' IN RIGHT(LEFT(procurement_boms.p_name_mom,9),7)) = 6 and RIGHT(LEFT(procurement_boms.p_name_mom,9),1) REGEXP '^[0-9]+$' "
                
            elsif current_user.s_name.size == 2
                s_name = current_user.s_name
               
                where_p = "  POSITION('" + s_name + "' IN procurement_boms.p_name_mom) = 8 "
               
            elsif current_user.s_name.size > 2
                if params[:sell] == "" or params[:sell] == nil
                    where_p = "("
                    current_user.s_name.split(",").each_with_index do |item,index|
                        s_name = item
                        if current_user.s_name.split(",").size > (index+1)
                        
                            where_p += "  LOCATE('" + s_name + "', procurement_boms.p_name_mom,3) = 8 OR"
                       
                        else
                       
                            where_p += "  LOCATE('" + s_name + "', procurement_boms.p_name_mom,3) = 8)"
                        
                        end
                    end
                else
                    if params[:sell].size == 1
                        s_name = params[:sell]
               
                        where_p = " POSITION('" + s_name + "' IN RIGHT(LEFT(procurement_boms.p_name_mom,9),7)) = 6 and RIGHT(LEFT(procurement_boms.p_name_mom,9),1) REGEXP '^[0-9]+$' "
                
                    elsif params[:sell].size == 2
                        s_name = params[:sell]
               
                        where_p = "  POSITION('" + s_name + "' IN procurement_boms.p_name_mom) = 8 "
                    end
                end
            end
            if params[:start_date] != "" and  params[:start_date] != nil
                where_date += " AND procurement_boms.created_at > '#{params[:start_date]}'"
            end
            if params[:end_date] != "" and  params[:end_date] != nil
                where_date += " AND procurement_boms.created_at < '#{params[:end_date]}'"
            end
            @quate = ProcurementBom.find_by_sql("SELECT procurement_boms.`p_name`,p_items.* FROM procurement_boms INNER JOIN p_items ON procurement_boms.id = p_items.procurement_bom_id WHERE #{where_p} AND p_items.sell_feed_back_tag = 'sell' ").paginate(:page => params[:page], :per_page => 10)
        else
            @quate = ProcurementBom.find_by_sql("SELECT procurement_boms.`p_name`,p_items.*  FROM procurement_boms INNER JOIN p_items ON procurement_boms.id = p_items.procurement_bom_id WHERE p_items.sell_feed_back_tag = 'sell'").paginate(:page => params[:page], :per_page => 10)
        end 
=end   
    end

    def clean_work_date_smd
        get_data = WorkFlow.find_by_id(params[:id])
        if not get_data.blank?
            get_data.smd_start_date = nil
            get_data.smd_end_date = nil

            get_data.smd_state = ""
            get_data.save
            redirect_to :back and return
        end
    end

    def clean_work_date_dip
        get_data = WorkFlow.find_by_id(params[:id])
        if not get_data.blank?

            get_data.dip_start_date = nil
            get_data.dip_end_date = nil

            get_data.save
            redirect_to :back and return
        end
    end

    def index
        #phone = '<img width="200" title="" align="" alt="" src="/uploads/image/201603/1d479d38ffe2.jpg" /> ccc>'
        #if ( phone =~ /width="(.\d*")/ )  
            #phone = phone.gsub!(/width="(.\d*")/, "")
        #end
        #dddddd = phone.scan(/width="(.\d*")/) 
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        Rails.logger.info(Rails.public_path)
        Rails.logger.info(Rails.env)
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        @open = "collapse" 
        @pic = "glyphicon glyphicon-plus"
        limit = "LIMIT 20"
        
        if params[:order]
            if params[:order].strip.size == 1
                order = params[:order].strip
                #where_def = "  POSITION('" + order + "' IN work_flows.order_no) = 8"
                where_def = "  (POSITION('" + order + "' IN RIGHT(LEFT(work_flows.order_no,9),7)) = 6 and RIGHT(LEFT(work_flows.order_no,9),1) REGEXP '^[0-9]+$') OR (POSITION('" + order + "' IN RIGHT(LEFT(work_flows.order_no,9),7)) = 7 and RIGHT(LEFT(work_flows.order_no,10),1) REGEXP '^[0-9]+$') "
                limit = ""
            elsif params[:order].strip.size == 2
                order = params[:order].strip
                #where_def = "  POSITION('" + order + "' IN work_flows.order_no) = 8"
                where_def = "  (POSITION('" + order + "' IN work_flows.order_no) = 8 AND RIGHT(LEFT(work_flows.order_no,10),1) REGEXP '^[0-9]+$') OR (POSITION('" + order + "' IN work_flows.order_no) = 9 AND RIGHT(LEFT(work_flows.order_no,8),1) REGEXP '^[0-9]+$')"
                
                limit = ""
            else
                order = params[:order].strip
                where_def = "  work_flows.order_no like '%" + order + "%'"
                #where_def = "  work_flows.order_no like '" + order + "'"
                limit = ""
            end
        else
            order = ""
            where_def = "  work_flows.order_no like '%" + order + "%'"
            #limit = ""
        end
        add_where = " AND work_flows.order_state != 1"
        @order_check_1 = false
        @order_check_2 = false
        @order_check_3 = true
        @order_check_4 = false
        if params[:order_s] 
            if params[:order_s][:order_s].to_i == 1 
                add_where = " " 
                @order_check_1 = true
                @order_check_2 = false
                @order_check_3 = false
                @order_check_4 = false
            elsif params[:order_s][:order_s].to_i == 2 
                add_where = " AND work_flows.order_state = 1"
                @order_check_2 = true
                @order_check_1 = false
                @order_check_3 = false
                @order_check_4 = false
            elsif params[:order_s][:order_s].to_i == 3 
                add_where = " AND work_flows.order_state != 1"
                @order_check_3 = true
                @order_check_2 = false
                @order_check_1 = false
                @order_check_4 = false
            elsif params[:order_s][:order_s].to_i == 4 
                where_def = " work_flows.product_code = '#{params[:order].strip}'"
                add_where = ""
                @order_check_3 = false
                @order_check_2 = false
                @order_check_1 = false
                @order_check_4 = true
            elsif params[:order_s][:order_s].to_i == 5 
                @order_check_3 = false
                @order_check_2 = false
                @order_check_1 = false
                @order_check_1 = false
                @order_check_5 = true
            end
        end
        if params[:empty_date] 
            add_where = ""
            if params[:empty_date] == "show_empty"
                empty_date = "(work_flows.smd_start_date IS NOT NULL AND work_flows.smd_end_date IS NULL OR work_flows.dip_start_date IS NOT NULL AND work_flows.dip_end_date IS NULL OR work_flows.supplement_date IS NOT NULL AND work_flows.clear_date IS NULL) AND work_flows.order_state != 1 AND "
                limit = ""
            elsif params[:empty_date] == "ready"
                @show_title = "料齐的订单"
                empty_date = "(work_flows.smd LIKE '%齐%' AND work_flows.smd_start_date IS NULL AND work_flows.order_state != 1) OR (work_flows.dip LIKE '%齐%' AND work_flows.dip_start_date IS NULL AND work_flows.order_state != 1) AND"
                limit = ""
            elsif params[:empty_date] == "danger"
                empty_date = "work_flows.order_state = 3 AND"
                limit = ""
            end
        else
            empty_date = ""
            #limit = ""
        end 
        if can? :work_c, :all
            #if params[:order] or  params[:empty_date]                    
                #add_where = ""        
                #@work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE "  + empty_date + where_def + add_where + "  ORDER BY work_flows.updated_at DESC " ).paginate(:page => params[:page], :per_page => 10)
            #else
                #@show_title = "未反馈的订单"
                #add_where = ""
                #@work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE "  + empty_date + where_def + add_where + " AND feedback_state = 1 ORDER BY work_flows.updated_at DESC " ).paginate(:page => params[:page], :per_page => 10)
            #end
            add_orderby = ""
            if params[:sort_date]
                if params[:sort_date] == "smd"
                    empty_date = ""
                    add_where = "AND smd_end_date IS NOT NULL AND work_flows.order_state != 1 "
                    add_orderby = " ORDER BY work_flows.smd_end_date "
                elsif params[:sort_date] == "dip"
                    empty_date = ""
                    add_where = "AND dip_end_date IS NOT NULL AND work_flows.order_state != 1 "
                    add_orderby = " ORDER BY work_flows.dip_end_date "
                elsif params[:sort_date] == "clear"
                    empty_date = ""
                    add_where = "AND clear_date IS NOT NULL AND work_flows.order_state != 1 "
                    add_orderby = " ORDER BY work_flows.clear_date " 
                elsif params[:sort_date] == "state"
                    empty_date = ""
                    add_where = "AND feed_state IS NOT NULL AND work_flows.order_state != 1 "
                    add_orderby = " ORDER BY work_flows.feed_state DESC" 
                elsif params[:sort_date] == "smd_start"
                    add_where = "AND feed_state IS NOT NULL AND work_flows.order_state != 1 "
                    add_orderby = " ORDER BY work_flows.smd_start_date DESC" 
                elsif params[:sort_date] == "dip_start"
                    add_where = "AND feed_state IS NOT NULL AND work_flows.order_state != 1 "
                    add_orderby = " ORDER BY work_flows.dip_start_date DESC" 
                end
            end
            Rails.logger.info("--------------------------------------add_orderby")
            Rails.logger.info(add_orderby)
            Rails.logger.info("--------------------------------------add_orderby") 
            @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE (work_flows.smd LIKE '%齐%' AND work_flows.smd_start_date IS NULL AND work_flows.order_state = 0) OR (work_flows.dip LIKE '%齐%' AND work_flows.dip_start_date IS NULL AND work_flows.order_state = 0) " + add_where + add_orderby).paginate(:page => params[:page], :per_page => 10)
            @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE topics.feedback_receive LIKE '%production%' ORDER BY topics.updated_at DESC " ).paginate(:page => params[:page], :per_page => 20)
            if params[:order] or params[:empty_date]
                @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + empty_date + where_def + add_where ).paginate(:page => params[:page], :per_page => 10)
                if @work_flow.size == 1                
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE product_code = '#{@work_flow.first.product_code}'").paginate(:page => params[:page], :per_page => 20)
                end
            end
            
            render "production.html.erb"
=begin
#工程部 
        elsif can? :work_d, :all
            start_date = ""
            if params[:start_date] != ""
                start_date = " AND topics.created_at > '#{params[:start_date]}'"
            end
            end_date = ""
            if params[:end_date] != ""
                end_date = " AND topics.created_at < '#{params[:end_date]}'"
            end
            @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE topics.feedback_receive LIKE '%engineering%' ORDER BY topics.updated_at DESC " ).paginate(:page => params[:page], :per_page => 20)
            if params[:order] 
                @work_flow = WorkFlow.find_by_sql("SELECT DISTINCT work_flows.order_no, work_flows.* FROM work_flows LEFT JOIN topics ON work_flows.id = topics.order_id WHERE " + where_def + add_where + start_date + end_date).paginate(:page => params[:page], :per_page => 10)
                #@work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + where_def + add_where).paginate(:page => params[:page], :per_page => 10)
                if @work_flow.size == 1                
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE product_code = '#{@work_flow.first.product_code}'").paginate(:page => params[:page], :per_page => 20)
                end
            end
            Rails.logger.info("--------------------------------------")
            Rails.logger.info("SELECT * FROM `work_flows` WHERE " + where_def + add_where)
            Rails.logger.info("--------------------------------------")
            render "engineering.html.erb"
            #if params[:order]  
                #add_where = ""          
                #@work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE "  + where_def + add_where + " ORDER BY work_flows.updated_at DESC "  ).paginate(:page => params[:page], :per_page => 10)
            #else
                #add_where = ""
                #@work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE "  + where_def + add_where + " AND feedback_state = 1 ORDER BY work_flows.updated_at DESC "  ).paginate(:page => params[:page], :per_page => 10)
            #end
            #render "test_feedback.list.html.erb"
=end
#BOM组
        elsif can? :work_d_bom, :all
            start_date = ""
            if params[:start_date] != ""
                start_date = " AND topics.created_at > '#{params[:start_date]}'"
            end
            end_date = ""
            if params[:end_date] != ""
                end_date = " AND topics.created_at < '#{params[:end_date]}'"
            end
            @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE topics.feedback_receive LIKE '%engineering_bom%' ORDER BY topics.updated_at DESC " ).paginate(:page => params[:page], :per_page => 20)
            if params[:order] 
                @work_flow = WorkFlow.find_by_sql("SELECT DISTINCT work_flows.order_no, work_flows.* FROM work_flows LEFT JOIN topics ON work_flows.id = topics.order_id WHERE " + where_def + add_where + start_date + end_date).paginate(:page => params[:page], :per_page => 10)
                #@work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + where_def + add_where).paginate(:page => params[:page], :per_page => 10)
                if @work_flow.size == 1                
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE product_code = '#{@work_flow.first.product_code}'").paginate(:page => params[:page], :per_page => 20)
                end
            end
            Rails.logger.info("--------------------------------------")
            Rails.logger.info("SELECT * FROM `work_flows` WHERE " + where_def + add_where)
            Rails.logger.info("--------------------------------------")
            render "engineering.html.erb"
#PCB组
        elsif can? :work_d_pcb, :all
            start_date = ""
            if params[:start_date] != ""
                start_date = " AND topics.created_at > '#{params[:start_date]}'"
            end
            end_date = ""
            if params[:end_date] != ""
                end_date = " AND topics.created_at < '#{params[:end_date]}'"
            end
            @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE topics.feedback_receive LIKE '%engineering_pcb%' ORDER BY topics.updated_at DESC " ).paginate(:page => params[:page], :per_page => 20)
            if params[:order] 
                @work_flow = WorkFlow.find_by_sql("SELECT DISTINCT work_flows.order_no, work_flows.* FROM work_flows LEFT JOIN topics ON work_flows.id = topics.order_id WHERE " + where_def + add_where + start_date + end_date).paginate(:page => params[:page], :per_page => 10)
                #@work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + where_def + add_where).paginate(:page => params[:page], :per_page => 10)
                if @work_flow.size == 1                
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE product_code = '#{@work_flow.first.product_code}'").paginate(:page => params[:page], :per_page => 20)
                end
            end
            Rails.logger.info("--------------------------------------")
            Rails.logger.info("SELECT * FROM `work_flows` WHERE " + where_def + add_where)
            Rails.logger.info("--------------------------------------")
            render "engineering.html.erb"

#ziliao组
        elsif can? :work_d_ziliao, :all
            start_date = ""
            if params[:start_date] != ""
                start_date = " AND topics.created_at > '#{params[:start_date]}'"
            end
            end_date = ""
            if params[:end_date] != ""
                end_date = " AND topics.created_at < '#{params[:end_date]}'"
            end
            @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE topics.feedback_receive LIKE '%engineering_ziliao%' ORDER BY topics.updated_at DESC " ).paginate(:page => params[:page], :per_page => 20)
            if params[:order] 
                @work_flow = WorkFlow.find_by_sql("SELECT DISTINCT work_flows.order_no, work_flows.* FROM work_flows LEFT JOIN topics ON work_flows.id = topics.order_id WHERE " + where_def + add_where + start_date + end_date).paginate(:page => params[:page], :per_page => 10)
                #@work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + where_def + add_where).paginate(:page => params[:page], :per_page => 10)
                if @work_flow.size == 1                
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE product_code = '#{@work_flow.first.product_code}'").paginate(:page => params[:page], :per_page => 20)
                end
            end
            Rails.logger.info("--------------------------------------")
            Rails.logger.info("SELECT * FROM `work_flows` WHERE " + where_def + add_where)
            Rails.logger.info("--------------------------------------")
            render "engineering.html.erb"

#test组
        elsif can? :work_d_test, :all
            start_date = ""
            if params[:start_date] != ""
                start_date = " AND topics.created_at > '#{params[:start_date]}'"
            end
            end_date = ""
            if params[:end_date] != ""
                end_date = " AND topics.created_at < '#{params[:end_date]}'"
            end
            @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE topics.feedback_receive LIKE '%engineering_test%' ORDER BY topics.updated_at DESC " ).paginate(:page => params[:page], :per_page => 20)
            if params[:order] 
                @work_flow = WorkFlow.find_by_sql("SELECT DISTINCT work_flows.order_no, work_flows.* FROM work_flows LEFT JOIN topics ON work_flows.id = topics.order_id WHERE " + where_def + add_where + start_date + end_date).paginate(:page => params[:page], :per_page => 10)
                #@work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + where_def + add_where).paginate(:page => params[:page], :per_page => 10)
                if @work_flow.size == 1                
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE product_code = '#{@work_flow.first.product_code}'").paginate(:page => params[:page], :per_page => 20)
                end
            end
            Rails.logger.info("--------------------------------------")
            Rails.logger.info("SELECT * FROM `work_flows` WHERE " + where_def + add_where)
            Rails.logger.info("--------------------------------------")
            render "engineering.html.erb"

#工厂交期
        elsif can? :work_b, :all
            if params[:empty_date].blank?    
                empty_date = "(work_flows.smd_start_date IS NOT NULL AND work_flows.smd_end_date IS NULL OR work_flows.dip_start_date IS NOT NULL AND work_flows.dip_end_date IS NULL OR work_flows.supplement_date IS NOT NULL AND work_flows.clear_date IS NULL) AND work_flows.order_state != 1 AND" 
            end 
            add_orderby = ""
            if params[:sort_date]
                if params[:sort_date] == "smd"
                    empty_date = ""
                    add_where = "AND smd_end_date IS NOT NULL AND work_flows.order_state != 1 "
                    add_orderby = " ORDER BY work_flows.smd_end_date "
                elsif params[:sort_date] == "dip"
                    empty_date = ""
                    add_where = "AND dip_end_date IS NOT NULL AND work_flows.order_state != 1 "
                    add_orderby = " ORDER BY work_flows.dip_end_date "
                elsif params[:sort_date] == "clear"
                    empty_date = ""
                    add_where = "AND clear_date IS NOT NULL AND work_flows.order_state != 1 "
                    add_orderby = " ORDER BY work_flows.clear_date " 
                elsif params[:sort_date] == "state"
                    empty_date = ""
                    add_where = "AND feed_state IS NOT NULL AND work_flows.order_state != 1 "
                    add_orderby = " ORDER BY work_flows.feed_state DESC" 
                elsif params[:sort_date] == "smd_start"
                    add_where = "AND feed_state IS NOT NULL AND work_flows.order_state != 1 "
                    add_orderby = " ORDER BY work_flows.smd_start_date DESC" 
                elsif params[:sort_date] == "dip_start"
                    add_where = "AND feed_state IS NOT NULL AND work_flows.order_state != 1 "
                    add_orderby = " ORDER BY work_flows.dip_start_date DESC" 
                end
            end
            if params[:order_s] 
                empty_date = ""  
            end
            limit = "" 
            Rails.logger.info("--------------------------------------add_orderby")
            Rails.logger.info(add_orderby)
            Rails.logger.info("--------------------------------------add_orderby")           
            @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE "  + empty_date + where_def + add_where + add_orderby ).paginate(:page => params[:page], :per_page => 10)   
            @topic = Topic.find_by_sql("SELECT *, POSITION('work_b' IN topics.mark) AS mark_chk FROM `topics` WHERE topics.feedback_receive LIKE '%production%' ORDER BY mark_chk" ).paginate(:page => params[:page], :per_page => 10)   
            render "delivery_date.html.erb"
#业务
        elsif can? :work_e, :all
            where_o = ""
            where_o_a = ""
           # where_p = ""
            if not current_user.s_name.blank?
                if current_user.s_name.size == 1
                    s_name = current_user.s_name
                    #where_o = "  POSITION('" + s_name + "' IN RIGHT(LEFT(topics.order_no,9),7)) = 6 and RIGHT(LEFT(topics.order_no,9),1) REGEXP '^[0-9]+$' AND "
                    where_o = "  ((POSITION('" + s_name + "' IN RIGHT(LEFT(topics.order_no,9),7)) = 6 and RIGHT(LEFT(topics.order_no,9),1) REGEXP '^[0-9]+$') or (POSITION('" + s_name + "' IN RIGHT(LEFT(topics.order_no,9),7)) = 7 and RIGHT(LEFT(topics.order_no,10),1) REGEXP '^[0-9]+$' and RIGHT(LEFT(topics.order_no,8),1) REGEXP '^[0-9]+$'))  AND "
                    

                    #where_p = " POSITION('" + s_name + "' IN RIGHT(LEFT(procurement_boms.p_name,9),7)) = 6 and RIGHT(LEFT(procurement_boms.p_name,9),1) REGEXP '^[0-9]+$' "
                    #where_o_a = " WHERE POSITION('" + s_name + "' IN RIGHT(LEFT(a.order_no,9),7)) = 6 and RIGHT(LEFT(a.order_no,9),1) REGEXP '^[0-9]+$' "
                    where_o_a = " WHERE ((POSITION('" + s_name + "' IN RIGHT(LEFT(a.order_no,9),7)) = 6 and RIGHT(LEFT(a.order_no,9),1) REGEXP '^[0-9]+$') or (POSITION('" + s_name + "' IN RIGHT(LEFT(a.order_no,9),7)) = 7 and RIGHT(LEFT(a.order_no,10),1) REGEXP '^[0-9]+$' and RIGHT(LEFT(a.order_no,8),1) REGEXP '^[0-9]+$')) "
                elsif current_user.s_name.size == 2
                    s_name = current_user.s_name
                    #where_o = "  POSITION('" + s_name + "' IN topics.order_no) = 8 AND "
                    #where_o = "  (POSITION('" + s_name + "' IN topics.order_no) = 8 or POSITION('" + s_name + "' IN topics.order_no) = 9) AND "
                    where_o = "  ((LOCATE('" + s_name + "', topics.order_no,3) = 8 AND RIGHT(LEFT(topics.order_no,10),1) REGEXP '^[0-9]+$') OR (LOCATE('" + s_name + "', topics.order_no,3) = 9 AND RIGHT(LEFT(topics.order_no,8),1) REGEXP '^[0-9]+$')) AND "
                    #where_p = "  POSITION('" + s_name + "' IN procurement_boms.p_name) = 8 "
                    #where_o_a = " WHERE POSITION('" + s_name + "' IN a.order_no) = 8 "
                    #where_o_a = " WHERE (POSITION('" + s_name + "' IN topics.order_no) = 8 or POSITION('" + s_name + "' IN topics.order_no) = 9) "
                    where_o_a = " WHERE (LOCATE('" + s_name + "', a.order_no,3) = 8 AND RIGHT(LEFT(a.order_no,10),1) REGEXP '^[0-9]+$') OR (LOCATE('" + s_name + "', a.order_no,3) = 9 AND RIGHT(LEFT(a.order_no,8),1) REGEXP '^[0-9]+$') "
                elsif current_user.s_name.size > 2
                    where_o_a = " WHERE "
                    where_o = "("
                    #where_p = "("
                    current_user.s_name.split(",").each_with_index do |item,index|
                        s_name = item
                        if current_user.s_name.split(",").size > (index+1)
                            #where_o += "  LOCATE('" + s_name + "', topics.order_no,3) = 8 OR LOCATE('" + s_name + "', topics.order_no,3) = 9 OR"                       
                            where_o += "  (LOCATE('" + s_name + "', topics.order_no,3) = 8 AND RIGHT(LEFT(topics.order_no,10),1) REGEXP '^[0-9]+$') OR (LOCATE('" + s_name + "', topics.order_no,3) = 9 AND RIGHT(LEFT(topics.order_no,8),1) REGEXP '^[0-9]+$') OR "
                            #where_o_a += " LOCATE('" + s_name + "', a.order_no,3) = 8 OR LOCATE('" + s_name + "', a.order_no,3) = 9 OR "
                            where_o_a += "  (LOCATE('" + s_name + "', a.order_no,3) = 8 AND RIGHT(LEFT(a.order_no,10),1) REGEXP '^[0-9]+$') OR (LOCATE('" + s_name + "', a.order_no,3) = 9 AND RIGHT(LEFT(a.order_no,8),1) REGEXP '^[0-9]+$') OR "
                        else
                            #where_o += "  LOCATE('" + s_name + "', topics.order_no,3) = 8 OR LOCATE('" + s_name + "', topics.order_no,3) = 9) AND"
                            where_o += "  (LOCATE('" + s_name + "', topics.order_no,3) = 8 AND RIGHT(LEFT(topics.order_no,10),1) REGEXP '^[0-9]+$') OR (LOCATE('" + s_name + "', topics.order_no,3) = 9 AND RIGHT(LEFT(topics.order_no,8),1) REGEXP '^[0-9]+$')) AND "
                            #where_o_a += " LOCATE('" + s_name + "', a.order_no,3) = 8 OR LOCATE('" + s_name + "', a.order_no,3) = 9"
                            where_o_a += "  (LOCATE('" + s_name + "', a.order_no,3) = 8 AND RIGHT(LEFT(a.order_no,10),1) REGEXP '^[0-9]+$') OR (LOCATE('" + s_name + "', a.order_no,3) = 9 AND RIGHT(LEFT(a.order_no,8),1) REGEXP '^[0-9]+$')  "
                        end
                    end
                end
            end
            @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE #{where_o}  topics.topic_state = 'open' ORDER BY topics.mark " ).paginate(:page => params[:page], :per_page => 20)
            if params[:order]
                #if params[:order].size == 1 or params[:order].size == 2
                    #@work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + empty_date + where_def + add_where + "ORDER BY updated_at DESC " ).paginate(:page => params[:page], :per_page => 10)
                #else
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM (SELECT * FROM `work_flows` WHERE " + empty_date + where_def + add_where + ") AS a #{where_o_a} ORDER BY a.updated_at DESC " ).paginate(:page => params[:page], :per_page => 20)
                #end
                if @work_flow.size == 1 and params[:order].size > 2               
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE product_code = '#{@work_flow.first.product_code}'").paginate(:page => params[:page], :per_page => 20)
                end
            else
                if empty_date != ""                    
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM (SELECT * FROM `work_flows` WHERE "  + empty_date + where_def + add_where + ") AS a #{where_o_a} ORDER BY a.updated_at DESC " ).paginate(:page => params[:page], :per_page => 20)
                end               
            end
            #@quate = ProcurementBom.find_by_sql("SELECT * FROM `procurement_boms` WHERE	#{where_p}")
            render "sell.html.erb"
#跟单
        elsif can? :work_f, :all
            add_orderby = " ORDER BY work_flows.updated_at DESC " 
            #add_orderby = " " 
            if params[:sort_date]
                empty_date = ""
                if params[:sort_date] == "smd"
                    add_where = "AND smd_end_date IS NOT NULL AND work_flows.order_state != 1 "
                    add_orderby = " ORDER BY work_flows.smd_end_date "
                elsif params[:sort_date] == "dip"
                    add_where = "AND dip_end_date IS NOT NULL AND work_flows.order_state != 1 "
                    add_orderby = " ORDER BY work_flows.dip_end_date "
                elsif params[:sort_date] == "clear"
                    add_where = "AND clear_date IS NOT NULL AND work_flows.order_state != 1 "
                    add_orderby = " ORDER BY work_flows.clear_date " 
                end
            end
            if params[:close]
                @issue_lable = "已经关闭的问题"
                @topic = Topic.find_by_sql("SELECT topics.*,feedbacks.topic_id,feedbacks.feedback_level, POSITION('work_f' IN topics.mark) AS mark_chk FROM topics INNER JOIN feedbacks ON topics.id = feedbacks.topic_id WHERE feedbacks.feedback_level = 1 ORDER BY mark_chk " ).paginate(:page => params[:page], :per_page => 20)
            else
                @issue_lable = "未关闭的问题"
                @topic = Topic.find_by_sql("SELECT *, POSITION('work_f' IN topics.mark) AS mark_chk FROM `topics` WHERE topics.feedback_receive LIKE '%merchandiser%' ORDER BY mark_chk " ).paginate(:page => params[:page], :per_page => 20)
            end
            if params[:order] or params[:sort_date]
                @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + where_def + add_where + add_orderby).paginate(:page => params[:page], :per_page => 50)
                if @work_flow.size == 1                
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE product_code = '#{@work_flow.first.product_code}'").paginate(:page => params[:page], :per_page => 50)
                end
            end
            
            render "merchandiser.html.erb"
#采购
        elsif can? :work_g, :all
            start_date = ""
            start_date_a = ""
            if params[:start_date] != ""
                start_date = " AND topics.created_at > '#{params[:start_date]}'"
                start_date_a = " AND A.created_at > '#{params[:start_date]}'"
            end
            end_date = ""
            end_date_a = ""
            if params[:end_date] != ""
                end_date = " AND topics.created_at < '#{params[:end_date]}'"
                end_date_a = " AND A.created_at < '#{params[:end_date]}'"
            end
            @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE topics.feedback_receive LIKE '%procurement%' ORDER BY topics.updated_at DESC " ).paginate(:page => params[:page], :per_page => 20)
            if params[:order] 
                if params[:order_s][:order_s].to_i == 5 
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM (SELECT DISTINCT feedbacks.order_no, feedbacks.feedback_type, feedbacks.created_at, feedbacks.updated_at FROM feedbacks WHERE feedbacks.feedback_type = 'procurement' GROUP BY feedbacks.order_no) A JOIN work_flows ON A.order_no = work_flows.order_no WHERE " + where_def + add_where + start_date_a + end_date_a + " ORDER BY	A.updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    @work_flow = WorkFlow.find_by_sql("SELECT DISTINCT work_flows.order_no, work_flows.* FROM work_flows RIGHT JOIN topics ON work_flows.id = topics.order_id WHERE " + where_def + add_where + start_date + end_date).paginate(:page => params[:page], :per_page => 20)
                    #@work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + where_def + add_where).paginate(:page => params[:page], :per_page => 10)
                end
                if @work_flow.size == 1                
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE product_code = '#{@work_flow.first.product_code}'").paginate(:page => params[:page], :per_page => 20)
                end
            end
            
            render "procurement.html.erb"
        else
            add_orderby = " ORDER BY work_flows.updated_at DESC " 
            #add_orderby = " " 
            if params[:sort_date]
                empty_date = ""
                if params[:sort_date] == "smd"
                    add_where = "AND smd_end_date IS NOT NULL AND work_flows.order_state != 1 "
                    add_orderby = " ORDER BY work_flows.smd_end_date "
                elsif params[:sort_date] == "dip"
                    add_where = "AND dip_end_date IS NOT NULL AND work_flows.order_state != 1 "
                    add_orderby = " ORDER BY work_flows.dip_end_date "
                elsif params[:sort_date] == "clear"
                    add_where = "AND clear_date IS NOT NULL AND work_flows.order_state != 1 "
                    add_orderby = " ORDER BY work_flows.clear_date " 
                end
            end
            @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + empty_date + where_def + add_where + add_orderby ).paginate(:page => params[:page], :per_page => 20)       
            #if @work_flow.size == 1                
                #@work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE product_code = '#{@work_flow.first.product_code}'").paginate(:page => params[:page], :per_page => 10)
            #end
            #render "index.html.erb"
            #redirect_to action: :index, data: { no_turbolink: true }
        end
        if can? :work_a, :all
            @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE topics.feedback_receive LIKE '%pmc%' ORDER BY topics.updated_at DESC " ).paginate(:page => params[:page], :per_page => 20)
        else
            @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE topics.feedback_receive LIKE '%production%' ORDER BY topics.updated_at DESC " ).paginate(:page => params[:page], :per_page => 20)
        end
    end

   
    def show
        #@work_flow = WorkFlow.find(params[:id])
        @topic = Topic.find(params[:id])
        @feedback_all = Feedback.where(topic_id: params[:id]).order("created_at DESC")
        @receive = ""
        @topic.feedback_receive.split(',').each do |rece|
            @receive += " " + t(:"#{rece}")
        end
        if can? :work_c, :all or can? :work_a, :all
            render "production_feedback.html.erb"
        elsif can? :work_d, :all or can? :work_d_bom, :all or can? :work_d_pcb, :all or can? :work_d_ziliao, :all or can? :work_d_test, :all
            render "engineering_feedback.html.erb"
        elsif can? :work_e, :all
            if current_user.s_name.blank?
                if @topic.mark.blank?
                    @topic.mark = "lwork_" + "all" + "l"
                else
                    @topic.mark += "lwork_" + "all" + "l"
                end
            else
                if @topic.mark.blank?
                    @topic.mark = "lwork_" + current_user.s_name + "l"
                else
                    @topic.mark += "lwork_" + current_user.s_name + "l"
                end
            end
            @topic.save
            render "sell_feedback.html.erb"
        elsif can? :work_f, :all
            if current_user.email == "wenbo@mokotechnology.com"
                if @topic.mark.blank? 
                    @topic.mark = "lwork_fl"
                else
                    @topic.mark += "lwork_fl"
                end
                @topic.save
            end
            render "merchandiser_feedback.html.erb"
        elsif can? :work_g, :all
            render "procurement_feedback.html.erb"
        elsif can? :work_b, :all
            if @topic.mark.blank?
                @topic.mark = "lwork_bl"
            else
                @topic.mark += "lwork_bl"
            end
            @topic.save
            #render "delivery_date_feedback.html.erb"
            render "production_feedback.html.erb"
        end
    end

    def up_warehouse
        if params[:warehouse_info]
            all_order = params[:warehouse_info].split("\r\n");
            all_order.each do |item|
                item_order = item.split(" ")
                if item_order.size == 2
                    checkorder = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE  work_flows.order_no = '" + item_order[0] + "'").first
                    if not checkorder.blank?
                        checkorder.warehouse_quantity = checkorder.warehouse_quantity.to_i + item_order[1].to_i 
                        checkorder.save
                        work_history = Work.new
                        work_history.order_date = checkorder.order_date
                        work_history.order_no = checkorder.order_no
                        work_history.order_quantity = checkorder.order_quantity
                        work_history.warehouse_quantity = checkorder.warehouse_quantity
                        work_history.user_name = current_user.email
                        work_history.save
                        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                        Rails.logger.info(item_order.inspect)
                        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")

                        user_open_id = User.find_by(s_name_self: (checkorder.order_no.split("-")[0].scan(/\D/).join("").chop.delete("mk").delete("MK")))
                        if not user_open_id.blank?
                            open_id = user_open_id.open_id
                            oauth = Oauth.find(1)
                            company_id = oauth.company_id
                            company_token = oauth.company_token
                            url = 'https://openapi.b.qq.com/api/tips/send'
                            if not open_id.blank? 
                                url += '?company_id='+company_id
                                url += '&company_token='+company_token
                                url += '&app_id=200710667'
                                url += '&client_ip=120.25.151.208'
                                url += '&oauth_version=2'
                                url += '&to_all=0'  
                                url += '&receivers='+open_id
                                url += '&window_title=Fastbom-PCB AND PCBA'
                                url += '&tips_title='+URI.encode(User.find_by(s_name_self: (checkorder.order_no.split("-")[0].scan(/\D/).join("").chop.delete("mk").delete("MK"))).full_name+'宝宝')
                                url += '&tips_content='+URI.encode('你的订单入库数量有更新，点击查看。')
                            #url += '&tips_url=erp.fastbom.com/feedback?id='+self.topic_id.to_s 
                                url += '&tips_url=erp.fastbom.com/work_flow?utf8=%E2%9C%93%26order_s%5Border_s%5D=1%26order=' + checkorder.order_no + '%26commit=%E6%90%9C%E7%B4%A2'
                                resp = Net::HTTP.get_response(URI(url))
                            end                    
                        end
                    end
                else
                    redirect_to work_flow_path, :flash => {:error => item+"--------入库数量更新失败，请检查上传数据格式！"}
                    return false
                end
            end
        end
        redirect_to work_flow_path(), notice: "订单数据更新成功！"
    end
  
    def up_enddate
        if params[:smd_end_date]
            all_order = params[:smd_end_date].split("\r\n");
            all_order.each do |item|
                item_order = item.split(" ")
                if item_order.size == 2
                    checkorder = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE  work_flows.order_no = '" + item_order[0] + "'").first
                    if not checkorder.blank?
                        checkorder.smd_end_date = item_order[1] 
                        checkorder.save
                        work_history = Work.new
                        work_history.order_date = checkorder.order_date
                        work_history.order_no = checkorder.order_no
                        work_history.order_quantity = checkorder.order_quantity
                        work_history.smd_end_date = checkorder.smd_end_date
                        work_history.user_name = current_user.email
                        work_history.save
                        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                        Rails.logger.info(item_order.inspect)
                        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                    end
                else
                    redirect_to work_flow_path, :flash => {:error => item+"--------入库数量更新失败，请检查上传数据格式！"}
                    return false
                end
            end
        elsif params[:dip_end_date]
            all_order = params[:dip_end_date].split("\r\n");
            all_order.each do |item|
                item_order = item.split(" ")
                if item_order.size == 2
                    checkorder = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE  work_flows.order_no = '" + item_order[0] + "'").first
                    if not checkorder.blank?
                        checkorder.dip_end_date = item_order[1] 
                        checkorder.save
                        work_history = Work.new
                        work_history.order_date = checkorder.order_date
                        work_history.order_no = checkorder.order_no
                        work_history.order_quantity = checkorder.order_quantity
                        work_history.dip_end_date = checkorder.dip_end_date
                        work_history.user_name = current_user.email
                        work_history.save
                        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                        Rails.logger.info(item_order.inspect)
                        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                    end
                else
                    redirect_to work_flow_path, :flash => {:error => item+"--------入库数量更新失败，请检查上传数据格式！"}
                    return false
                end
            end
        elsif params[:clear_date]
            all_order = params[:clear_date].split("\r\n");
            all_order.each do |item|
                item_order = item.split(" ")
                if item_order.size == 2
                    checkorder = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE  work_flows.order_no = '" + item_order[0] + "'").first
                    if not checkorder.blank?
                        checkorder.clear_date = item_order[1] 
                        checkorder.save
                        work_history = Work.new
                        work_history.order_date = checkorder.order_date
                        work_history.order_no = checkorder.order_no
                        work_history.order_quantity = checkorder.order_quantity
                        work_history.clear_date = checkorder.clear_date
                        work_history.user_name = current_user.email
                        work_history.save
                        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                        Rails.logger.info(item_order.inspect)
                        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                    end
                else
                    redirect_to work_flow_path, :flash => {:error => item+"--------入库数量更新失败，请检查上传数据格式！"}
                    return false
                end
            end
        elsif params[:remarks]
            all_order = params[:remarks].split("\r\n");
            all_order.each do |item|
                item_order = item.split(" ")
                if item_order.size == 2
                    checkorder = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE  work_flows.order_no = '" + item_order[0] + "'").first
                    if not checkorder.blank?
                        checkorder.remark = item_order[1] 
                        checkorder.save
                        work_history = Work.new
                        work_history.order_date = checkorder.order_date
                        work_history.order_no = checkorder.order_no
                        work_history.order_quantity = checkorder.order_quantity
                        work_history.remark = checkorder.remark
                        work_history.user_name = current_user.email
                        work_history.save
                        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                        Rails.logger.info(item_order.inspect)
                        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                    end
                else
                    redirect_to work_flow_path, :flash => {:error => item+"--------备注更新失败，请检查上传数据格式！"}
                    return false
                end
            end
        end
        
        redirect_to work_flow_path(), notice: "订单数据更新成功！"
    end

    def add_feed
        if params[:add_feed]
            all_order = params[:add_feed].split("\r\n");
            all_order.each do |item|
                item_order = item.split(" ")
                if item_order.size == 2
                    checkorder = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE  work_flows.order_no = '" + item_order[0] + "'").first
                    if not checkorder.blank?
                        checkorder.feed_state = item_order[1] 
                        checkorder.save
                        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                        Rails.logger.info(item_order.inspect)
                        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                    end
                else
                    redirect_to work_flow_path, :flash => {:error => item+"--------补料信息更新失败，请检查上传数据格式！"}
                    return false
                end
            end
        end
        redirect_to work_flow_path(), notice: "订单数据更新成功！"
    end

    def order_state
        if params[:order_state] or params[:order_y] or params[:order_r]
            if params[:order_state]
                all_order = params[:order_state].strip.split("\r\n");
                all_order.each do |item|
                    checkorder = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE  work_flows.order_no = '" + item + "'").first
                    if not checkorder.blank?
                        checkorder.order_state = 1
                        checkorder.save
                    else
                        redirect_to work_flow_path, :flash => {:error => item+"--------结单失败，请检查订单号！"}
                        return false
                    end
                end
            elsif params[:order_y]
                all_order = params[:order_y].strip.split("\r\n");
            elsif params[:order_r]
                all_order = params[:order_r].strip.split("\r\n");
                all_order.each do |item|
                    item_order = item.split(" ")
                    if item_order.size == 2
                        checkorder = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE  work_flows.order_no = '" + item_order[0] + "'").first
                        if not checkorder.blank?
                            checkorder.order_state = 3
                            checkorder.remark = item_order[1] 
                            checkorder.save
                            work_history = Work.new
                            work_history.order_date = checkorder.order_date
                            work_history.order_no = checkorder.order_no
                            work_history.order_quantity = checkorder.order_quantity
                            work_history.remark = checkorder.remark
                            work_history.user_name = current_user.email
                            work_history.save
                        end
                    else
                        redirect_to work_flow_path, :flash => {:error => item+"--------备注更新失败，请检查上传数据格式！"}
                        return false
                    end
                end
            end
        end
        redirect_to work_flow_path(), notice: "订单数据更新成功！"
    end

    def up_work
        if params[:order_info]
            all_order = params[:order_info].split("\r\n");
            all_order.each do |item|
                item_order = item.split(" ")
                if item_order.size == 5
                    checkorder = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE  work_flows.order_no = '" + item_order[1] + "'")
                    if checkorder.blank?
                        work_up = WorkFlow.new
                        work_up.order_date = item_order[0]
                        work_up.order_no = item_order[1]
                        work_up.order_quantity = item_order[2] 
                        work_up.salesman_end_date = item_order[3]
                        work_up.product_code = item_order[4]
                        #work_up.warehouse_quantity = item_order[5]
                        work_up.save
                        #Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                        #Rails.logger.info(item_order.inspect)
                        #Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                    end
                else
                    redirect_to work_flow_path, :flash => {:error => item+"--------订单数据更新失败，请检查上传数据格式！"}
                    return false
                end
            end
        end
        redirect_to work_flow_path()
    end
    
    def edit_work_item
        if not params[:work_id].blank?
            get_work = WorkFlow.find(params[:work_id])
            if not get_work.blank?
                get_work.remark = params[:work_remark]
                get_work.last_at = params[:last_at]
                get_work.save
            end
        end
        redirect_to :back
    end

    def edit_work_color
        if params[:work_id]
            work_up = WorkFlow.find(params[:work_id])
            if not work_up.blank?
                if work_up.order_state > 0
                    work_up.order_state = 0
                    work_up.save
                elsif work_up.order_state.blank? or work_up.order_state == 0
                    work_up.order_state = 3
                    work_up.save
                end
            end
        end
        redirect_to :back
    end

    def edit_work
        @open = "collapse"
        if params[:work_id]
            work_up = WorkFlow.find(params[:work_id])
            
            if params[:commit] =="A"
                work_up.order_state = 0
            elsif params[:commit] =="B"
                work_up.order_state = 2
            elsif params[:commit] =="C"
                work_up.order_state = 3
            elsif params[:commit] =="D"
                work_up.order_state = 4
            else
                if not params[:order_date].blank? 
                    work_up.order_date = params[:order_date].strip
                end
                if not params[:order_no].blank?
                    work_up.order_no = params[:order_no].strip
                end
                if not params[:order_quantity].blank?
                    work_up.order_quantity = params[:order_quantity].strip
                end
                if not params[:salesman_end_date].blank?
                    work_up.salesman_end_date = params[:salesman_end_date].strip
                end
                if not params[:product_code].blank?
                    work_up.product_code = params[:product_code].strip
                end
                if not params[:warehouse_quantity].blank?
                    work_up.warehouse_quantity = params[:warehouse_quantity].strip
                end
                if  params[:smd]
                    work_up.smd = params[:smd].strip
                end
                if  params[:dip]
                    work_up.dip = params[:dip].strip
                end
                if not params[:smd_start_date].blank?
                #if params[:smd_start_date] == ""
                    #work_up.smd_start_date = nil
                #else 
                    work_up.smd_start_date = params[:smd_start_date].strip
                #end
                end
                if not params[:smd_end_date].blank?
                    work_up.smd_end_date = params[:smd_end_date].strip
                end
                if params[:smd_state]
                    work_up.smd_state = params[:smd_state].strip
                end
                if not params[:dip_start_date].blank?
                    work_up.dip_start_date = params[:dip_start_date].strip
                end
                if not params[:dip_end_date].blank?
                    work_up.dip_end_date = params[:dip_end_date].strip
                end
                if not params[:update_date].blank?
                    work_up.update_date = params[:update_date].strip
                end
                if not params[:production_feedback].blank?
                    work_up.production_feedback = params[:production_feedback].strip
                    work_up.feedback_state = "3"
                end
                if not params[:engineering_feedback].blank?
                    work_up.test_feedback = params[:engineering_feedback].strip
                    work_up.feedback_state = "2"
                end
                if not params[:sell_feedback].blank?
                    work_up.feedback_state = "1"
                end
                if params[:supplement_date]
                    #if params[:supplement_date].strip == ""
                        #work_up.supplement_date = nil
                    #else
                        work_up.supplement_date = params[:supplement_date].strip
                    #end
                end    
                if params[:feed_state]
                    work_up.feed_state = params[:feed_state].strip
                end
                if not params[:clear_date].blank?
                    work_up.clear_date = params[:clear_date].strip
                end
                if not params[:salesman_state].blank?
                    work_up.salesman_state = params[:salesman_state].strip
                end
                if params[:remark]
                    work_up.remark = params[:remark].strip
                end
            end
            
            if work_up.save
                if params[:page]
                    use_page = params[:page].to_s
                else
                    use_page = ""
                end
                if params[:topic_up] 
                    topic_up = Topic.new                                      
                    topic_up.order_no = work_up.order_no                      #帖子对应的的order
                    topic_up.product_code = work_up.product_code              #帖子对应的物料
                    topic_up.order_id = params[:topic_up]                  #帖子对应的order id
                    if not params[:production_feedback].blank?
                        topic_up.feedback_title = params[:feedback_title]       #标题
                        if ( params[:production_feedback] =~ /width="(.\d*")/ )  
                            params[:production_feedback].gsub!(/width="(.\d*")/, "")
                        end
                        if ( params[:production_feedback] =~ /height="(.\d*")/ )  
                            params[:production_feedback].gsub!(/height="(.\d*")/, "")
                        end
                        params[:production_feedback].gsub!('<img ','<img width="200" height="100" ')
                        topic_up.feedback = params[:production_feedback]      #话题内容
                        topic_up.feedback_type = "production"                 #发帖人部门
                        if not params[:receive_feedback].blank?
                            topic_up.feedback_receive = params[:receive_feedback].join(",") + ",merchandiser"    #收贴的部门
                        else
                            topic_up.feedback_receive =  "merchandiser"    #收贴的部门
                        end
                    elsif not params[:engineering_feedback].blank?
                        topic_up.feedback_title = params[:feedback_title]       #标题
                        if ( params[:engineering_feedback] =~ /width="(.\d*")/ )  
                            params[:engineering_feedback].gsub!(/width="(.\d*")/, "")
                        end
                        if ( params[:engineering_feedback] =~ /height="(.\d*")/ )  
                            params[:engineering_feedback].gsub!(/height="(.\d*")/, "")
                        end
                        params[:engineering_feedback].gsub!('<img ','<img width="200" height="100" ')
                        topic_up.feedback = params[:engineering_feedback]      #话题内容
                        topic_up.feedback_type = "engineering"                 #发帖人部门
                        topic_up.feedback_receive = params[:receive_feedback].join(",") + ",merchandiser"    #收贴的部门
                    elsif not params[:sell_topic].blank?
                        topic_up.feedback_title = params[:feedback_title]      #标题
                        if ( params[:sell_topic] =~ /width="(.\d*")/ )  
                            params[:sell_topic].gsub!(/width="(.\d*")/, "")
                        end
                        if ( params[:sell_topic] =~ /height="(.\d*")/ )  
                            params[:sell_topic].gsub!(/height="(.\d*")/, "")
                        end
                        params[:sell_topic].gsub!('<img ','<img width="200" height="100" ')
                        topic_up.feedback = params[:sell_topic]             #话题内容
                        topic_up.feedback_type = "sell"                        #发帖人部门
                        topic_up.feedback_receive = "merchandiser"             #收贴的部门
                        #topic_up.feedback_receive_user = "sell"                #收贴的人
                        #topic_up.feedback_level = 1                            #暂时没用
                        #topic_up.feedback_id = 1                               #暂时没用
                    elsif not params[:merchandiser_feedback].blank?
                        topic_up.feedback_title = params[:feedback_title]       #标题                        
                        if ( params[:merchandiser_feedback] =~ /width="(.\d*")/ )  
                            params[:merchandiser_feedback].gsub!(/width="(.\d*")/, "")
                        end
                        if ( params[:merchandiser_feedback] =~ /height="(.\d*")/ )  
                            params[:merchandiser_feedback].gsub!(/height="(.\d*")/, "")
                        end
                        params[:merchandiser_feedback].gsub!('<img ','<img width="200" height="100" ')
                        topic_up.feedback = params[:merchandiser_feedback]      #话题内容
           
                        topic_up.feedback_type = "merchandiser"                 #发帖人部门
                        topic_up.feedback_receive = params[:receive_feedback].join(",") + ",merchandiser"    #收贴的部门
                        #topic_up.feedback_receive_user = "sell"                #收贴的人
                        #topic_up.feedback_level = 1                            #暂时没用
                        #topic_up.feedback_id = 1
                    elsif not params[:procurement_feedback].blank?
                        topic_up.feedback_title = params[:feedback_title]       #标题
                        if ( params[:procurement_feedback] =~ /width="(.\d*")/ )  
                            params[:procurement_feedback].gsub!(/width="(.\d*")/, "")
                        end
                        if ( params[:procurement_feedback] =~ /height="(.\d*")/ )  
                            params[:procurement_feedback].gsub!(/height="(.\d*")/, "")
                        end
                        params[:procurement_feedback].gsub!('<img ','<img width="200" height="100" ')
                        topic_up.feedback = params[:procurement_feedback]      #话题内容
                        topic_up.feedback_type = "procurement"                 #发帖人部门
                        topic_up.feedback_receive = params[:receive_feedback].join(",") + ",merchandiser"    #收贴的部门
                        #topic_up.feedback_receive_user = "sell"                #收贴的人
                        #topic_up.feedback_level = 1                            #暂时没用
                        #topic_up.feedback_id = 1
                    end
                    topic_up.user_name = current_user.email                     #发帖的人
                    topic_up.save
                    if topic_up.feedback_receive =~ /production/
                        all_open_id = User.find_by_sql("SELECT users_roles.role_id,users_roles.user_id,users.id,users.email,users.s_name,users.open_id,users.full_name FROM users INNER JOIN users_roles ON users_roles.user_id = users.id AND users_roles.role_id > 3 AND users_roles.role_id < 7")
                        open_id = ""
                        all_open_id.each do |item|
                            if not item.open_id.blank?
                                open_id += item.open_id + ","
                            end
                        end
                        Rails.logger.info("oauth-------------------------")
                        Rails.logger.info(open_id.inspect)   
                        Rails.logger.info("oauth----------------------------------")
                        oauth = Oauth.find(1)
                        company_id = oauth.company_id
                        company_token = oauth.company_token
                        url = 'https://openapi.b.qq.com/api/tips/send'
                        if not open_id.blank? 
                            url += '?company_id='+company_id
                            url += '&company_token='+company_token
                            url += '&app_id=200710667'
                            url += '&client_ip=120.25.151.208'
                            url += '&oauth_version=2'
                            url += '&to_all=0'  
                            url += '&receivers='+open_id.chop
                            url += '&window_title=Fastbom-PCB AND PCBA'
                            url += '&tips_title='+URI.encode('生产部的宝宝们')
                            url += '&tips_content='+URI.encode('有新的回复，点击查看。')
                            url += '&tips_url=erp.fastbom.com/feedback?id='+topic_up.id.to_s 
                            resp = Net::HTTP.get_response(URI(url))
                        end 
                    end
                    if topic_up.feedback_receive =~ /engineering/
                        all_open_id = User.find_by_sql("SELECT users_roles.role_id,users_roles.user_id,users.id,users.email,users.s_name,users.open_id,users.full_name FROM users INNER JOIN users_roles ON users_roles.user_id = users.id AND (users_roles.role_id = '7' OR users_roles.role_id = '22')")
                        open_id = ""
                        all_open_id.each do |item|
                            if not item.open_id.blank?
                                open_id += item.open_id + ","
                            end
                        end
                        oauth = Oauth.find(1)
                        company_id = oauth.company_id
                        company_token = oauth.company_token
                        url = 'https://openapi.b.qq.com/api/tips/send'
                        if not open_id.blank? 
                            url += '?company_id='+company_id
                            url += '&company_token='+company_token
                            url += '&app_id=200710667'
                            url += '&client_ip=120.25.151.208'
                            url += '&oauth_version=2'
                            url += '&to_all=0'  
                            url += '&receivers='+open_id.chop
                            url += '&window_title=Fastbom-PCB AND PCBA'
                            url += '&tips_title='+URI.encode('工程部的宝宝们')
                            url += '&tips_content='+URI.encode('有新的回复，点击查看。')
                            url += '&tips_url=erp.fastbom.com/feedback?id='+topic_up.id.to_s 
                            resp = Net::HTTP.get_response(URI(url))
                        end 
                    end
                    if topic_up.feedback_receive =~ /merchandiser/
                        all_open_id = User.find_by_sql("SELECT users_roles.role_id,users_roles.user_id,users.id,users.email,users.s_name,users.open_id,users.full_name FROM users INNER JOIN users_roles ON users_roles.user_id = users.id AND users_roles.role_id = '9'")
                        open_id = ""
                        all_open_id.each do |item|
                            if not item.open_id.blank?
                                open_id += item.open_id + ","
                            end
                        end
                        oauth = Oauth.find(1)
                        company_id = oauth.company_id
                        company_token = oauth.company_token
                        url = 'https://openapi.b.qq.com/api/tips/send'
                        if not open_id.blank? 
                            url += '?company_id='+company_id
                            url += '&company_token='+company_token
                            url += '&app_id=200710667'
                            url += '&client_ip=120.25.151.208'
                            url += '&oauth_version=2'
                            url += '&to_all=0'  
                            url += '&receivers='+open_id.chop
                            url += '&window_title=Fastbom-PCB AND PCBA'
                            url += '&tips_title='+URI.encode('跟单部的宝宝们')
                            url += '&tips_content='+URI.encode('有新的回复，点击查看。')
                            url += '&tips_url=erp.fastbom.com/feedback?id='+topic_up.id.to_s 
                            resp = Net::HTTP.get_response(URI(url))
                        end 
                    end
                    if topic_up.feedback_receive =~ /procurement/
                        all_open_id = User.find_by_sql("SELECT users_roles.role_id,users_roles.user_id,users.id,users.email,users.s_name,users.open_id,users.full_name FROM users INNER JOIN users_roles ON users_roles.user_id = users.id AND (users_roles.role_id = '10' OR users_roles.role_id = '16' OR users_roles.role_id = '17' OR users_roles.role_id = '18')")
                        open_id = ""
                        all_open_id.each do |item|
                            if not item.open_id.blank?
                                open_id += item.open_id + ","
                            end
                        end
                        oauth = Oauth.find(1)
                        company_id = oauth.company_id
                        company_token = oauth.company_token
                        url = 'https://openapi.b.qq.com/api/tips/send'
                        if not open_id.blank? 
                            url += '?company_id='+company_id
                            url += '&company_token='+company_token
                            url += '&app_id=200710667'
                            url += '&client_ip=120.25.151.208'
                            url += '&oauth_version=2'
                            url += '&to_all=0'  
                            url += '&receivers='+open_id.chop
                            url += '&window_title=Fastbom-PCB AND PCBA'
                            url += '&tips_title='+URI.encode('采购部的宝宝们')
                            url += '&tips_content='+URI.encode('有新的回复，点击查看。')
                            url += '&tips_url=erp.fastbom.com/feedback?id='+topic_up.id.to_s 
                            resp = Net::HTTP.get_response(URI(url))
                        end 
                    end

                elsif params[:feedback_up] 
                    topic_up = Topic.find(params[:feedback_up])
                    Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                    Rails.logger.info(params[:feedback_up].inspect)
                    Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                    if can? :work_e, :all                                       #业务回帖                        
                        receive_new = topic_up.feedback_receive.split(",") <<  "merchandiser" 
                        receive_new.delete("sell") 
                        topic_up.feedback_receive = receive_new.join(",")
                        
                    else                                                        #其他部门回帖                        
                        if params[:send_up]
                            topic_up = Topic.find(params[:feedback_up])
                            if params[:send_up] == "mark"
                                topic_up.mark = params[:send_up]
                            else
                                receive_new = topic_up.feedback_receive.split(",")|params[:send_up]  
                                if can? :work_c, :all
                                    receive_new.delete("production")    
                                #elsif can? :work_d, :all 
                                    #receive_new.delete("engineering")
                                elsif can? :work_a, :all 
                                    receive_new.delete("pmc")
                                elsif can? :work_d_ziliao, :all 
                                    receive_new.delete("engineering_ziliao")
                                elsif can? :work_d_bom, :all 
                                    receive_new.delete("engineering_bom")
                                elsif can? :work_d_pcb, :all 
                                    receive_new.delete("engineering_pcb")
                                elsif can? :work_d_test, :all 
                                    receive_new.delete("engineering_test")

                                #elsif can? :work_f, :all 
                                    #receive_new.delete("merchandiser")
                                elsif can? :work_g, :all 
                                    receive_new.delete("procurement")
                                end

                                topic_up.feedback_receive = receive_new.join(",")
                                
                                topic_up.mark = ""
                            end
                        end                                                         
                        if params[:feedback_receive] 
                            if params[:feedback_receive] == "sell"                       
                                topic_up.feedback_receive_user = topic_up.user_name   #收贴的人
                            end
                            topic_up.feedback_receive = params[:send_up]    #收贴的部门
                        end
                        if params[:feedback_receive_user]
                            topic_up.feedback_receive_user = params[:feedback_receive_user]   #收贴的人
                        end
                    end
                    feedback_level = 0
                    if not params[:topic_state].blank?
                        topic_up.topic_state = params[:topic_state]             #是否关闭问题
                        if params[:topic_state] == "close"
                            feedback_level = 1
                            topic_up.feedback_receive = ""
                        end
                    end
                    topic_up.mark = ""
                    topic_up.save
                    if topic_up.feedback_receive =~ /pmc/
                        all_open_id = User.find_by_sql("SELECT users_roles.role_id,users_roles.user_id,users.id,users.email,users.s_name,users.open_id,users.full_name FROM users INNER JOIN users_roles ON users_roles.user_id = users.id AND users_roles.role_id > 3 AND users_roles.role_id < 7")
                        open_id = ""
                        all_open_id.each do |item|
                            if not item.open_id.blank?
                                open_id += item.open_id + ","
                            end
                        end
                        oauth = Oauth.find(1)
                        company_id = oauth.company_id
                        company_token = oauth.company_token
                        url = 'https://openapi.b.qq.com/api/tips/send'
                        if not open_id.blank? 
                            url += '?company_id='+company_id
                            url += '&company_token='+company_token
                            url += '&app_id=200710667'
                            url += '&client_ip=120.25.151.208'
                            url += '&oauth_version=2'
                            url += '&to_all=0'  
                            url += '&receivers='+open_id.chop
                            url += '&window_title=Fastbom-PCB AND PCBA'
                            url += '&tips_title='+URI.encode('PMC的宝宝们')
                            url += '&tips_content='+URI.encode('有新的回复，点击查看。')
                            url += '&tips_url=erp.fastbom.com/feedback?id='+topic_up.id.to_s 
                            resp = Net::HTTP.get_response(URI(url))
                        end 
                    end
                    if topic_up.feedback_receive =~ /production/
                        all_open_id = User.find_by_sql("SELECT users_roles.role_id,users_roles.user_id,users.id,users.email,users.s_name,users.open_id,users.full_name FROM users INNER JOIN users_roles ON users_roles.user_id = users.id AND users_roles.role_id > 3 AND users_roles.role_id < 7")
                        open_id = ""
                        all_open_id.each do |item|
                            if not item.open_id.blank?
                                open_id += item.open_id + ","
                            end
                        end
                        oauth = Oauth.find(1)
                        company_id = oauth.company_id
                        company_token = oauth.company_token
                        url = 'https://openapi.b.qq.com/api/tips/send'
                        if not open_id.blank? 
                            url += '?company_id='+company_id
                            url += '&company_token='+company_token
                            url += '&app_id=200710667'
                            url += '&client_ip=120.25.151.208'
                            url += '&oauth_version=2'
                            url += '&to_all=0'  
                            url += '&receivers='+open_id.chop
                            url += '&window_title=Fastbom-PCB AND PCBA'
                            url += '&tips_title='+URI.encode('生产部的宝宝们')
                            url += '&tips_content='+URI.encode('有新的回复，点击查看。')
                            url += '&tips_url=erp.fastbom.com/feedback?id='+topic_up.id.to_s 
                            resp = Net::HTTP.get_response(URI(url))
                        end 
                    end
                    if topic_up.feedback_receive =~ /engineering/
                        all_open_id = User.find_by_sql("SELECT users_roles.role_id,users_roles.user_id,users.id,users.email,users.s_name,users.open_id,users.full_name FROM users INNER JOIN users_roles ON users_roles.user_id = users.id AND users_roles.role_id = '7'")
                        open_id = ""
                        all_open_id.each do |item|
                            if not item.open_id.blank?
                                open_id += item.open_id + ","
                            end
                        end
                        oauth = Oauth.find(1)
                        company_id = oauth.company_id
                        company_token = oauth.company_token
                        url = 'https://openapi.b.qq.com/api/tips/send'
                        if not open_id.blank? 
                            url += '?company_id='+company_id
                            url += '&company_token='+company_token
                            url += '&app_id=200710667'
                            url += '&client_ip=120.25.151.208'
                            url += '&oauth_version=2'
                            url += '&to_all=0'  
                            url += '&receivers='+open_id.chop
                            url += '&window_title=Fastbom-PCB AND PCBA'
                            url += '&tips_title='+URI.encode('工程部的宝宝们')
                            url += '&tips_content='+URI.encode('有新的回复，点击查看。')
                            url += '&tips_url=erp.fastbom.com/feedback?id='+topic_up.id.to_s 
                            resp = Net::HTTP.get_response(URI(url))
                        end 
                    end
                    if topic_up.feedback_receive =~ /merchandiser/
                        all_open_id = User.find_by_sql("SELECT users_roles.role_id,users_roles.user_id,users.id,users.email,users.s_name,users.open_id,users.full_name FROM users INNER JOIN users_roles ON users_roles.user_id = users.id AND users_roles.role_id = '9'")
                        open_id = ""
                        all_open_id.each do |item|
                            if not item.open_id.blank?
                                open_id += item.open_id + ","
                            end
                        end
                        oauth = Oauth.find(1)
                        company_id = oauth.company_id
                        company_token = oauth.company_token
                        url = 'https://openapi.b.qq.com/api/tips/send'
                        if not open_id.blank? 
                            url += '?company_id='+company_id
                            url += '&company_token='+company_token
                            url += '&app_id=200710667'
                            url += '&client_ip=120.25.151.208'
                            url += '&oauth_version=2'
                            url += '&to_all=0'  
                            url += '&receivers='+open_id.chop
                            url += '&window_title=Fastbom-PCB AND PCBA'
                            url += '&tips_title='+URI.encode('跟单部的宝宝们')
                            url += '&tips_content='+URI.encode('有新的回复，点击查看。')
                            url += '&tips_url=erp.fastbom.com/feedback?id='+topic_up.id.to_s 
                            resp = Net::HTTP.get_response(URI(url))
                        end 
                    end
                    if topic_up.feedback_receive =~ /procurement/
                        all_open_id = User.find_by_sql("SELECT users_roles.role_id,users_roles.user_id,users.id,users.email,users.s_name,users.open_id,users.full_name FROM users INNER JOIN users_roles ON users_roles.user_id = users.id AND (users_roles.role_id = '10' OR users_roles.role_id = '16' OR users_roles.role_id = '17' OR users_roles.role_id = '18')")
                        open_id = ""
                        all_open_id.each do |item|
                            if not item.open_id.blank?
                                open_id += item.open_id + ","
                            end
                        end
                        oauth = Oauth.find(1)
                        company_id = oauth.company_id
                        company_token = oauth.company_token
                        url = 'https://openapi.b.qq.com/api/tips/send'
                        if not open_id.blank? 
                            url += '?company_id='+company_id
                            url += '&company_token='+company_token
                            url += '&app_id=200710667'
                            url += '&client_ip=120.25.151.208'
                            url += '&oauth_version=2'
                            url += '&to_all=0'  
                            url += '&receivers='+open_id.chop
                            url += '&window_title=Fastbom-PCB AND PCBA'
                            url += '&tips_title='+URI.encode('采购部的宝宝们')
                            url += '&tips_content='+URI.encode('有新的回复，点击查看。')
                            url += '&tips_url=erp.fastbom.com/feedback?id='+topic_up.id.to_s 
                            resp = Net::HTTP.get_response(URI(url))
                        end 
                    end                    







                    if not params[:production_feedback].blank? and params[:send_up] != "mark" 
                        feedback_up = Feedback.new 
                        feedback_up.send_to = params[:send_up].join(",")   
                        feedback_up.topic_id = params[:feedback_up]              #回复对应的帖子 id
                        feedback_up.order_no = work_up.order_no                  #回复对应的的order
                        feedback_up.product_code = work_up.product_code          #回复对应的物料
                        feedback_up.order_id = params[:feedback_up]              #回复对应的order id
                        feedback_up.feedback_title = params[:feedback_title]     #标题
                        if ( params[:production_feedback] =~ /width="(.\d*")/ )  
                            params[:production_feedback].gsub!(/width="(.\d*")/, "")
                        end
                        if ( params[:production_feedback] =~ /height="(.\d*")/ )  
                            params[:production_feedback].gsub!(/height="(.\d*")/, "")
                        end
                        params[:production_feedback].gsub!('<img ','<img width="200" height="100" ') 
                        feedback_up.feedback = params[:production_feedback]     #回复内容
                        feedback_up.feedback_type = "production"               #回复人部门
                        #feedback_up.feedback_receive = params[:feedback_type]    #收贴的部门
                        #feedback_up.feedback_receive_user = params[:user_name]   #收贴的人
                        #feedback_up.feedback_level = 1                          #暂时没用
                        #feedback_up.feedback_id = 1                             #暂时没用
                        feedback_up.user_name = current_user.email                     #发帖的人
                        feedback_up.save
                    elsif not params[:engineering_feedback].blank? and params[:send_up].to_s != "mark" 
                        feedback_up = Feedback.new  
                        feedback_up.send_to = params[:send_up].join(",") 
                        feedback_up.topic_id = params[:feedback_up]              #回复对应的帖子 id    
                        feedback_up.order_no = work_up.order_no                  #回复对应的的order
                        feedback_up.product_code = work_up.product_code          #回复对应的物料
                        feedback_up.order_id = params[:feedback_up]              #回复对应的order id
                        feedback_up.feedback_title = params[:feedback_title]     #标题
                        if ( params[:engineering_feedback] =~ /width="(.\d*")/ )  
                            params[:engineering_feedback].gsub!(/width="(.\d*")/, "")
                        end
                        if ( params[:engineering_feedback] =~ /height="(.\d*")/ )  
                            params[:engineering_feedback].gsub!(/height="(.\d*")/, "")
                        end
                        params[:engineering_feedback].gsub!('<img ','<img width="200" height="100" ') 
                        feedback_up.feedback = params[:engineering_feedback]     #回复内容
                        feedback_up.feedback_type = "engineering"               #回复人部门
                        #feedback_up.feedback_receive = params[:feedback_type]    #收贴的部门
                        #feedback_up.feedback_receive_user = params[:user_name]   #收贴的人
                        #feedback_up.feedback_level = 1                          #暂时没用
                        #feedback_up.feedback_id = 1                             #暂时没用
                        feedback_up.user_name = current_user.email                     #发帖的人
                        feedback_up.save
                    elsif not params[:sell_feedback].blank? 
                        feedback_up = Feedback.new  
                        feedback_up.topic_id = params[:feedback_up]              #回复对应的帖子 id           
                        feedback_up.order_no = work_up.order_no                  #回复对应的的order
                        feedback_up.product_code = work_up.product_code          #回复对应的物料
                        feedback_up.order_id = params[:feedback_up]              #回复对应的order id
                        feedback_up.feedback_title = params[:feedback_title]      #标题
                        if ( params[:sell_feedback] =~ /width="(.\d*")/ )  
                            params[:sell_feedback].gsub!(/width="(.\d*")/, "")
                        end
                        if ( params[:sell_feedback] =~ /height="(.\d*")/ )  
                            params[:sell_feedback].gsub!(/height="(.\d*")/, "")
                        end
                        params[:sell_feedback].gsub!('<img ','<img width="200" height="100" ') 
                        feedback_up.feedback = params[:sell_feedback]             #回复内容
                        feedback_up.feedback_type = "sell"                        #回复人部门
                        #feedback_up.feedback_receive = params[:feedback_type]     #收贴的部门
                        #feedback_up.feedback_receive_user = params[:user_name]    #收贴的人
                        #feedback_up.feedback_level = 1                            #暂时没用
                        #feedback_up.feedback_id = 1                               #暂时没用
                        feedback_up.user_name = current_user.email                     #发帖的人
                        feedback_up.save
                    elsif not params[:merchandiser_feedback].blank? and params[:send_up].to_s != "mark"                      
                        feedback_up = Feedback.new  
                        feedback_up.send_to = params[:send_up].join(",") 
                        feedback_up.topic_id = params[:feedback_up]              #回复对应的帖子 id 
                        feedback_up.order_no = work_up.order_no                  #回复对应的的order
                        feedback_up.product_code = work_up.product_code          #回复对应的物料
                        feedback_up.order_id = params[:feedback_up]              #回复对应的order id
                        feedback_up.feedback_title = params[:feedback_title]     #标题 
                        if ( params[:merchandiser_feedback] =~ /width="(.\d*")/ )  
                            params[:merchandiser_feedback].gsub!(/width="(.\d*")/, "")
                        end
                        if ( params[:merchandiser_feedback] =~ /height="(.\d*")/ )  
                            params[:merchandiser_feedback].gsub!(/height="(.\d*")/, "")
                        end
                        params[:merchandiser_feedback].gsub!('<img ','<img width="200" height="100" ') 
                        feedback_up.feedback = params[:merchandiser_feedback]    #回复内容
                        feedback_up.feedback_type = "merchandiser"               #回复人部门
                        feedback_up.feedback_level = feedback_level               #回复是否为最终解决方案
                        #feedback_up.feedback_receive = params[:feedback_type]    #收贴的部门
                        #feedback_up.feedback_receive_user = params[:user_name]   #收贴的人
                        #feedback_up.feedback_level = 1                          #暂时没用
                        #feedback_up.feedback_id = 1                             #暂时没用
                        feedback_up.user_name = current_user.email                     #发帖的人
                        feedback_up.save
                    elsif not params[:procurement_feedback].blank? and params[:send_up].to_s != "mark"                        
                        feedback_up = Feedback.new 
                        feedback_up.send_to = params[:send_up].join(",") 
                        feedback_up.topic_id = params[:feedback_up]              #回复对应的帖子 id     
                        feedback_up.order_no = work_up.order_no                  #回复对应的的order
                        feedback_up.product_code = work_up.product_code          #回复对应的物料
                        feedback_up.order_id = params[:feedback_up]              #回复对应的order id
                        feedback_up.feedback_title = params[:feedback_title]     #标题
                        if ( params[:procurement_feedback] =~ /width="(.\d*")/ )  
                            params[:procurement_feedback].gsub!(/width="(.\d*")/, "")
                        end
                        if ( params[:procurement_feedback] =~ /height="(.\d*")/ )  
                            params[:procurement_feedback].gsub!(/height="(.\d*")/, "")
                        end
                        params[:procurement_feedback].gsub!('<img ','<img width="200" height="100" ') 
                        feedback_up.feedback = params[:procurement_feedback]     #回复内容
                        feedback_up.feedback_type = "procurement"               #回复人部门
                        #feedback_up.feedback_receive = params[:feedback_type]    #收贴的部门
                        #feedback_up.feedback_receive_user = params[:user_name]   #收贴的人
                        #feedback_up.feedback_level = 1                          #暂时没用
                        #feedback_up.feedback_id = 1                             #暂时没用
                        feedback_up.user_name = current_user.email                     #发帖的人
                        feedback_up.save
                    end                    
                else
                    work_history = Work.new
                    if not params[:order_date].blank? 
                        work_history.order_date = params[:order_date].strip
                    end
                    work_history.order_no = work_up.order_no
                    if not params[:order_quantity].blank?
                        work_history.order_quantity = params[:order_quantity].strip
                    end
                    if not params[:salesman_end_date].blank?
                        work_history.salesman_end_date = params[:salesman_end_date].strip
                    end
                    if not params[:product_code].blank?
                        work_history.product_code = params[:product_code].strip
                    end
                    if not params[:warehouse_quantity].blank?
                        work_history.warehouse_quantity = params[:warehouse_quantity].strip
                    end
                    if not params[:smd].blank?
                        work_history.smd = params[:smd].strip
                    end
                    if not params[:dip].blank?
                        work_history.dip = params[:dip].strip
                    end
                    if not params[:smd_start_date].blank?
                        work_history.smd_start_date = params[:smd_start_date].strip
                    end
                    if not params[:smd_end_date].blank?
                        work_history.smd_end_date = params[:smd_end_date].strip
                    end
                    if params[:smd_state]
                        work_history.smd_state = params[:smd_state].strip
                    end

                    if not params[:dip_start_date].blank?
                        work_history.dip_start_date = params[:dip_start_date].strip
                    end
                    if not params[:dip_end_date].blank?
                        work_history.dip_end_date = params[:dip_end_date].strip
                    end
                    if not params[:update_date].blank?
                        work_history.update_date = params[:update_date].strip
                    end
                    if not params[:production_feedback].blank?
                        work_history.production_feedback = params[:production_feedback].strip
                    end
                    if not params[:engineering_feedback].blank?
                        work_history.test_feedback = params[:engineering_feedback].strip
                    end
                    if not params[:supplement_date].blank?
                        work_history.supplement_date = params[:supplement_date].strip
                    end
                    if params[:feed_state]
                        work_history.feed_state = params[:feed_state].strip
                    end
                    if not params[:clear_date].blank?
                        work_history.clear_date = params[:clear_date].strip
                    end
                    if not params[:salesman_state].blank?
                        work_history.salesman_state = params[:salesman_state].strip
                    end
                    if params[:remark]
                        work_history.remark = params[:remark].strip
                    end
                    work_history.user_name = current_user.email
                    work_history.save
                end                      
            end
            where_def = "  work_flows.id = '" + params[:work_id] + "'"
            @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE "  + where_def + " ORDER BY work_flows.updated_at DESC ").paginate(:page => params[:page], :per_page => 10)
            @order_no = work_up.order_no
        end
        limit = "LIMIT 20"        
        @open = "collapse in"
        @pic = "glyphicon glyphicon-minus"
        
        flash.now[:success] = "数据更新成功!！"
        if can? :work_c, :all
            @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE topics.feedback_receive = 'production' ORDER BY topics.updated_at DESC " ).paginate(:page => params[:page], :per_page => 10)
            if params[:order] 
                @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + where_def ).paginate(:page => params[:page], :per_page => 10)
            end
            redirect_to work_flow_path(), notice: "订单数据更新成功！" and return
            #render "production.html.erb"
        elsif can? :work_d, :all
            #@work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE "  + where_def + " ORDER BY work_flows.updated_at DESC " + limit ).first
            @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE topics.feedback_receive = 'engineering' ORDER BY topics.updated_at DESC " ).paginate(:page => params[:page], :per_page => 10)
            if params[:order] 
                @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + where_def ).paginate(:page => params[:page], :per_page => 10)
            end
            render "engineering.html.erb"
        elsif can? :work_b, :all
            render "delivery_date.html.erb"
            #redirect_to action: "index", page: "#{use_page}"
        elsif can? :work_e, :all
            #render "sell_feedback.html.erb"
            #render "sell.html.erb"
            redirect_to work_flow_path() and return
        elsif can? :work_f, :all
           # @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE topics.feedback_receive = 'merchandiser' ORDER BY topics.updated_at DESC " ).paginate(:page => params[:page], :per_page => 10)
            #if params[:order] 
                #@work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + where_def ).paginate(:page => params[:page], :per_page => 10)
            #end
            #render "merchandiser.html.erb" 
            redirect_to work_flow_merchandiser_path(where_def: where_def, order_no: params[:order].to_s,open: @open,pic: @pic), notice: "订单数据更新成功！" and return
        elsif can? :work_g, :all
            @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE topics.feedback_receive = 'procurement' ORDER BY topics.updated_at DESC " ).paginate(:page => params[:page], :per_page => 10)
            if params[:order] 
                @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + where_def ).paginate(:page => params[:page], :per_page => 10)
            end
            render "procurement.html.erb" 
        else
            redirect_to work_flow_path(), notice: "订单数据更新成功！"
        end
    end

    def work_flow_merchandiser
        @open = params[:open]
        @pic = params[:pic]
        @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE topics.feedback_receive = 'merchandiser' ORDER BY topics.updated_at DESC " ).paginate(:page => params[:page], :per_page => 10)
        if params[:order_no] 
            @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + params[:where_def] ).paginate(:page => params[:page], :per_page => 10)
        end
        render "merchandiser.html.erb"
    end

    private
        def pcb_params
  	    params.require(:att).permit(:att)
  	end

        class ColorFormat < Spreadsheet::Format
            def initialize(gb_color, font_color)
                super :pattern => 1, :pattern_fg_color => gb_color,:color => font_color, :text_wrap => 1
            end
        end
end
