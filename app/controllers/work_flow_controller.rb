require 'will_paginate/array'
class WorkFlowController < ApplicationController
before_filter :authenticate_user!

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
        all_s_dn = AllDn.find_by_sql("SELECT DISTINCT all_dns.dn_long FROM all_dns GROUP BY all_dns.dn")
        all_s_dn.each do |dn|
            @all_dn += "&quot;,&quot;" + dn.dn_long.to_s
        end
        @all_dn += "&quot;]"
    end

    def find_w_wh
        if params[:dn_code] != ""
            where_wh = "dn_long = '#{params[:dn_code].strip}' AND state = 'buy'"
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
            @w_part += '<th >待入</th>'
            @w_part += '<th >已入</th>'
            @w_part += '<th width="150">操作</th>'
            @w_part += '<tr>'
            @w_part += '</thead>'
            @w_part += '<tbody>'
            @w_wh_order = PiBuyInfo.where("#{where_wh}")
            if not @w_wh_order.blank?
                @w_wh_order.each do |wh_order|
                    wh_order_item = PiBuyItem.where(pi_buy_info_id: wh_order.id,state: nil)
                    if not wh_order_item.blank?
                        wh_order_item.each do |wh_item|                       
                            @w_part += '<tr id="wh_item_'+wh_item.id.to_s+'">'
                            @w_part += '<td>'+wh_order.dn_long.to_s+'('+wh_order.dn.to_s+')</td>'
                            @w_part += '<td>'+PiBuyInfo.find_by_id(wh_item.pi_buy_info_id).pi_buy_no.to_s+'</td>'
                            @w_part += '<td>'+wh_item.erp_no.to_s+'</td>'
                            @w_part += '<td>'+wh_item.moko_part.to_s+'</td>'
                            @w_part += '<td>'+wh_item.moko_des.to_s+'</td>'
                            @w_part += '<td>'+(wh_item.quantity*ProcurementBom.find(wh_item.procurement_bom_id).qty).to_s+'</td>'
                            @w_part += '<td>'+wh_item.qty_wait.to_s+'</td>'
                            @w_part += '<td>'+wh_item.qty_done.to_s+'</td>'
                            #@w_part += '<td>'+(wh_item.quantity*ProcurementBom.find(wh_item.procurement_bom_id).qty).to_s+'</td>'
                            @w_part += '<td><div class="input-group input-group-sm">'
                            @w_part += '<form class="form-inline" action="/add_wh_item" accept-charset="UTF-8" data-remote="true" method="post">'
                            @w_part += '<input id="wh_order_no"  name="wh_order_no" type="text"  class="sr-only"  value="'+params[:pi_wh_no].to_s+'">'
                            @w_part += '<input id="pi_buy_item_id"  name="pi_buy_item_id" type="text"  class="sr-only"  value="'+wh_item.id.to_s+'">'
                            @w_part += '<input id="wh_qty_in"  name="wh_qty_in" type="text" size="10" class="form-control input-sm"  value="'+(wh_item.quantity*ProcurementBom.find(wh_item.procurement_bom_id).qty-wh_item.qty_wait-wh_item.qty_done).to_s+'">'
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

    def add_wh_item
        pi_buy_item = PiBuyItem.find_by_id(params[:pi_buy_item_id])
        wh_item = PiWhItem.new
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
            if (pi_buy_item.qty_wait + pi_buy_item.qty_done) >= pi_buy_item.quantity*ProcurementBom.find(pi_buy_item.procurement_bom_id).qty 
                pi_buy_item.state = "done"
            end
            pi_buy_item.save
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
        if (pi_buy_item.qty_wait + pi_buy_item.qty_done) >= pi_buy_item.quantity*ProcurementBom.find(pi_buy_item.procurement_bom_id).qty 
            pi_buy_item.state = "done"
        else
            pi_buy_item.state = nil
        end
        if del_wh_item.destroy
            pi_buy_item.save
        end
        redirect_to :back
    end

    def wh_draft
        wh_order = PiWhInfo.find_by_pi_wh_no(params[:wh_no])
        if not wh_order.blank?
=begin
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
            elsif wh_order.state == "checked"
=end
            if wh_order.state == "new"
                wh_in_data = PiWhItem.where(pi_wh_info_no: params[:wh_no])
                if not wh_in_data.blank?
                    wh_in_data.each do |wh_in|
                        wh_data = WarehouseInfo.find_by_moko_part(wh_in.moko_part)
                        if not wh_data.blank?
                            wh_data.qty = wh_data.qty + wh_in.qty_in
                            #wh_data.save
                        else   
                            wh_data = WarehouseInfo.new
                            wh_data.moko_part = wh_in.moko_part
                            wh_data.moko_des = wh_in.moko_des
                            wh_data.qty = wh_in.qty_in                          
                            #wh_data.save
                        end
                        if wh_data.save
                            uo_buy_item = PiBuyItem.find_by_id(wh_in.pi_buy_item_id)
                            uo_buy_item.qty_done = uo_buy_item.qty_done + wh_in.qty_in
                            uo_buy_item.qty_wait = uo_buy_item.qty_wait - wh_in.qty_in
                            if (uo_buy_item.qty_done + uo_buy_item.qty_wait) >= uo_buy_item.quantity*ProcurementBom.find(uo_buy_item.procurement_bom_id).qty 
                                uo_buy_item.state = "done"
                            end
                            uo_buy_item.save
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
                                add_history_data.qty = item_data.quantity*ProcurementBom.find(item_data.procurement_bom_id).qty
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

    def send_pi_buy
        up_state = PiBuyInfo.find_by_pi_buy_no(params[:pi_buy_no])
        if not up_state.blank?
            up_state.state = "buy"
            up_state.save
        end
        redirect_to pi_waiting_for_path()
    end

    def pi_waiting_for
        @w_wh = PiBuyInfo.where(state: "buy")
    end

    def pi_buy_item
        @pi_buy = PiBuyItem.where(pi_buy_info_id: params[:pi_buy_info_id])
    end

    def add_pi_buy_item
        if params[:roles]
            params[:roles].each do |item_id|
                item_data = PItem.find_by_id(item_id)
                if not item_data.blank?
                    find_buy_data = PiBuyItem.find_by_p_item_id(item_id)
                    if find_buy_data.blank?
                        add_buy_data = PiBuyItem.new
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
                        if add_buy_data.save
                            item_data.buy = "done"
                            item_data.save
                        end
                    end
                end
            end
        end
        redirect_to :back
    end

    def find_pi_buy
        @table_buy = ''
        @table_buy += '<table class="table table-hover">'
        @table_buy += '<thead>'
        @table_buy += '<tr style="background-color: #eeeeee">'
        @table_buy += '<th width="20"></th>'
        @table_buy += '<th >MOKO DES</th>'
        @table_buy += '<th width="80">数量</th>'
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
                    where_des += "p_items.moko_des LIKE '%#{de}%'"
                    if des.size > (index + 1)
                        where_des += " AND "
                    end
                end      
            end
            @pi_buy = PiInfo.find_by_sql("SELECT pi_infos.pi_no, pi_items.pi_no, p_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.pi_no = pi_items.pi_no INNER JOIN p_items ON pi_items.bom_id = p_items.procurement_bom_id WHERE (p_items.moko_part LIKE '%#{params[:key_order]}%' OR (#{where_des})) AND pi_infos.state = 'checked' AND p_items.buy IS NULL")    
            if not @pi_buy.blank?
                @pi_buy.each do |buy|
                    @table_buy += '<tr>'
                    @table_buy += '<td><input type="checkbox" value="'+buy.id.to_s+'" name="roles[]" id="roles_" checked></td>'
                    @table_buy += '<td>'+buy.moko_des.to_s+'</td>'
                    @table_buy += '<td>'+buy.quantity.to_s+'</td>'
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
                    PItemRemark.where(p_item_id: buy.id).each do |remark_item|
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
            @c_info = AllDn.find_by_sql("SELECT DISTINCT all_dns.dn,all_dns.dn_long,id FROM all_dns WHERE all_dns.dn LIKE '%#{params[:dn_code]}%' GROUP BY all_dns.dn")
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

    def find_dn_ch
        up_dn = PiBuyInfo.find_by(pi_buy_no: params[:pi_buy_no])
        up_dn.dn = AllDn.find_by_id(params[:id]).dn
        up_dn.dn_long = AllDn.find_by_id(params[:id]).dn_long
        up_dn.save     
        redirect_to edit_pi_buy_path(pi_buy_no: params[:pi_buy_no])
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

    def edit_pi_buy  
        @pi_buy_find = PiInfo.find_by_sql("SELECT pi_infos.pi_no, pi_items.pi_no, p_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.pi_no = pi_items.pi_no INNER JOIN p_items ON pi_items.bom_id = p_items.procurement_bom_id WHERE pi_infos.state = 'checked' AND p_items.buy IS NULL")   
        @pi_buy_info = PiBuyInfo.find_by_pi_buy_no(params[:pi_buy_no])
        @pi_buy = PiBuyItem.where(pi_buy_info_id: @pi_buy_info.id)
        @all_dn = "[&quot;"
        all_s_dn = AllDn.find_by_sql("SELECT DISTINCT all_dns.dn FROM all_dns GROUP BY all_dns.dn")
        all_s_dn.each do |dn|
            @all_dn += "&quot;,&quot;" + dn.dn.to_s
        end
        @all_dn += "&quot;]"
    end

    def pi_buy_list
        @pi_buy_list = PiBuyInfo.where(state: "new").paginate(:page => params[:page], :per_page => 20)
        @pi_buy = PiInfo.find_by_sql("SELECT pi_infos.pi_no, pi_items.pi_no, p_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.pi_no = pi_items.pi_no INNER JOIN p_items ON pi_items.bom_id = p_items.procurement_bom_id WHERE pi_infos.state = 'checked'").paginate(:page => params[:page], :per_page => 20)
    end

    def pi_waitfor_buy
        @pi_buy = PiInfo.find_by_sql("SELECT pi_infos.pi_no, pi_items.pi_no, p_items.* FROM pi_infos INNER JOIN pi_items ON pi_infos.pi_no = pi_items.pi_no INNER JOIN p_items ON pi_items.bom_id = p_items.procurement_bom_id WHERE pi_infos.state = 'checked' AND p_items.buy IS NULL").paginate(:page => params[:page], :per_page => 20)
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
                    @pilist = PiInfo.where(state: "check",finance_state: nil,pi_sell: current_user.email).order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    @pilist = PiInfo.where(state: "check",finance_state: nil).order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
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
        copy_data.pcb_order_no = find_data.pcb_order_no
        if PcbOrderItem.find_by_pcb_order_no(find_data.pcb_order_no).blank?
            p_n =1
        else
            p_n = PcbOrderItem.find_by_pcb_order_no(find_data.pcb_order_no).pcb_order_no_son.split('-')[-1].to_i + 1
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
        PcbOrderItem.where(pcb_order_id: params[:id]).each do |q_item|
            pi_item = PiItem.new
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
=begin
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
=end
        end
        redirect_to :back
    end

    def new_pcb_pi
        if params[:pi_no] == "" or params[:pi_no] == nil
            if PiInfo.find_by_sql('SELECT pi_no FROM pi_infos WHERE to_days(pi_infos.created_at) = to_days(NOW())').blank?
                pi_n =1
            else
                pi_n = PiInfo.find_by_sql('SELECT pi_no FROM pi_infos WHERE to_days(pi_infos.created_at) = to_days(NOW())').last.pi_no.split("PI")[-1].to_i + 1
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
        @pi_item = PiItem.where(pi_no: params[:pi_no])
        @pi_other_item = PiOtherItem.where(pi_no: params[:pi_no])
        @total_p = PiItem.where(pi_no: params[:pi_no]).sum("t_p") + PiOtherItem.where(pi_no: params[:pi_no]).sum("t_p")
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

    def new_pcb_order
       if params[:new]
           if PcbOrder.find_by_sql('SELECT order_no FROM pcb_orders WHERE to_days(pcb_orders.created_at) = to_days(NOW())').blank?
                p_n =1
           else
                p_n = PcbOrder.find_by_sql('SELECT order_no FROM pcb_orders WHERE to_days(pcb_orders.created_at) = to_days(NOW())').last.order_no.to_s.chop.split(current_user.s_name_self.to_s)[-1].to_i + 1
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
            if can? :work_e, :all
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
        if can? :work_e, :all
            pcb_order.destroy
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
            @pcblist = PcbOrder.where("(c_code LIKE '%#{params[:key_order]}%' OR c_des LIKE '%#{params[:key_order]}%' OR p_name LIKE '%#{params[:key_order]}%' OR des_cn LIKE '%#{params[:key_order]}%' OR des_en LIKE '%#{params[:key_order]}%' OR order_no LIKE '%#{params[:key_order]}%' OR remark LIKE '%#{params[:key_order]}%' OR follow_remark LIKE '%#{params[:key_order]}%') AND state <> 'new' AND order_sell = '#{current_user.email}'").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
        else
            if params[:new] 
                if can? :work_a, :all
                    @pcblist = PcbOrder.where(state: "new").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                elsif can? :work_e, :all
                    @pcblist = PcbOrder.where(state: "new",order_sell: current_user.email).order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    @pcblist = PcbOrder.where(state: "new").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                end
                render "new_pcb_order_list.html.erb" and return
            elsif params[:quote]
                if can? :work_a, :all
                    @pcblist = PcbOrder.where(state: "quote").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                elsif can? :work_e, :all
                    @pcblist = PcbOrder.where(state: "quote",order_sell: current_user.email).order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    @pcblist = PcbOrder.where(state: "quote").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                end
                render "pcb_order_list.html.erb" and return
            elsif params[:bom_chk]
                if can? :work_a, :all
                    @pcblist = PcbOrder.where(state: "bom_chk").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                elsif can? :work_e, :all
                    @pcblist = PcbOrder.where(state: "bom_chk",order_sell: current_user.email).order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    @pcblist = PcbOrder.where(state: "bom_chk").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                end
                render "pcb_order_list.html.erb" and return
            elsif params[:place_an_order]
                if can? :work_a, :all
                    @pcblist = PcbOrder.where(state: "order").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                elsif can? :work_e, :all
                    @pcblist = PcbOrder.where(state: "order",order_sell: current_user.email).order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    @pcblist = PcbOrder.where(state: "order").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                end
                render "pcb_order_list.html.erb" and return
            elsif params[:quotechk]
                if can? :work_a, :all
                    @pcblist = PcbOrder.where(state: "quotechk").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                elsif can? :work_e, :all
                    @pcblist = PcbOrder.where(state: "quotechk",order_sell: current_user.email).order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    @pcblist = PcbOrder.where(state: "quotechk").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                end
                render "pcb_order_list.html.erb" and return
            else
                if can? :work_a, :all
                    @pcblist = PcbOrder.where("state <> 'new' ").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                elsif can? :work_e, :all
                    @pcblist = PcbOrder.where("state <> 'new' AND order_sell = '#{current_user.email}'").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
                else
                    @pcblist = PcbOrder.where("state <> 'new' ").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
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
        @pcb = PcbOrderItem.find(params[:edit_c_item_id])
        @pcb.moko_code = params[:edit_moko_code]
        @pcb.moko_des = params[:edit_moko_des]
        @pcb.des_en = params[:edit_des_en] 
        @pcb.des_cn = params[:edit_des_cn]
        @pcb.qty = params[:edit_qty]
        if not params[:edit_att].blank?
            @pcb.att = params[:edit_att]
        end
        @pcb.p_type = params[:edit_p_type]    
        @pcb.remark = params[:edit_follow_remark]
        if params[:edit_price]
            @pcb.t_p = params[:edit_price]
            @pcb.price = BigDecimal.new(params[:edit_price])/@pcb.qty
        end
        @pcb.save
        redirect_to :back
    end

    def edit_pi_item
        edit_pi_item = PiItem.find(params[:edit_c_item_id])
        edit_pi_item.t_p = params[:edit_t_p]
        edit_pi_item.price = params[:edit_price]
        edit_pi_item.des_en = params[:edit_des_en]
        edit_pi_item.des_cn = params[:edit_des_cn]
        edit_pi_item.qty = params[:edit_qty]
        edit_pi_item.remark = params[:edit_follow_remark]
        edit_pi_item.save
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

    def sell_view_baojia
        @boms = ProcurementBom.find(params[:bom_id])
        @baojia = PItem.where(procurement_bom_id: params[:bom_id])
    end

    def edit_orderinfo
        if params[:hint] == ""
           hint = 1
        else
           hint = params[:hint]
        end
        order_info = ProcurementBom.where(p_name_mom: params[:itemp_id]).update_all "order_country = '#{params[:order_country]}', star = '#{hint}', sell_remark = '#{Time.new().localtime.strftime('%y-%m-%d')} #{params[:sell_remark]}', sell_manager_remark = '#{params[:sell_manager_remark]}'"
        

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
    
    def sell_baojia_q
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
            @quate = ProcurementBom.find_by_sql("SELECT *,SUM(procurement_boms.t_p) AS sum_t_p FROM `procurement_boms` WHERE #{where_p + where_date + where_5star}  GROUP BY procurement_boms.p_name_mom").paginate(:page => params[:page], :per_page => 10)
        else
            if params[:start_date] != "" and  params[:start_date] != nil
                where_date += " procurement_boms.created_at > '#{params[:start_date]}'"
            end
            if params[:end_date] != "" and  params[:start_date] != nil
                where_date += " AND procurement_boms.created_at < '#{params[:end_date]}'"
            end
            if where_date != ""
                @quate = ProcurementBom.find_by_sql("SELECT *,SUM(procurement_boms.t_p) AS sum_t_p FROM `procurement_boms` WHERE #{where_date + where_5star}  GROUP BY procurement_boms.p_name_mom").paginate(:page => params[:page], :per_page => 10)
            else
                if params[:complete]
                    @quate = ProcurementBom.find_by_sql("SELECT *,SUM(procurement_boms.t_p) AS sum_t_p FROM `procurement_boms` WHERE procurement_boms.star = 5   GROUP BY procurement_boms.p_name_mom").paginate(:page => params[:page], :per_page => 10)
                else
                    @quate = ProcurementBom.find_by_sql("SELECT *,SUM(procurement_boms.t_p) AS sum_t_p FROM `procurement_boms`   GROUP BY procurement_boms.p_name_mom").paginate(:page => params[:page], :per_page => 10)
                end
            end
        end
        
        #@quate = ProcurementBom.find_by_sql("SELECT * FROM `procurement_boms` WHERE #{where_p + where_date}  ").paginate(:page => params[:page], :per_page => 10)
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
                where_def = "  POSITION('" + order + "' IN RIGHT(LEFT(work_flows.order_no,9),7)) = 6 and RIGHT(LEFT(work_flows.order_no,9),1) REGEXP '^[0-9]+$' "
                limit = ""
            elsif params[:order].strip.size == 2
                order = params[:order].strip
                #where_def = "  POSITION('" + order + "' IN work_flows.order_no) = 8"
                where_def = "  POSITION('" + order + "' IN work_flows.order_no) = 8"
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
                    where_o = "  POSITION('" + s_name + "' IN RIGHT(LEFT(topics.order_no,9),7)) = 6 and RIGHT(LEFT(topics.order_no,9),1) REGEXP '^[0-9]+$' AND "
                    #where_p = " POSITION('" + s_name + "' IN RIGHT(LEFT(procurement_boms.p_name,9),7)) = 6 and RIGHT(LEFT(procurement_boms.p_name,9),1) REGEXP '^[0-9]+$' "
                    where_o_a = " WHERE POSITION('" + s_name + "' IN RIGHT(LEFT(a.order_no,9),7)) = 6 and RIGHT(LEFT(a.order_no,9),1) REGEXP '^[0-9]+$' "
                elsif current_user.s_name.size == 2
                    s_name = current_user.s_name
                    where_o = "  POSITION('" + s_name + "' IN topics.order_no) = 8 AND "
                    #where_p = "  POSITION('" + s_name + "' IN procurement_boms.p_name) = 8 "
                    where_o_a = " WHERE POSITION('" + s_name + "' IN a.order_no) = 8 "
                elsif current_user.s_name.size > 2
                    where_o_a = " WHERE "
                    where_o = "("
                    #where_p = "("
                    current_user.s_name.split(",").each_with_index do |item,index|
                        s_name = item
                        if current_user.s_name.split(",").size > (index+1)
                            where_o += "  LOCATE('" + s_name + "', topics.order_no,3) = 8 OR "
                            #where_p += "  POSITION('" + s_name + "' IN procurement_boms.p_name) = 8 OR"
                            where_o_a += " LOCATE('" + s_name + "', a.order_no,3) = 8 OR"
                        else
                            where_o += "  LOCATE('" + s_name + "', topics.order_no,3) = 8) AND"
                            #where_p += "  POSITION('" + s_name + "' IN procurement_boms.p_name) = 8)"
                            where_o_a += " LOCATE('" + s_name + "', a.order_no,3) = 8 "
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
                if not params[:smd_state].blank?
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
end
