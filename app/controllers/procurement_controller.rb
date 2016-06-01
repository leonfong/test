#encoding: UTF-8
require 'roo'
require 'spreadsheet'
require 'will_paginate/array'
class ProcurementController < ApplicationController
skip_before_action :verify_authenticity_token
before_filter :authenticate_user!
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
	        @xls_file = Roo::Excel.new(params[:bom_path])
            else
                @xls_file = Roo::Excelx.new(params[:bom_path])
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
            all_item = []
            @sheet.row(row_use).each do |item|
                if not item =~ /\n/
                    if not item.blank? 
                        all_item << '"'+item+'":'+'"'+item+'"'
                    end
                end
            end
            all_title = @sheet.row(row_use).join("|")
            @bom.all_title = all_title  
            @bom.save
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
            Rails.logger.info("------------------------------------------------------------qq1")
            #Rails.logger.info(@sheet.row(row_use)[params[:partCol].to_i].split("").inspect)
            Rails.logger.info(@sheet.row(row_use)[params[:quantityCol].to_i].split("").inspect)
            Rails.logger.info(@sheet.row(row_use)[params[:refdesCol].to_i].split("").inspect)
            Rails.logger.info("------------------------------------------------------------qq2") 
            all_use = @sheet.row(row_use)[params[:partCol].to_i].split("")+@sheet.row(row_use)[params[:quantityCol].to_i].split("")+@sheet.row(row_use)[params[:refdesCol].to_i].split("")
            #params[:select_part].each do |use|
	    @parse_result.select! {|item| !item["#{@sheet.row(row_use)[params[:quantityCol].to_i]}"].blank? } #选择非空行
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
                        desa += item["#{@sheet.row(row_use)[des.to_i]}"].to_s + " "
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
                        #all_info += ""
                    #else
                        all_info += item["#{info}"].to_s + "|"
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
                        if refa =~ /r/i or refa =~ /c/i or refa =~ /d/i or refa =~ /v/i or refa =~ /q/i or refa =~ /lcd/i or refa =~ /led/i
                            bom_item.user_do = 77
                        elsif refa =~ /l/i or refa =~ /x/i or refa =~ /w/i
                            bom_item.user_do = 75
                        else
                            bom_item.user_do = 7
                        end
                    end
		    bom_item.description = desa
                    bom_item.quantity = qtya.to_i
                    bom_item.mpn = mpna
                    bom_item.fengzhuang = fengzhuang
                    bom_item.link = link
                    bom_item.other = othera
                    bom_item.all_info = all_info.chop
                    bom_item.user_id = current_user.id
                    bom_item.save
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

        @bom = ProcurementBom.new(bom_params)#使用页面传进来的文件名字作为参数创建一个bom对象
        @bom.user_id = current_user.id
        @file = @bom.excel_file_identifier
        @bom.no = "MB" + Time.new.strftime('%Y').to_s[-1] + Time.new.strftime('%m%d').to_s + "B" + Bom.find_by_sql('SELECT Count(procurement_boms.id)+1 AS all_no FROM procurement_boms WHERE to_days(procurement_boms.created_at) = to_days(NOW())').first.all_no.to_s + "B"
        #如果上传成功
	if @bom.save
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
	    @xls_file = Roo::Excel.new(@bom.excel_file.current_path)
        else
            @xls_file = Roo::Excelx.new(@bom.excel_file.current_path)
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
                        if not item.mpn.blank?
        #0.1.1先从自有物料中匹配mpn
                            use_mpn = Product.find_by_sql("SELECT * FROM products WHERE products.mpn LIKE '%#{item.mpn.strip}%'")
                            if not use_mpn.blank?
                                item.product_id = use_mpn.id
                                
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
                                    item.save
                                else
                                    item.save
                                end
                                #item.save
                                render "p_search_part.js.erb" and return
                            else
        #0.1.2如果自有物料不能匹配 
                                Rails.logger.info("qqqqqq-------------------------------------------------------qqqqqq")
                                match_product_old = search_bom_use(item.description) #根据历史记录查询产品
                                Rails.logger.info("qqqqqq-------------------------------------------------------qqqqqq")
                                Rails.logger.info(match_product_old.inspect)
                                Rails.logger.info("qqqqqq-------------------------------------------------------qqqqqq")
                                if match_product_old.blank?
                                    match_product = search_bom(item.description,item.part_code) #根据关键字和位号查询产品
                                elsif not match_product_old.dn_id.blank?
                                   
                                    match_dn = PDn.find(match_product_old.dn_id)
                                    add_dns = PDn.new
                                    add_dns.item_id = item.id
                                    add_dns.date = match_dn.date
                                    add_dns.part_code = match_dn.part_code
                                    add_dns.dn = match_dn.dn
                                    add_dns.dn_long = match_dn.dn_long
                                    add_dns.cost = match_dn.cost
                                    add_dns.qty = match_dn.qty
                                    add_dns.color = "g"
                                    add_dns.save
                                    item.cost = add_dns.cost
                                    item.color = "g"
                                    item.product_id = match_product_old.product_id
                                    item.dn_id = add_dns.id
                                    item.save
                                    @item = item
                                    render "p_search_part.js.erb" and return 
                                end
                                if not match_product.blank?
                                    item.product_id = match_product.first.id if match_product.count > 0
                                    
                                    @item = item
                                    part_code = Product.find(item.product_id).name
                                    all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{part_code}' AND all_dns.qty >= 100 ORDER BY all_dns.date DESC").first
                                #all_dns.each do |dns|
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
                            Rails.logger.info("22-------------------------------------------------------22")
                            match_product_old = search_bom_use(item.description) #根据历史记录查询产品
                            Rails.logger.info("qqqqqq-------------------------------------------------------qqqqqq")
                            Rails.logger.info(match_product_old.inspect)
                            Rails.logger.info("qqqqqq-------------------------------------------------------qqqqqq")
                            if match_product_old.blank?
                                match_product = search_bom(item.description,item.part_code) #根据关键字和位号查询产品
                            elsif not match_product_old.dn_id.blank?
                                match_dn = PDn.find(match_product_old.dn_id)
                                add_dns = PDn.new
                                add_dns.item_id = item.id
                                add_dns.date = match_dn.date
                                add_dns.part_code = match_dn.part_code
                                add_dns.dn = match_dn.dn
                                add_dns.dn_long = match_dn.dn_long
                                add_dns.cost = match_dn.cost
                                add_dns.qty = match_dn.qty
                                add_dns.color = "g"
                                add_dns.save
                                item.cost = add_dns.cost
                                item.color = "g"
                                item.product_id = match_product_old.product_id
                                item.dn_id = add_dns.id
                                item.save
                                @item = item
                                render "p_search_part.js.erb" and return 
                            end
                            if not match_product.blank?
                                item.product_id = match_product.first.id if match_product.count > 0
                                
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
                            
                            #item.product_id = match_product.first.id if match_product.count > 0
                            #item.save
                            #@item = item
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
                        @total_p += bomitem.cost*bomitem.quantity*@bom.qty.to_i
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

    def p_viewbom 
         @mpninfo = "SP1007-01WTG"
        #@mpninfo = Digikey.find(1)   
        #Rails.logger.info("--------------------------")
        #Rails.logger.info(@mpninfo.inspect)
        #Rails.logger.info("--------------------------")  
        @all_dn = "[&quot;"
        all_s_dn = AllDn.find_by_sql("SELECT DISTINCT all_dns.dn FROM all_dns GROUP BY all_dns.dn")
        all_s_dn.each do |dn|
            @all_dn += "&quot;,&quot;" + dn.dn.to_s
        end
        @all_dn += "&quot;]"
        @boms = ProcurementBom.find(params[:bom_id])
        if can? :work_g_all, :all
            @user_do = "7"
            @bom_item = PItem.where(procurement_bom_id: params[:bom_id])
        elsif can? :work_g_a, :all
            @user_do = "77"
            @bom_item = PItem.where(procurement_bom_id: params[:bom_id],user_do: "77")
        elsif can? :work_g_b, :all
            @user_do = "75"
            @bom_item = PItem.where(procurement_bom_id: params[:bom_id],user_do: "75")
        end
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
        elsif @boms.pcb_file.blank? or params[:bak]
            render "p_viewbom.html.erb"
            return false  
        else
            @shipping_info = ShippingInfo.where(user_id: current_user.id)
            render "submit_order.html.erb"
            return false
        end
    end






    def p_bomlist
        @boms = ProcurementBom.find_by_sql("SELECT * FROM `procurement_boms` WHERE `name` IS NULL ORDER BY `check` DESC,`created_at` DESC ").paginate(:page => params[:page], :per_page => 10)
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
        @match_products = Product.find_by_sql("SELECT products.*, min(`all_dns`.`price`) AS `min_price` FROM products INNER JOIN all_dns ON products.`name` = all_dns.part_code WHERE #{where_des} #{find_ptype} #{find_bom}  GROUP BY	`all_dns`.`part_code`").to_ary
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
                    @match_products[0..19].each do |item|
                        @bom_html = @bom_html + "<tr>"
                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>#{item.name.to_s}</div></a>"
                        @bom_html = @bom_html + "</td>"
                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>#{item.description.to_s}</div></a>"
                        @bom_html = @bom_html + "</td>"
                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>#{ActionController::Base.helpers.number_with_precision(item.min_price, precision: 4).to_s}</div></a>"
                        @bom_html = @bom_html + "</td>"
                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>OK</div></a>"
                        @bom_html = @bom_html + "</td>"
                        @bom_html = @bom_html + "</tr>"
                    end           
                end
            else
                @bom_html = ""
                unless @match_products.nil?
                    @match_products[0..19].each do |item|
                        @bom_html = @bom_html + "<tr>"
                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>#{item.name.to_s}</div></a>"
                        @bom_html = @bom_html + "</td>"
                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>#{item.description.to_s}</div></a>"
                        @bom_html = @bom_html + "</td>"
                        @bom_html = @bom_html + "<td>"
                        @bom_html = @bom_html + "<a rel='nofollow' data-method='get' data-remote='true' href='/p_update?id="+ params[:id].to_s + "&product_id=" + item.id.to_s + "&bomsuse=bomsuse'><div>#{ActionController::Base.helpers.number_with_precision(item.min_price, precision: 4).to_s}</div></a>"
                        @bom_html = @bom_html + "</td>"
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
            @bom_lab = @bom_lab + "<tr><td>" + t(:category) + "：" 
            unless @counted.nil?
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
                @counted1.each do |key, value| 
                    #<%= link_to "#{key}",  edit_bom_item_path(@bom_item, :package2 =>key, :q =>params[:q], :p =>params[:p]) %>
                    #<a href="/bom_item/8315/edit?p=C6-1%2CC7-1%2CC67-1%2CC68-1&amp;package2=0402&amp;q=CAP+CER+10PF+16V+NP0+0402">0402</a>
                    @bom_lab = @bom_lab + '<a data-remote="true" href="/search_m' + "?id=" + @bom_item.id.to_s + "&amp;p=" + params[:p].to_s + "&amp;package2=" + key.to_s + "&amp;q=" + params[:q].to_s + "&amp;bomsuse=bomsuse" + '">' + key.to_s + "</a>"
                    @bom_lab = @bom_lab + '<span class="badge">' + value.to_s + '</span>'
                end
            end
            @bom_lab = @bom_lab + "</td></tr>"
        else
            @bom_lab = @bom_lab + "<tr><td>" + t(:category) + "： "
            unless @counted.nil? 
                @counted.each do |key, value| 
                    #<%= link_to "#{key}",  edit_bom_item_path(@bom_item, :part_name =>key, :q =>params[:q], :p =>params[:p]) %> 
                    Rails.logger.info("--------------------------")
                    Rails.logger.info(key.inspect)
                    Rails.logger.info(value.inspect)
                    Rails.logger.info("--------------------------")
                    @bom_lab = @bom_lab + '<a data-remote="true" href="/search_m' + "?id=" + @bom_item.id.to_s + "&amp;p=" + params[:p].to_s + "&amp;part_name=" + key.to_s + "&amp;q=" + params[:q].to_s + "&amp;bomsuse=bomsuse" + '">' + key + "</a>" 
                    @bom_lab = @bom_lab + '<span class="badge">' + value.to_s + '</span>'
                end
            end
            @bom_lab = @bom_lab + "</td></tr>"
            @bom_lab = @bom_lab + "<tr><td>" + t(:packaging) + "："
            unless @counted1.nil?
                @counted1.each do |key, value|
                    #<%= link_to "#{key}",  edit_bom_item_path(@bom_item, :package2 =>key, :part_name =>@ptype, :q =>params[:q], :p =>params[:p]) %>
                     @bom_lab = @bom_lab + '<a data-remote="true" href="/search_m' + "?id=" + @bom_item.id.to_s + "&amp;p=" + params[:p].to_s + "&amp;package2=" + key.to_s + "&amp;q=" + params[:q].to_s + "&amp;part_name=" + @ptype + "&amp;bomsuse=bomsuse" + '">' + key.to_s + "</a>"
                    @bom_lab = @bom_lab + '<span class="badge">' + value.to_s + '</span>'
                end
            end
            @bom_lab = @bom_lab + "</td></tr>"
        end
        @bom_lab = @bom_lab + "</tbody></table>"
        Rails.logger.info("--------------------------")
        Rails.logger.info(@bom_html.inspect)
        Rails.logger.info("--------------------------")
    end

    def p_update
        if not params[:product_id].blank?
            del_dn = PDn.find_by_sql("SELECT * FROM p_dns WHERE p_dns.item_id = '#{params[:id]}' AND p_dns.tag IS NULL")
            #del_dn = PDn.find_by(item_id: params[:id], tag: nil)
            if not del_dn.blank?
                #del_dn.delete 
                #del_dn.save
                del_dn.each do |del_a|
                    del_a.destroy 
                end
            end
            part_code = Product.find(params[:product_id]).name
            all_dns = AllDn.where(part_code: part_code).order('date DESC')
            all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{part_code}' AND all_dns.qty >= 100 ORDER BY all_dns.date DESC").first
            if all_dns.blank?
                all_dns = AllDn.find_by_sql("SELECT * FROM all_dns WHERE all_dns.part_code = '#{part_code}' ORDER BY all_dns.date DESC").first
            end
            #all_dns.each do |dns|
            if not all_dns.blank?
                add_dns = PDn.new
                add_dns.item_id = params[:id]
                add_dns.dn = all_dns.dn
                add_dns.dn_long = all_dns.dn_long
                add_dns.date = all_dns.date
                add_dns.part_code = all_dns.part_code
                add_dns.qty = all_dns.qty
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
            PDn.where(item_id: params[:id]).each do |dn|
                @view_dns += '<tr id="' + params[:id].to_s + '_' + dn.id.to_s + '" '
                if dn.color == "b"
                    @view_dns += ' class="bg-info">'
                elsif dn.color == "g" 
                    @view_dns += ' class="bg-success">' 
                else
                    @view_dns += ' >'
                end
                #@view_dns += '<td width="25"><small><a class="glyphicon glyphicon-edit" data-method="get" data-remote="true" href=""></a></small></td>'
                @view_dns += '<td width="25"><small><a type="button" class="glyphicon glyphicon-edit" data-toggle="modal" data-target="#editModal" data-whatever="' + dn.id.to_s + '" data-dn="' + dn.dn.to_s + '" data-dnlong="' + dn.dn_long.to_s + '" data-qty="' + dn.qty.to_s + '" data-cost="' + dn.cost.to_s + '" data-remark="' + dn.remark.to_s + '" data-itemid="' + params[:id].to_s + '" ></small></a></td>'
                @view_dns += '<td width="50"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s + '&bomsuse=bomsuse" ><div>' + dn.date.localtime.strftime('%y-%m').to_s + '</div></a></small></td>'
                
                @view_dns += '<td width="100" title="'+dn.dn_long.to_s+'"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s +  '&bomsuse=bomsuse" ><div>' + dn.dn.to_s + '</div></a></small></td>'
                @view_dns += '<td width="50"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s +  '&bomsuse=bomsuse" ><div>'+dn.qty.to_s+'</div></a></small></td>'
                @view_dns += '<td width="80"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s +  '&bomsuse=bomsuse" ><div>￥'+dn.cost.to_s+'</div></a></small></td>'
                if not dn.info.blank?                
                    @view_dns += '<td width="80"><small><a href="'+dn.info.to_s+'">下载</a></small></td>'
                else
                    @view_dns += '<td width="80"><small></small></td>'
                end 
                @view_dns += '<td><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s +  '&bomsuse=bomsuse" ><div>' + dn.remark.to_s + '</div></a></small></td>'                
                @view_dns += '<td width="30"><small><a class="glyphicon glyphicon-trash" data-method="get" data-remote="true" href="/del_dn?id='+dn.id.to_s+'&item_id='+params[:id].to_s+'"></a></small></td>'
                @view_dns += '</tr>'


                #@view_dns += '<tr id="' + params[:id].to_s + '_' + dn.id.to_s + '" class="">'
                #@view_dns += '<td><small>'+dn.dn.to_s+'</small></td>'
                #@view_dns += '<td><small>$'+dn.cost.to_s+'</small></td>'
                #if not dn.info.blank?                
                 #   @view_dns += '<td><small><a href="'+dn.info.to_s+'">下载</a></small></td>'
                #else
                #    @view_dns += '<td><small></small></td>'
                #end 
                  #  @view_dns += '<td><small>'+dn.remark.to_s+'</small></td>'
                  #  @view_dns += '<td><small><a class="glyphicon glyphicon-remove" data-method="get" data-remote="true" href="/del_dn?id='+dn.id.to_s+'&item_id='+params[:id].to_s+'"></a></small></td>'

                    #@view_dns += '</tr>'
            end
            @view_dns += '</tbody>'
            @view_dns += '</table>'
            Rails.logger.info("----------------------")
            #Rails.logger.info(@view_dns)
            Rails.logger.info("----------------------")
            #@view_dns = "wwwww"
            @bom_item = PItem.find(params[:id]) #取回p_items表bomitem记录，在解析bom是存入，可能没有匹配到product
            @bom = ProcurementBom.find(@bom_item.procurement_bom_id)
            if @bom_item.update_attribute("product_id", params[:product_id])
                if @bom_item.product_id
	            #@bom_item.product = Product.find(@bom_item.product_id)
                    @bom_item.warn = false
                    @bom_item.cost = add_dns.cost
                    @bom_item.dn_id = add_dns.id
                    @bom_item.mark = false
                    @bom_item.manual = true
                    @bom_item.mpn_id = nil
                    #@bom_item.mpn = nil
                    @bom_item.color = "b"
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
                        @total_price_nn = 0.00               
	                unless @matched_items_nn.empty?
                            @bom_api_all = []
		            @matched_items_nn.each do |item|
                                if not item.price.blank?
                                    @total_price_nn += item.price * item.quantity * @bom.qty.to_i 
                                end                      
		            end
                        end
                        render "p_update.js.erb"
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
        dell_dns_color = PDn.where(item_id: params[:id])
        c_color = nil
        dell_dns_color = PDn.where(item_id: params[:id]).update_all "color = '#{c_color}'"
        if not params[:product_name].blank?
            @add_dns = PDn.find(params[:dn_id])
            @add_dns.color = "b"
            @add_dns.save
            @bom_item = PItem.find(params[:id]) #取回p_items表bomitem记录，在解析bom是存入，可能没有匹配到product
            @bom = ProcurementBom.find(@bom_item.procurement_bom_id)
            if @bom_item.update_attribute("product_id", Product.find_by(name: params[:product_name]).id)
                if @bom_item.product_id
	            #@bom_item.product = Product.find(@bom_item.product_id)
                    @bom_item.warn = false
                    @bom_item.cost = @add_dns.cost
                    @bom_item.dn_id = @add_dns.id
                    @bom_item.mark = false
                    @bom_item.manual = true
                    @bom_item.mpn_id = nil
                    #@bom_item.mpn = nil
                    @bom_item.color = "b"
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
                        @matched_items_nn = PItem.where(procurement_bom_id: @bom.id)            
                        @total_price_nn = 0.00               
	                unless @matched_items_nn.empty?
                            @bom_api_all = []
		            @matched_items_nn.each do |item|
                                if not item.cost.blank?
                                    @total_price_nn += item.cost * item.quantity * @bom.qty.to_i 
                                end                      
		            end
                        end
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
            @add_dns.color = "b"
            @add_dns.save
            @bom_item = PItem.find(params[:id]) 
            @bom_item.cost = @add_dns.cost
            @bom_item.dn_id = @add_dns.id
            @bom_item.product_id = 0
            @bom_item.color = "b"
            @bom_item.user_do_change = nil
            @bom_item.save


            @bom = ProcurementBom.find(@bom_item.procurement_bom_id)
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
            render "p_updateii.js.erb"    
        end
    end

    def p_edit
        @bom_item = PItem.find(params[:item_id])
        if not @bom_item.blank?
            if not params[:info].blank?
                p_dn = PDn.new(bn_params)
            else
                p_dn = PDn.new()
            end
            #Rails.logger.info("--------------------------")
            #Rails.logger.info(p_dn.info.current_path.inspect)
            #Rails.logger.info("--------------------------")
            p_dn.item_id = params[:item_id]
            p_dn.cost = params[:cost]
            p_dn.dn = params[:dn]
            if params[:dn_long] == ""
                p_dn.dn_long = AllDn.find_by(dn: params[:dn].strip).dn_long
            else
                p_dn.dn_long = params[:dn_long]
            end
            p_dn.qty = params[:qty]
            p_dn.date = Time.new
            p_dn.remark = params[:remark]
            p_dn.tag = "a"
            p_dn.save
            #Rails.logger.info("--------------------------")
            #Rails.logger.info(p_dn.info.current_path)
            #Rails.logger.info("--------------------------")
        end
        redirect_to :back
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
            dn.remark = params[:dn_remark]
        end
        dn.save
        @itemid = params[:dn_itemid]
        @dnid = params[:dn_id]
        @view_dns = ""
        @view_dns += '<td width="25"><small><a type="button" class="glyphicon glyphicon-edit" data-toggle="modal" data-target="#editModal" data-whatever="' + dn.id.to_s + '" data-dn="' + dn.dn.to_s + '" data-dnlong="' + dn.dn_long.to_s + '" data-qty="' + dn.qty.to_s + '" data-cost="' + dn.cost.to_s + '" data-remark="' + dn.remark.to_s + '" data-itemid="' + params[:dn_itemid].to_s + '" ></small></a></td>'
        @view_dns += '<td width="50"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s + '&bomsuse=bomsuse" ><div>' + dn.date.localtime.strftime('%y-%m').to_s + '</div></a></small></td>'    
        @view_dns += '<td width="100" title="'+dn.dn_long.to_s+'"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s +  '&bomsuse=bomsuse" ><div>' + dn.dn.to_s + '</div></a></small></td>'
        @view_dns += '<td width="50"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s +  '&bomsuse=bomsuse" ><div>'+dn.qty.to_s+'</div></a></small></td>'
        @view_dns += '<td width="80"><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s +  '&bomsuse=bomsuse" ><div>￥'+dn.cost.to_s+'</div></a></small></td>'
        if not dn.info.blank?                
            @view_dns += '<td width="80"><small><a href="'+dn.info.to_s+'">下载</a></small></td>'
        else
            @view_dns += '<td width="80"><small></small></td>'
        end 
        @view_dns += '<td><small><a rel="nofollow" data-method="get" data-remote="true" href="/p_updateii?id='+ params[:id].to_s + '&product_name=' + dn.part_code.to_s + '&dn_id=' + dn.id.to_s +  '&bomsuse=bomsuse" ><div>' + dn.remark.to_s + '</div></a></small></td>'                
        @view_dns += '<td width="30"><small><a class="glyphicon glyphicon-trash" data-method="get" data-remote="true" href="/del_dn?id='+dn.id.to_s+'&item_id='+params[:id].to_s+'"></a></small></td>'
        redirect_to :back
        return false
        #render "p_edit_dn.js.erb"
    end

    def p_up_userdo
        @user_do = params[:user_do]
        @bom_item = PItem.find(params[:id])
        if not @bom_item.blank?
            if @bom_item.user_do != params[:user_do]
                @bom_item.user_do = params[:user_do]
                @bom_item.user_do_change = "c"
                @bom_item.color = nil
                @bom_item.save
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
                    url += '&tips_url=www.fastbom.com/p_viewbom?bom_id='+@bom_item.procurement_bom_id.to_s 
                    resp = Net::HTTP.get_response(URI(url))
                end 
            end
        end  
    end

    def up_check
        check_user_do = PItem.where(procurement_bom_id: params[:bom_id],user_do: params[:user_do],user_do_change: "c")
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
        @dn = PDn.find(params[:id])
        if not @dn.blank?
            @dn.destroy
        end
    end

    def p_excel
        @bom = ProcurementBom.find(params[:bom_id])
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
                    sheet1.column(set_color).width = 20
                    set_color += 1
                end
		@bom.p_items.each_with_index do |item,index|
		    rowNum = index+1
                    title_format = Spreadsheet::Format.new({
                    :text_wrap => 1
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
                        row.push(info)
                    end
		    #row.push(rowNum)
		    #row.push(item.description)
		    #row.push(item.quantity)
                    if item.product_id != 0 and item.product_id != nil
                        row.push(Product.find(item.product_id).name)
                        row.push(Product.find(item.product_id).description)
                    else
                        row.push("")
                        row.push("")
                    end
                    row.push("￥#{item.cost}")
                    row.push("￥#{item.price}")
                    if item.dn_id.blank?
                        row.push("")
                    else
                        if PDn.find(item.dn_id).remark.blank?
                            row.push("")
                        else
                            row.push(PDn.find(item.dn_id).remark)
                        end
                    end
                    Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                    Rails.logger.info(item.all_info.inspect)
                    Rails.logger.info(item.all_info.split("|",-1).inspect)
                    Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                    if not item.dn_id.blank?
                        Rails.logger.info("111111111111111")
                        Rails.logger.info(request.protocol)
                        Rails.logger.info(request.host_with_port)
                        Rails.logger.info(PDn.find(item.dn_id).info_url.inspect)
                        Rails.logger.info("111111111111111")
                        if not PDn.find(item.dn_id).info_url.blank?
                            #row.push(request.protocol + request.host_with_port + PDn.find(item.dn_id).info_url)
                            row.push(Spreadsheet::Link.new request.protocol + request.host_with_port + PDn.find(item.dn_id).info_url, '技术资料')
                        else
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
                t_p += item.cost*item.quantity
                item.price = item.cost*(100+params[:profit].to_i)/100
                t_pp += item.price*item.quantity
                item.save
            end
        end
        bom.t_p = t_p*bom.qty
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
            @p_item.cost = nil 
            @p_item.price = nil
            @p_item.color = nil
            @p_item.save
        end 
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
    end

    def p_edit_mpn
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
        #redirect_to :back
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

        def bn_params
  	    params.require(:info).permit(:name, :info)
  	end

        def editbn_params
  	    params.require(:dn_info).permit(:info)
  	end

        def search_bom_use (query_str)
            if not query_str.blank?
                result = PItem.find_by_sql("SELECT * FROM p_items WHERE p_items.description LIKE '%" + query_str.to_s.strip + "%' AND p_items.dn_id IS NOT NULL ORDER BY p_items.created_at DESC").first
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
                if query_str.include?"e"
                    query_str = query_str.gsub("e","r")
                end
                if query_str.include?"E"
                    query_str = query_str.gsub("E","r")
                end
                #ary_all = query_str.to_s.scan(/([0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                
                ary_all = query_str.to_s.scan(/[0-9]\.?[0-9]*[mMkKuUrRΩ][0-9]\.?[0-9]*/)
                if not ary_all.blank?
                    value2 = ary_all.join("").scan(/[mMkKuUrRΩ]/)
                end
                ary_all = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                #获取阻值
                ary_q = []
                value2_test = query_str.to_s.scan(/[0-9]*[mMkKuUrRΩ][0-9]/)
                Rails.logger.info("value2_test!!!!!!!!!!!!!!!!!!!!!!!!!!!value2_test")
                Rails.logger.info(query_str.inspect)
                Rails.logger.info(value2_test.inspect)
                Rails.logger.info("value2_test!!!!!!!!!!!!!!!!!!!!!!!!!!!value2_test")
                value2_use = "nothing"
                if value2_test != []
                    value2_use = value2_test[0].to_s.sub(/[mMkKuUrRΩ]/, ".") + value2_test[0].to_s.scan(/[mMkKuUrRΩ]/)[0]
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
                        end
                        #value2 = query_str.to_s.scan(/-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)*[mMkKuUrR]|-?[1-9]\d*[mMkKuUrR]/)
                        
                    end
                end
                if value2_use != "nothing"
                    #获取电压
                    value3_all = ary_all.join(" ").split(" ").grep(/[vV]/)
                    value3 = "nothing"
                    if value3_all != []
                        value3 = value3_all[0]
                    end
                    ary_q[0] = value2_use
                    ary_q[1] = value3
                    #获取封装
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
                package2_all = Product.find_by_sql("SELECT products.package2, products.ptype FROM products WHERE products.ptype = 'RES' GROUP BY products.package2")
                value4_all = package2_all.select { |item| ary_all.join(" ").include?item.package2 }
                if not value4_all.blank?

                    Rails.logger.info("__________0000000000000000000000000000000000000bbbbb___________________________")
                    #Rails.logger.info(value4_all.first.package2)
                    Rails.logger.info("_________0000000000000000000000000000000000000bbbbb_______________________________") 
                    ary_q[2] = value4_all.first.package2
                else
                    ary_q[2] = "nothing"
                end
                #获取阻值
                value2_test = query_str.to_s.scan(/[0-9]+[mMkKuUrRΩ][0-9]/)
                Rails.logger.info("value2_test!!!!!!!!!!!!!!!!!!!!!!!!!!!value2_test")
                Rails.logger.info(query_str.inspect)
                Rails.logger.info(value2_test.inspect)
                Rails.logger.info("value2_test!!!!!!!!!!!!!!!!!!!!!!!!!!!value2_test")
                value2_use = "nothing"
                if value2_test != []
                    value2_use = value2_test[0].to_s.sub(/[mMkKuUrRΩ]/, ".") + value2_test[0].to_s.scan(/[mMkKuUrRΩ]/)[0]
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
