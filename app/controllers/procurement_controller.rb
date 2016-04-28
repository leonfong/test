require 'roo'
require 'spreadsheet'
require 'will_paginate/array'
class ProcurementController < ApplicationController
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
            @bom.save    
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
            all_item = []
            @sheet.row(1).each do |item|
                if not item.blank?
                    all_item << '"'+item+'":'+'"'+item+'"'
                end
            end
            all_item = "{"+all_item.join(",")+"}"
            Rails.logger.info("------------------------------------------------------------qq1")
            Rails.logger.info(all_item.inspect)
            Rails.logger.info("------------------------------------------------------------qq2")
            #@parse_result = @sheet.parse(:Qty => "Qty",clean:true)
	    @parse_result = @sheet.parse(JSON.parse(all_item))  
	    #remove first row 
	    @parse_result.shift
            #render "select_column.html.erb" 
            #return false  
            all_use = @sheet.row(1)[params[:partCol].to_i].split("")+@sheet.row(1)[params[:quantityCol].to_i].split("")+@sheet.row(1)[params[:refdesCol].to_i].split("")
            #params[:select_part].each do |use|
	     #@parse_result.select! {|item| !item["#{@sheet.row(1)[params[:partCol].to_i]}"].blank? } #选择非空行
            #end
            Rails.logger.info("------------------------------------------------------------qq1")
            Rails.logger.info(all_item.inspect)
            Rails.logger.info("------------------------------------------------------------qq2")
            Rails.logger.info(@parse_result.inspect)
            Rails.logger.info(@sheet.row(1)[params[:partCol].to_i].inspect)
            Rails.logger.info("------------------------------------------------------------qq3")
            #行号
            row_num = 0
           # all_m_bom = []
            #one_m_bom = []
            #other_all = @sheet.row(1)-@sheet.row(1)[params[:partCol].to_i].split("")-@sheet.row(1)[params[:quantityCol].to_i].split("")-@sheet.row(1)[params[:refdesCol].to_i].split("")
            other_all = @sheet.row(1)
            other_all.delete(@sheet.row(1)[params[:partCol].to_i])
            other_all.delete(@sheet.row(1)[params[:quantityCol].to_i])
            other_all.delete(@sheet.row(1)[params[:refdesCol].to_i])
            params[:desCol].strip.split(" ").each do |des|
                other_all.delete(@sheet.row(1)[des.to_i])
            end
            Rails.logger.info("------------------------------------------------------------aaaa")
            Rails.logger.info(other_all.inspect)
            Rails.logger.info(params[:desCol].strip.split(" ").inspect)
            Rails.logger.info("------------------------------------------------------------aaaa")
	    @parse_result.each do |item| #处理每一行的数据 
                mpna = ""
                if item["#{@sheet.row(1)[params[:partCol].to_i]}"].blank?
                    mpna += ""
                else
                    mpna += item["#{@sheet.row(1)[params[:partCol].to_i]}"].to_s + " " 
                end
                qtya = ""
                if item["#{@sheet.row(1)[params[:quantityCol].to_i]}"].blank?
                    qtya += ""
                else
                    qtya += item["#{@sheet.row(1)[params[:quantityCol].to_i]}"].to_s + " "             
                end
                refa = ""
                if item["#{@sheet.row(1)[params[:refdesCol].to_i]}"].blank?
                    refa += ""
                else
                    refa += item["#{@sheet.row(1)[params[:refdesCol].to_i]}"].to_s + " "
                end
                fengzhuang = ""
                if item["#{@sheet.row(1)[params[:packageCol].to_i]}"].blank?
                    fengzhuang += ""
                else
                    fengzhuang += item["#{@sheet.row(1)[params[:packageCol].to_i]}"].to_s + " "
                end
                link = ""
                if item["#{@sheet.row(1)[params[:linkCol].to_i]}"].blank?
                    link += ""
                else
                    link += item["#{@sheet.row(1)[params[:linkCol].to_i]}"].to_s + " "
                end
                desa = ""
                params[:desCol].strip.split(" ").each do |des|                    
                    if item["#{@sheet.row(1)[des.to_i]}"].blank?
                        desa += ""
                    else
                        desa += item["#{@sheet.row(1)[des.to_i]}"].to_s + " "
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
	        
		Rails.logger.info("------------------------------------------------------------des")
                Rails.logger.info(mpna.inspect)
                Rails.logger.info(qtya.inspect)
                Rails.logger.info(refa.inspect)
                Rails.logger.info(desa.inspect)
                Rails.logger.info(othera.inspect)
                Rails.logger.info("------------------------------------------------------------des")
                find_mpn = PItem.where(procurement_bom_id: params[:bom_id],mpn: mpna)
                if find_mpn.blank?
                    bom_item = @bom.p_items.build() #创建bom_items对象
                    bom_item.part_code = refa
		    bom_item.description = desa
                    bom_item.quantity = qtya.to_i
                    bom_item.mpn = mpna
                    bom_item.fengzhuang = fengzhuang
                    bom_item.link = link
                    bom_item.other = othera
                    bom_item.user_id = current_user.id
                    bom_item.save
                end
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
        @bom.no = "MB" + Time.new.strftime('%Y').to_s[-1] + Time.new.strftime('%m%d').to_s + "B" + Bom.find_by_sql('SELECT Count(boms.id)+1 AS all_no FROM boms WHERE to_days(boms.created_at) = to_days(NOW())').first.all_no.to_s + "B"
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
            end 
            @bom = ProcurementBom.find(params[:bom_id])      
            if not @bom.qty.blank?
                @total_p = 0   
                all_c = 0           
                @bom_item.each do |bomitem|
                    api_info = find_price(bomitem.mpn_id,@bom.qty)
                    if not api_info.blank?  
                       bomitem.price = api_info[0]
                       bomitem.mf = api_info[1]
                       bomitem.dn = api_info[2]
                       bomitem.save
                       if not bomitem.price.blank?
                           @total_p += bomitem.price*bomitem.quantity
                       end
                    end
                    all_c += bomitem.quantity
                end
                @total_p = @total_p*@bom.qty.to_i
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
        @boms = ProcurementBom.find(params[:bom_id])
        @bom_item = PItem.where(procurement_bom_id: params[:bom_id])
        if  params[:ajax]
            @bomitem = BomItem.find_by_sql("SELECT id,mpn,part_code,quantity,price,(price*quantity) AS total,mf,dn FROM bom_items WHERE bom_items.id = '#{params[:ajax]}'").first
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
        @boms = ProcurementBom.find_by_sql("SELECT * FROM `procurement_boms` WHERE `user_id` = '" + current_user.id.to_s + "' AND `name` IS NULL ORDER BY `id` DESC ").paginate(:page => params[:page], :per_page => 10)
    end











    private
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







end
