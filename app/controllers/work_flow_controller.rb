require 'will_paginate/array'
require 'roo'
require 'spreadsheet'
require 'axlsx'
class WorkFlowController < ApplicationController
before_filter :authenticate_user!
    
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
        if not current_user.s_name.blank?
            if current_user.s_name.size == 1
                @quate = PcbOrder.where("#{where_date + where_5star}  pcb_orders.state <> 'new' AND pcb_orders.order_sell = '#{current_user.email}'").order("pcb_orders.updated_at DESC").paginate(:page => params[:page], :per_page => 20)
            else 
                if can? :work_admin, :all
                    @quate = PcbOrder.find_by_sql("SELECT pcb_orders.* FROM pcb_orders  WHERE #{where_date + where_5star}  pcb_orders.state <> 'new'#{where_sell}").paginate(:page => params[:page], :per_page => 20)
                else
                    @quate = PcbOrder.find_by_sql("SELECT pcb_orders.* FROM pcb_orders JOIN users ON pcb_orders.order_sell = users.email WHERE #{where_date + where_5star}  pcb_orders.state <> 'new' AND users.team = '#{current_user.team}'#{where_sell}").paginate(:page => params[:page], :per_page => 20)
                end
            end
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
                    get_item_data.buy_user = params[:buy_user]
                    get_item_data.save
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
        @pmc_add_list = PiPmcAddInfo.where(state: "new").paginate(:page => params[:page], :per_page => 20)
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
        if can? :work_d, :all or can? :work_admin, :all 
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

    def factory_in
        if not params[:order_no].blank?
            @buy_done = PcbOrderItem.where(buy_type: "done",pcb_order_no_son: params[:order_no].strip)
        else
            @buy_done = PcbOrderItem.where(buy_type: "done")
        end
    end

    def factory_out
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
        wh_item = PiWhItem.new
        wh_item.pmc_flag = pi_buy_item.pmc_flag
        wh_item.pi_pmc_item_id = pi_buy_item.pi_pmc_item_id
        wh_item.buy_user = pi_buy_item.buy_user
        wh_item.pi_wh_info_no = params[:wh_order_no]
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
        @pi_buy = PiBuyItem.where(pi_buy_info_id: @pi_buy_info.id)
        @all_dn = "[&quot;"
        all_s_dn = AllDn.find_by_sql("SELECT DISTINCT all_dns.dn, all_dns.dn_long FROM all_dns GROUP BY all_dns.dn")
        all_s_dn.each do |dn|
            @all_dn += "&quot;,&quot;" + dn.dn.to_s + "&#{dn.dn_long.to_s}"
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
        @w_wh = PiBuyInfo.where(state: "check")
    end

    def pi_buy_checked_list
        @w_wh = PiBuyInfo.where(state: "checked")
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
            up_state.state = "checked"
            up_state.save
            PiBuyItem.where(pi_buy_info_id: up_state.id).each do |item|
                item.state = "checked"
                item.save
                pmc_data = PiPmcItem.find_by_id(item.pi_pmc_item_id)
                #pmc_data.buy_qty = item.qty
                pmc_data.state = "checked" 
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
            up_state.state = "buy"
            up_state.save
            PiBuyItem.where(pi_buy_info_id: up_state.id).each do |item|
                item.state = "buying"
                item.save
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
                    put_pdn.save
                    #更新所有价格
                    change_pmc_cost = PiPmcItem.where("moko_part = '#{item.moko_part}' AND (state = 'buy_adding' OR state = 'new' OR state = 'pass')")
                    if not change_pmc_cost.blank?
                        change_pmc_cost.update_all "cost = '#{item.cost}'"
                    end
                    change_buy_cost = PiBuyItem.where("moko_part = '#{item.moko_part}' AND state = 'new'").update_all "cost = '#{item.cost}'"
                end

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
        @history_list = PDn.where(part_code: params[:part_code]).order(order_set)
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
                @c_table += '<tr>'
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
        up_dn = PiBuyInfo.find_by(pi_buy_no: params[:pi_buy_no])
        up_dn.dn = AllDn.find_by_id(params[:id]).dn
        up_dn.dn_long = AllDn.find_by_id(params[:id]).dn_long
        up_dn.save     
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

        redirect_to edit_pi_buy_path(pi_buy_no: params[:pi_buy_no])
    end

    def add_pi_buy_item
        if params[:roles]
            params[:roles].each do |item_id|
                #item_data = PItem.find_by_id(item_id)
                
                item_data = PiPmcItem.find_by_id(item_id)
                if not item_data.blank?
                    find_buy_data = PiBuyItem.find_by_pi_pmc_item_id(item_id)
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
                        add_buy_data.pi_buy_info_id = params[:pi_buy_id]
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
        end
        redirect_to :back
    end

    def pmc_check_pass
        if can? :work_a, :all or can? :work_admin, :all
            item_data = PiPmcItem.find_by_id(params[:id])
            if not item_data.blank?
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
                            wh_data.qty = wh_data.qty - pmc_data.qty
                            wh_data.temp_moko_qty = wh_data.temp_moko_qty + pmc_data.qty
                            #wh_data.wh_qty = wh_data.wh_qty - pmc_data.qty
                            #wh_data.wh_f_qty = wh_data.wh_f_qty - pmc_data.qty
                        #如果实际库存不满足需求
                        else wh_data.qty.to_i - pmc_data.qty.to_i < 0
                            pmc_data.buy_qty = wh_data.qty
                            pmc_data.pmc_qty = wh_data.qty
                            wh_data.temp_moko_qty = wh_data.temp_moko_qty + wh_data.qty
                            #wh_data.wh_qty = wh_data.wh_qty - wh_data.qty
                            #wh_data.wh_f_qty = wh_data.wh_f_qty - wh_data.qty
                            wh_data.qty = 0
                        end
                        pmc_data.save
                        wh_data.save
                        temp_qty = temp_qty - pmc_data.buy_qty
                    end
                    #2再判断是否要减去虚拟库存 
                    if temp_qty > 0 and wh_data.future_qty > 0
                        if temp_qty == pmc_data.qty
                            pmc_data.buy_user = "MOKO_TEMP"
                            #如果虚拟库存满足需求
                            if wh_data.future_qty - pmc_data.qty >= 0
                                pmc_data.buy_qty = pmc_data.qty
                                pmc_data.pmc_qty = pmc_data.qty
                                wh_data.future_qty = wh_data.future_qty - pmc_data.qty
                                wh_data.temp_future_qty = wh_data.temp_future_qty + pmc_data.qty
                            #如果虚拟库存不满足需求
                            else wh_data.future_qty - pmc_data.qty < 0
                                pmc_data.buy_qty = wh_data.future_qty
                                pmc_data.pmc_qty = wh_data.future_qty
                                wh_data.future_qty = 0
                                wh_data.temp_future_qty = wh_data.temp_future_qty + wh_data.future_qty
                            end
                            pmc_data.save
                            wh_data.save
                            temp_qty = temp_qty - pmc_data.buy_qty
                        else
                            add_future_data = PiPmcItem.new
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
                            if wh_data.future_qty - temp_qty >= 0
                                add_future_data.buy_qty = temp_qty
                                add_future_data.pmc_qty = temp_qty
                                wh_data.future_qty = wh_data.future_qty - pmc_data.qty
                                wh_data.temp_future_qty = wh_data.temp_future_qty + pmc_data.qty
                            #如果虚拟库存不满足需求
                            else wh_data.future_qty - temp_qty < 0
                                add_future_data.buy_qty = wh_data.future_qty
                                add_future_data.pmc_qty = wh_data.future_qty
                                wh_data.future_qty = 0
                                wh_data.temp_future_qty = wh_data.temp_future_qty + wh_data.future_qty
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
                            temp_qty = temp_qty - add_future_data.buy_qty
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
                        wh_data.temp_buy_qty = wh_data.temp_buy_qty + temp_qty
                        wh_data.true_buy_qty = wh_data.true_buy_qty + temp_qty
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
        pmc_where = "state <> 'new'"
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

    def pmc_new
        Rails.logger.info("pmc_new--------------------------------------1")
        @pi_buy = PiInfo.find_by_sql("SELECT p_items.*,pi_items.order_item_id FROM pi_infos INNER JOIN pi_items ON pi_infos.pi_no = pi_items.pi_no INNER JOIN p_items ON pi_items.bom_id = p_items.procurement_bom_id WHERE pi_infos.state = 'checked' AND p_items.buy = '' ORDER BY p_items.product_id DESC")
        if @pi_buy
            Rails.logger.info("pmc_new--------------------------------------2")
            @pi_buy.each do |item_buy|
                need_buy = "no"
                need_chk = "no"
                item_id = item_buy.id
                item_data = PItem.find_by_id(item_id)
                if not item_data.blank?
                    Rails.logger.info("pmc_new--------------------------------------3")
                    find_buy_data = PiPmcItem.find_by_p_item_id(item_id)
                    if find_buy_data.blank?
                        Rails.logger.info("pmc_new--------------------------------------4")
                        add_buy_data = PiPmcItem.new
                        add_buy_data.state = "new"
                        add_buy_data.erp_no = item_data.erp_no
                        add_buy_data.erp_no_son = PcbOrderItem.find_by_id(item_buy.order_item_id).pcb_order_no_son
                        add_buy_data.moko_part = item_data.moko_part
                        add_buy_data.moko_des = item_data.moko_des
                        add_buy_data.part_code = item_data.part_code
        

                        moko_data = Product.find_by_id(item_buy.product_id)
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
                        sell_qty = item_data.pmc_qty
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
                            item_data.buy = "pmc"
                            item_data.save
                            Rails.logger.info("pmc_new--------------------------------------19")
                            #判断是否需要客供
                            if item_data.customer_qty > 0
                                add_customer_data = PiPmcItem.new
                                add_customer_data.state = "new"
                                add_customer_data.erp_no = item_data.erp_no
                                add_customer_data.erp_no_son = PcbOrderItem.find_by_id(item_buy.order_item_id).pcb_order_no_son
                                add_customer_data.moko_part = item_data.moko_part
                                add_customer_data.moko_des = item_data.moko_des
                                add_customer_data.part_code = item_data.part_code
                                add_customer_data.qty = sell_qty
                                add_customer_data.qty_in = item_data.customer_qty
                                add_customer_data.buy_user = "CUSTOMER"
                                add_customer_data.pmc_type = "CHK"
                                add_customer_data.buy_qty = item_data.customer_qty
                                add_customer_data.pmc_qty = item_data.customer_qty
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
                                    wh_data.temp_customer_qty = temp_customer_qty + add_customer_data.pmc_qty
                                    wh_data.save
                                end
                            end
                        end
                    end
                end
            end
        end
        pmc_where = "state = 'new'"
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
            add_part.save
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
        @pi_other_item = PiOtherItem.where(pi_no: @pi_info.pi_no)
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
                        row.push(PDn.where(p_item_id: item.id,color: "y").last!.cost)
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

    def wh_out

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

    def edit_wh_order
        @wh_info = PiWhInfo.find_by(pi_wh_no: params[:pi_wh_no])
        @wh_item = PiWhItem.where(pi_wh_info_no: params[:pi_wh_no])
        @all_dn = "[&quot;"
        all_s_dn = AllDn.find_by_sql("SELECT DISTINCT all_dns.dn_long,all_dns.dn FROM all_dns GROUP BY all_dns.dn")
        all_s_dn.each do |dn|
            @all_dn += "&quot;,&quot;" + dn.dn.to_s + "&#{dn.dn_long.to_s}"
        end
        @all_dn += "&quot;]"
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
                            @w_part += '<td>'+wh_item.qty_wait.to_s+'</td>'
                            @w_part += '<td>'+wh_item.qty_done.to_s+'</td>'
                            #@w_part += '<td>'+(wh_item.quantity*ProcurementBom.find(wh_item.procurement_bom_id).qty).to_s+'</td>'
                            @w_part += '<td><div class="input-group input-group-sm">'
                            @w_part += '<form class="form-inline" action="/add_wh_item" accept-charset="UTF-8" data-remote="true" method="post">'
                            @w_part += '<input id="wh_order_no"  name="wh_order_no" type="text"  class="sr-only"  value="'+params[:pi_wh_no].to_s+'">'
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
            #if wh_order.state == "new"
                wh_in_data = PiWhItem.where(pi_wh_info_no: params[:wh_no])
                if not wh_in_data.blank?
                    wh_in_data.each do |wh_in|
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
            end            
        end
        redirect_to wh_draft_list_path()
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
                @pi_buy = PiPmcItem.find_by_sql("SELECT * FROM `pi_pmc_items` WHERE (`pi_pmc_items`.`moko_part` LIKE '%#{params[:key_order]}%' OR (#{where_des})) AND `pi_pmc_items`.`state` = 'pass' AND `pi_pmc_items`.`buy_user` <> 'MOKO' ")
            else
                @pi_buy = PiPmcItem.where("state = 'pass' AND `buy_user` <> 'MOKO'")
            end
            #@pi_buy = PiInfo.find_by_sql("SELECT pi_infos.pi_no, pi_items.pi_no, p_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.pi_no = pi_items.pi_no INNER JOIN p_items ON pi_items.bom_id = p_items.procurement_bom_id WHERE (p_items.moko_part LIKE '%#{params[:key_order]}%' OR (#{where_des})) AND pi_infos.state = 'checked' AND p_items.buy IS NULL")    
            #@pi_buy = PiPmcItem.find_by_sql("SELECT * FROM `pi_pmc_items` WHERE (`pi_pmc_items`.`moko_part` LIKE '%#{params[:key_order]}%' OR (#{where_des})) AND `pi_pmc_items`.`state` = 'pass' ") 
            if not @pi_buy.blank?
                @pi_buy.each do |buy|
                    @table_buy += '<tr>'
                    @table_buy += '<td><input type="checkbox" value="'+buy.id.to_s+'" name="roles[]" id="roles_" checked></td>'
                    @table_buy += '<td>'+buy.moko_des.to_s+'</td>'
                    @table_buy += '<td>'+buy.pmc_qty.to_s+'</td>'
                    @table_buy += '<td>'+buy.cost.to_s+'</td>'
                    if not PDn.find_by_id(buy.dn_id).blank?
                        if not PDn.find_by_id(buy.dn_id).info.blank?
                            @table_buy += '<td><small><a href="'
                            @table_buy += dn.info.to_s
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
                                    @table_buy += '<a class="btn btn-info btn-xs" href="'+PDn.find(buy.dn_id).info+'" target="_blank">下载</a>'
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
            @c_info = AllDn.find_by_sql("SELECT DISTINCT all_dns.dn,all_dns.dn_long,id FROM all_dns WHERE all_dns.dn LIKE '%#{key_word}%' GROUP BY all_dns.dn")
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
                    @c_table += '<td><a rel="nofollow" data-method="get"  href="/find_dn_ch?id='+ cu.id.to_s + '&pi_buy_no=' + params[:pi_buy_no] + '"><div>' + cu.dn + '</div></a></td>'
                    @c_table += '<td><a rel="nofollow" data-method="get"  href="/find_dn_ch?id='+ cu.id.to_s + '&pi_buy_no=' + params[:pi_buy_no] + '"><div>' + cu.dn_long.to_s + '</div></a></td>'
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
        @pi_buy_list = PiBuyInfo.where(state: "new").paginate(:page => params[:page], :per_page => 20)
        @pi_buy = PiInfo.find_by_sql("SELECT pi_infos.pi_no, pi_items.pi_no, p_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.pi_no = pi_items.pi_no INNER JOIN p_items ON pi_items.bom_id = p_items.procurement_bom_id WHERE pi_infos.state = 'checked'").paginate(:page => params[:page], :per_page => 20)
    end

    def pi_waitfor_buy
        @pi_buy = PiPmcItem.where("state = 'pass' AND buy_user<> 'MOKO'").paginate(:page => params[:page], :per_page => 20)
        #@pi_buy = PiInfo.find_by_sql("SELECT pi_infos.pi_no, pi_items.pi_no, p_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.pi_no = pi_items.pi_no INNER JOIN p_items ON pi_items.bom_id = p_items.procurement_bom_id WHERE pi_infos.state = 'checked' AND p_items.buy IS NULL").paginate(:page => params[:page], :per_page => 20)
        
        #@pi_buy = PiInfo.find_by_sql("SELECT pi_infos.pi_no, pi_items.pi_no, p_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.pi_no = pi_items.pi_no INNER JOIN p_items ON pi_items.bom_id = p_items.procurement_bom_id WHERE pi_infos.state = 'checked'").paginate(:page => params[:page], :per_page => 20)
    end

    def pi_list
        if params[:key_order]
            @pilist = PiInfo.where("(c_code LIKE '%#{params[:key_order]}%' OR c_des LIKE '%#{params[:key_order]}%' OR p_name LIKE '%#{params[:key_order]}%' OR des_cn LIKE '%#{params[:key_order]}%' OR des_en LIKE '%#{params[:key_order]}%' OR pi_no LIKE '%#{params[:key_order]}%' OR remark LIKE '%#{params[:key_order]}%' OR follow_remark LIKE '%#{params[:key_order]}%') AND state <> 'new' AND pi_sell = '#{current_user.email}'").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
        else
            if params[:bom_chk]
                if can? :work_e, :all
                    @pilist = PiInfo.where(state: "check",bom_state: nil,pi_sell: current_user.email).order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    @pilist = PiInfo.where(state: "check",bom_state: nil).order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                end
                render "pi_list.html.erb" and return
            elsif params[:finance_chk]
                if can? :work_e, :all
                    @pilist = PiInfo.where(state: "check",bom_state: "checked",finance_state: nil,pi_sell: current_user.email).order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    @pilist = PiInfo.where(state: "check",bom_state: "checked",finance_state: nil).order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                end
                render "pi_list.html.erb" and return     
            elsif params[:checked]
                if can? :work_e, :all
                    @pilist = PiInfo.where(state: "checked",bom_state: "checked",finance_state: "checked",pi_sell: current_user.email).order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    @pilist = PiInfo.where(state: "checked",bom_state: "checked",finance_state: "checked").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                end
                render "pi_list.html.erb" and return
            else
                if can? :work_e, :all
                    @pilist = PiInfo.where("state <> 'new' AND pi_sell = '#{current_user.email}'").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    @pilist = PiInfo.where("state <> 'new'").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                end
            end
        end        
    end

    def pi_draft  
        if params[:commit] == "提交"
            pi_draft = PiInfo.find_by(pi_no: params[:p_pi])
            if can? :work_e, :all and pi_draft.state == "new"
                pi_draft.state = "check"
                
            end
            
            if can? :work_d, :all 
                if pi_draft.finance_state == "checked"
                    pi_draft.state = "checked"
                else
                    pi_draft.state = "check"
                end
                pi_draft.bom_state = "checked"
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
            end
            if can? :work_finance, :all 
                if pi_draft.bom_state == "checked"
                    pi_draft.state = "checked"
                else
                    pi_draft.state = "check"
                end
                pi_draft.finance_state = "checked"
            end
            pi_draft.save
            if can? :work_admin, :all 
                pi_draft.state = "checked"
                pi_draft.bom_state = "checked"
                pi_draft.finance_state = "checked"
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
        if can? :work_pcb_business, :all
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
            pi_item.saveinspect
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
        else
            pi_no = params[:pi_no]
        end
        #@pcblist = PcbOrder.where(state: "quotechk").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
        redirect_to edit_pcb_pi_path(pi_no: pi_no) and return    
    end

    def edit_pcb_pi
        @pi_info = PiInfo.find_by(pi_no: params[:pi_no])
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
        @pi_item = PiItem.where(pi_no: params[:pi_no])
        @pi_other_item = PiOtherItem.where(pi_no: params[:pi_no])
        @total_p = PiItem.where(pi_no: params[:pi_no]).sum("t_p") + PiOtherItem.where(pi_no: params[:pi_no]).sum("t_p")
        if can? :work_d, :all 
            @boms = ProcurementBom.find_by_id(@pi_info.pcb_customer_id)
            @bom_item = PItem.where(procurement_bom_id: @pi_info.pcb_customer_id)
            if not @bom_item.blank?
                @bom_item = @bom_item.select {|item| item.quantity != 0 }
            end
            Rails.logger.info("add-------------------------------------12")
            Rails.logger.info(@boms.inspect)
            Rails.logger.info("add-------------------------------------12")
            render "edit_pcb_pi_eng.html.erb" and return 
        end
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
        redirect_to edit_pcb_pi_path(pi_no: params[:c_pi_no],c_id: params[:id])
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
                    @c_table += '<td><a rel="nofollow" data-method="get"  href="/find_c_ch?id='+ cu.id.to_s + '&c_order_no=' + params[:c_order_no] + '"><div>' + cu.c_no + '</div></a></td>'
                    @c_table += '<td><a rel="nofollow" data-method="get"  href="/find_c_ch?id='+ cu.id.to_s + '&c_order_no=' + params[:c_order_no] + '"><div>' + cu.customer.to_s + '</div></a></td>'
                    @c_table += '<td><a rel="nofollow" data-method="get"  href="/find_c_ch?id='+ cu.id.to_s + '&c_order_no=' + params[:c_order_no] + '"><div>' + cu.customer_com.to_s + '</div></a></td>'
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
            q_order.save
            redirect_to pcb_order_list_path(quote: true) and return
        end
    end

    def del_pcb_order
        pcb_order = PcbOrder.find(params[:order_id])
        if can? :work_e, :all or can? :work_d, :all
            pcb_order.del_flag = "inactive"
            pcb_order.save
            #pcb_order.destroy
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
        edit_pi_item.unit_price = params[:edit_unit_price]
        edit_pi_item.pcb_price =params[:edit_pcb_price]
        edit_pi_item.com_cost = params[:edit_com_cost]
        edit_pi_item.pcba = params[:edit_pcba]
        edit_pi_item.t_p = params[:edit_t_p]
        if edit_pi_item.save
            if edit_pi_item.p_type == "PCBA"
                get_bom = ProcurementBom.find_by_id(edit_pi_item.bom_id)
                if not get_bom.blank?
                    bom_item = PItem.where(procurement_bom_id: get_bom.id)
                    if not bom_item.blank?
                        t_p = 0
                        bom_item.each do |item|
                            item.pmc_qty = get_bom.qty.to_i*item.quantity.to_i
                            item.save
                            if not item.cost.blank?
                                t_p = t_p + (item.pmc_qty*item.cost)
                            end
                        end
                        get_bom.t_p = t_p
                    end
                    get_bom.qty = edit_pi_item.qty
                    get_bom.save
                end
            end
        end
        redirect_to :back
    end

    def add_pi_other_item
        add_item = PiOtherItem.new
        add_item.c_id = params[:add_c_id_other]
        add_item.pi_no = params[:add_pi_no_other]
        add_item.p_type = params[:add_type_other]
        add_item.remark = params[:add_remark_other]
        add_item.t_p = params[:add_t_p_other]
        add_item.save
        redirect_to :back
    end

    def add_pi_sb
        add_sb = PiInfo.find_by_id(params[:add_pi_sb_id])
        add_sb.pi_shipping_cost = params[:add_sc]
        add_sb.pi_bank_fee = params[:add_bf]
        add_sb.t_p = params[:add_t_p]
        add_sb.t_p_rmb = params[:add_t_p_rmb]
        add_sb.save
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
        @pcb = PcbCustomer.new()
        #@pcb.user_id = current_user.id
        if PcbCustomer.maximum("id").blank?
            @pcb.c_no = "pcb1"
        else
            @pcb.c_no = "pcb" + (PcbCustomer.maximum("id") + 1).to_s
        end
        @pcb.customer = params[:customer]
        @pcb.customer_com = params[:customer_com]
        @pcb.email = params[:email] 
        @pcb.sell = current_user.email 
        @pcb.qty = params[:qty]
        @pcb.att = params[:att]
        @pcb.remark= params[:remark]
        @pcb.customer_country = params[:customer_country]
        @pcb.shipping_address = params[:shipping_address]      
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
            @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE topics.feedback_receive LIKE '%production%' ORDER BY topics.updated_at DESC " ).paginate(:page => params[:page], :per_page => 10)
            if params[:order] or params[:empty_date]
                @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + empty_date + where_def + add_where ).paginate(:page => params[:page], :per_page => 10)
                if @work_flow.size == 1                
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE product_code = '#{@work_flow.first.product_code}'").paginate(:page => params[:page], :per_page => 10)
                end
            end
            
            render "production.html.erb"
        elsif can? :work_d, :all
#工程部      
            start_date = ""
            if params[:start_date] != ""
                start_date = " AND topics.created_at > '#{params[:start_date]}'"
            end
            end_date = ""
            if params[:end_date] != ""
                end_date = " AND topics.created_at < '#{params[:end_date]}'"
            end
            @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE topics.feedback_receive LIKE '%engineering%' ORDER BY topics.updated_at DESC " ).paginate(:page => params[:page], :per_page => 10)
            if params[:order] 
                @work_flow = WorkFlow.find_by_sql("SELECT DISTINCT work_flows.order_no, work_flows.* FROM work_flows LEFT JOIN topics ON work_flows.id = topics.order_id WHERE " + where_def + add_where + start_date + end_date).paginate(:page => params[:page], :per_page => 10)
                #@work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + where_def + add_where).paginate(:page => params[:page], :per_page => 10)
                if @work_flow.size == 1                
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE product_code = '#{@work_flow.first.product_code}'").paginate(:page => params[:page], :per_page => 10)
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
            @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE #{where_o}  topics.topic_state = 'open' ORDER BY topics.mark " ).paginate(:page => params[:page], :per_page => 10)
            if params[:order]
                #if params[:order].size == 1 or params[:order].size == 2
                    #@work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + empty_date + where_def + add_where + "ORDER BY updated_at DESC " ).paginate(:page => params[:page], :per_page => 10)
                #else
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM (SELECT * FROM `work_flows` WHERE " + empty_date + where_def + add_where + ") AS a #{where_o_a} ORDER BY a.updated_at DESC " ).paginate(:page => params[:page], :per_page => 10)
                #end
                if @work_flow.size == 1 and params[:order].size > 2               
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE product_code = '#{@work_flow.first.product_code}'").paginate(:page => params[:page], :per_page => 10)
                end
            else
                if empty_date != ""                    
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM (SELECT * FROM `work_flows` WHERE "  + empty_date + where_def + add_where + ") AS a #{where_o_a} ORDER BY a.updated_at DESC " ).paginate(:page => params[:page], :per_page => 10)
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
                @topic = Topic.find_by_sql("SELECT topics.*,feedbacks.topic_id,feedbacks.feedback_level, POSITION('work_f' IN topics.mark) AS mark_chk FROM topics INNER JOIN feedbacks ON topics.id = feedbacks.topic_id WHERE feedbacks.feedback_level = 1 ORDER BY mark_chk " ).paginate(:page => params[:page], :per_page => 10)
            else
                @issue_lable = "未关闭的问题"
                @topic = Topic.find_by_sql("SELECT *, POSITION('work_f' IN topics.mark) AS mark_chk FROM `topics` WHERE topics.feedback_receive LIKE '%merchandiser%' ORDER BY mark_chk " ).paginate(:page => params[:page], :per_page => 10)
            end
            if params[:order] or params[:sort_date]
                @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + where_def + add_where + add_orderby).paginate(:page => params[:page], :per_page => 10)
                if @work_flow.size == 1                
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE product_code = '#{@work_flow.first.product_code}'").paginate(:page => params[:page], :per_page => 10)
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
            @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE topics.feedback_receive LIKE '%procurement%' ORDER BY topics.updated_at DESC " ).paginate(:page => params[:page], :per_page => 10)
            if params[:order] 
                if params[:order_s][:order_s].to_i == 5 
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM (SELECT DISTINCT feedbacks.order_no, feedbacks.feedback_type, feedbacks.created_at, feedbacks.updated_at FROM feedbacks WHERE feedbacks.feedback_type = 'procurement' GROUP BY feedbacks.order_no) A JOIN work_flows ON A.order_no = work_flows.order_no WHERE " + where_def + add_where + start_date_a + end_date_a + " ORDER BY	A.updated_at DESC").paginate(:page => params[:page], :per_page => 10)
                else
                    @work_flow = WorkFlow.find_by_sql("SELECT DISTINCT work_flows.order_no, work_flows.* FROM work_flows RIGHT JOIN topics ON work_flows.id = topics.order_id WHERE " + where_def + add_where + start_date + end_date).paginate(:page => params[:page], :per_page => 10)
                    #@work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + where_def + add_where).paginate(:page => params[:page], :per_page => 10)
                end
                if @work_flow.size == 1                
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE product_code = '#{@work_flow.first.product_code}'").paginate(:page => params[:page], :per_page => 10)
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
            @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + empty_date + where_def + add_where + add_orderby ).paginate(:page => params[:page], :per_page => 10)       
            #if @work_flow.size == 1                
                #@work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE product_code = '#{@work_flow.first.product_code}'").paginate(:page => params[:page], :per_page => 10)
            #end
            #render "index.html.erb"
            #redirect_to action: :index, data: { no_turbolink: true }
        end
        @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE topics.feedback_receive LIKE '%production%' ORDER BY topics.updated_at DESC " ).paginate(:page => params[:page], :per_page => 10)
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
        elsif can? :work_d, :all
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
            if @topic.mark.blank?
                @topic.mark = "lwork_fl"
            else
                @topic.mark += "lwork_fl"
            end
            @topic.save
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
                                elsif can? :work_d, :all 
                                    receive_new.delete("engineering")
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
            render "production.html.erb"
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
            render "sell.html.erb"
        elsif can? :work_f, :all
            @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE topics.feedback_receive = 'merchandiser' ORDER BY topics.updated_at DESC " ).paginate(:page => params[:page], :per_page => 10)
            if params[:order] 
                @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + where_def ).paginate(:page => params[:page], :per_page => 10)
            end
            render "merchandiser.html.erb" 
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
