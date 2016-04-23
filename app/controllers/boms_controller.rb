require 'roo'
require 'spreadsheet'
require 'will_paginate/array'
class BomsController < ApplicationController
skip_before_action :verify_authenticity_token
before_filter :authenticate_user!, :except => [:root,:upload,:mpn_item,:search_keyword,:des_item]
    def index
        #@boms = Bom.all
        if current_user.email == "web@mokotechnology.com"
            @boms = Bom.find_by_sql("SELECT boms.* FROM `boms` ORDER BY `id` DESC LIMIT 35" )
        else
            @boms = Bom.find_by_sql("SELECT * FROM `boms` WHERE `user_id` = '" + current_user.id.to_s + "' AND `name` IS NULL ORDER BY `id` DESC LIMIT 35")
        end
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        Rails.logger.info(@boms.inspect)
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
    end
    
    def down_excel

        #path = params[:path]
        #path = "/var/www/fastbom/public"+params[:path]
        #filename = params[:filename]
        #Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        #Rails.logger.info(path.inspect)
        #Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        #response.headers['X-Accel-Redirect'] = "/public/" + path
        #render :nothing => true

            #if Rails.env = 'production'
                #return head(
                    #'X-Accel-Redirect' => "/public#{path}",
                    #'Content-Type' => "application/excel",
                    #'Content-Disposition' => "attachment; filename=\"#{filename}\""
            #)
            #else
                #send_file(path, filename: filename, type: "application/vnd.ms-excel")
                #send_file("/var/www/fastbom/public"+path)
            #end
        

        @bom = Bom.find(params[:id])
        file_name = @bom.excel_file.to_s.scan(/[^\/]+$/).join('').split(".xls")[0]+".xls"
        path = Rails.root.to_s+"/public/uploads/bom/excel_file/"
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        Rails.logger.info(file_name.inspect)
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        respond_to do |format|
	    format.xls { 
                Spreadsheet.client_encoding = 'UTF-8'
		ff = Spreadsheet::Workbook.new

		sheet1 = ff.create_worksheet

		sheet1.row(0).concat %w{No Des Location_code quantity Mpn}

		@bom.bom_items.each_with_index do |item,index|
		    rowNum = index+1
                    title_format = Spreadsheet::Format.new({
                    :weight           => :bold,
                    :pattern_bg_color => :red,
                    :size             => 10,
                    :color => :red
                    })
		    row = sheet1.row(rowNum)
                    if item.warn
                        #[0,1,2,3,4,5,6,7].each{|col|
                        row.set_format(2,title_format)
                        #row.default_format = color
                        #}
                    end
		    row.push(rowNum)
		    row.push(item.description)
		    row.push(item.part_code)
		    row.push(item.quantity)
                    row.push(item.mpn)		 
                end

                #file_contents = StringIO.new
	        #ff.write (file_contents)
	        #send_data(file_contents.string.force_encoding('UTF-8'), filename: file_name)
                              
                ff.write (path+file_name)              
                send_file(path+file_name, type: "application/vnd.ms-excel")
                #send_file(path,filename: file_name, type: "application/vnd.ms-excel")
            }
        end

    end   
 

    def search_keyword
        Rails.logger.info("params[:locale]------------------------------------------------------params[:locale]")
        Rails.logger.info(cookies.permanent[:educator_locale].to_s)
        Rails.logger.info("params[:locale]--------------------------------------------------------params[:locale]")
        if cookies.permanent[:educator_locale].to_s == "zh"
            part_name_locale = "part_name"
        elsif cookies.permanent[:educator_locale].to_s == "en"
            part_name_locale = "part_name_en"
        end
        @bom = Bom.new
        #@mpn_show = MpnItem.find_by_sql("SELECT * FROM `mpn_items` LIMIT 0, 30")
        if not params[:mpn] == ""
            key_up = Keywords.new
            key_up.keywords = params[:mpn].strip
            key_up.save
            if params[:mpn].strip.split(" ").length == 1
                #mpn_item = MpnItem.find_by_sql("SELECT * FROM `mpn_items` WHERE `mpn` LIKE '%"+params[:mpn]+"%'").first
                #Rails.logger.info("mpn_item--------------------------------------------------------------------------mpn_item")
                #Rails.logger.info(mpn_item.inspect)   
                #Rails.logger.info("mpn_item--------------------------------------------------------------------------mpn_item") 
                #if mpn_item.blank?
                #end
                @mpn_item = search_findchips(params[:mpn])
                Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                #Rails.logger.info(@mpn_item.inspect)
                Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                if @mpn_item == []
                    if params[:part_name].nil? and params[:package2].nil?
	                @ptype = ""
		        @package2 = ""
                        find_bom = ""
	            elsif params[:package2].nil?
		        @ptype = params[:part_name]
                        #@ptype = ""
	                @package2 = ""
                        find_bom = " AND `" + part_name_locale + "` LIKE '%"+@ptype+"%' "
	            elsif params[:part_name].nil?
	                @ptype = ""
	                @package2 = params[:package2]
                        find_bom = " AND `package2` = '"+@package2+"' "
	            else
	                @ptype = params[:part_name]
                        #@ptype = ""
	                @package2 = params[:package2]
                        find_bom = " AND `" + part_name_locale + "` LIKE '%"+@ptype+"%' AND `package2` = '"+@package2+"' "
	            end

                    
                    keywords = params[:mpn].strip.split(" ")
                    key_where = " products.description LIKE '%%'"
                    keywords.each do |k|
                    key_where = key_where + " AND products.description LIKE '%" + k.to_s + "%'"
                    end
                    @key_item = Product.find_by_sql("SELECT * FROM products WHERE" + key_where + find_bom).to_ary
                    @counted = Hash.new(0)
                    @key_item.each { |h| @counted[h[part_name_locale]] += 1 }
                    @counted = Hash[@counted.map {|k,v| [k,v.to_s] }]	
				
	            @counted1 = Hash.new(0)
                    @key_item.each { |h| @counted1[h["package2"]] += 1 }
                    @counted1 = Hash[@counted1.map {|k,v| [k,v.to_s] }]	
                    if @key_item == []
                        flash.now[:error] = "I'm sorry, not found your chip information query."
                    end
                    Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                    #Rails.logger.info(@key_item.inspect)
                    Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                else
                    prices_all = []
                    naive_id_all = []
                    part_all = []
                    @mpn_item.each do |result|
                        result['parts'].each do |part|
                            part['price'].each do |f|     
                                if f.has_value?"USD"
                                    prices_all << f['price'].to_f
                                    naive_id_all << result['distributor']['id'] 
                                    part_all << part['part']                                    
                                end
                            end
                        end
                    end
                    Rails.logger.info("prices_all--------------------------------------------------------------------------")
                    Rails.logger.info(prices_all.inspect)   
                    Rails.logger.info("prices_all--------------------------------------------------------------------------") 
                    Rails.logger.info(naive_id_all.inspect)   
                    Rails.logger.info("naive_id_all--------------------------------------------------------------------------") 
                    Rails.logger.info(part_all.inspect)   
                    Rails.logger.info("part_all--------------------------------------------------------------------------")      
                    @price_result = []
                    if not prices_all == []
                        mpn_new = MpnItem.new
                        naive_id= naive_id_all[(prices_all.index prices_all.min)]
                        naive_part= part_all[(prices_all.index prices_all.min)]
                        mpn_item = MpnItem.find_by_sql("SELECT * FROM `mpn_items` WHERE `mpn` = '"+naive_part+"'").first
                        Rails.logger.info("mpn_item---------------------------------------------------------------mpn_item")
                        Rails.logger.info(mpn_item.inspect)   
                        Rails.logger.info("mpn_item------------------------------------------------------------mpn_item") 
                        if mpn_item.blank?
                            @mpn_item.each do |result|
                                if result['distributor']['id'] == naive_id
                                    Rails.logger.info("naive_id-----------------") 
                                    Rails.logger.info(naive_id.inspect)   
                                    Rails.logger.info("naive_id--------------------")      
                                    result['parts'].each do |part|
                                        if part['part'] == naive_part
                                            @price_result << part['part']
                                            @price_result << part['manufacturer']
                                            @price_result << result['distributor']['name']
                                            @price_result << part['description']
                                            @price_result << prices_all.min
                                            @price_result << "http://www.alldatasheet.com/view.jsp?Searchword=" + part['part'].to_s
                                            mpn_new.mpn = part['part']
                                            mpn_new.manufacturer = part['manufacturer']
                                            mpn_new.authorized_distributor = result['distributor']['name']
                                            mpn_new.description = part['description']
                                            mpn_new.price = prices_all.min
                                            mpn_new.datasheets = "http://www.alldatasheet.com/view.jsp?Searchword=" + part['part'].to_s
                                        end                            
                                    end
                                end
                            end
                            mpn_new.save
                            @price_result << mpn_new.id 
                        else
                            @price_result = []
                            @price_result << mpn_item['mpn']
                            @price_result << mpn_item['manufacturer'] 
                            @price_result << mpn_item['authorized_distributor']
                            @price_result << mpn_item['description']
                            @price_result << mpn_item['price']
                            @price_result << mpn_item['datasheets']
                            @price_result << mpn_item['id'] 
                        end    
                    end
                end
            else
                if params[:part_name].nil? and params[:package2].nil?
	            @ptype = ""
		    @package2 = ""
                    find_bom = ""
	        elsif params[:package2].nil?
		    @ptype = params[:part_name]
                    #@ptype = ""
	            @package2 = ""
                    find_bom = " AND `" + part_name_locale + "` LIKE '%"+@ptype+"%' "
	        elsif params[:part_name].nil?
	            @ptype = ""
	            @package2 = params[:package2]
                    find_bom = " AND `package2` = '"+@package2+"' "
	        else
	            @ptype = params[:part_name]
                    #@ptype = ""
	            @package2 = params[:package2]
                    find_bom = " AND `" + part_name_locale + "` LIKE '%"+@ptype+"%' AND `package2` = '"+@package2+"' "
	        end
                keywords = params[:mpn].strip.split(" ")
                key_where = " products.description LIKE '%%'"
                keywords.each do |k|
                    key_where = key_where + " AND products.description LIKE '%" + k.to_s + "%'"
                end
                @key_item = Product.find_by_sql("SELECT * FROM products WHERE" + key_where + find_bom).to_ary
                #@key_item = Product.find_by_sql("SELECT * FROM products WHERE" + key_where).to_ary
                @counted = Hash.new(0)
                @key_item.each { |h| @counted[h[part_name_locale]] += 1 }
                @counted = Hash[@counted.map {|k,v| [k,v.to_s] }]	
				
	        @counted1 = Hash.new(0)
                @key_item.each { |h| @counted1[h["package2"]] += 1 }
                @counted1 = Hash[@counted1.map {|k,v| [k,v.to_s] }]	
                if @key_item == []
                    flash.now[:error] = "I'm sorry, not found your chip information query."
                end
            end
        else
            flash.now[:error] = "Please enter the Keywords/Part Number"
        end
    end

    

    def search
        if !params[:q].nil? 
      	    str = params[:q]
            part_code = params[:p]

            #str = get_query_str(str)
     
            ary2 = part_code.upcase.to_s.scan(/[A-Z]+/)
            part_code = ary2[0]
            str = get_query_str_new(str,part_code)
            part = Part.find_by(part_code: part_code)

            if part
            #result =Product.search(str,conditions: {part_name: part.part_name},star: true,order: 'prefer DESC').to_ary
                if part.part_name == "SW"
                    sql_a = "SELECT * FROM `products` WHERE `description` LIKE '%"+str.split(" ")[0]+"%'"
                    #sql_b = " ORDER BY `prefer` DESC"
                    sql_b = ""
                else
                    if str.split(" ")[0] == "0R" or str.split(" ")[0] == "0r" or str.split(" ")[0] == "0o" or str.split(" ")[0] == "0O"
                        sql_a = "SELECT * FROM `products` WHERE `value2` = '"+str.split(" ")[0]+"'"
                    else
                        sql_a = "SELECT * FROM `products` WHERE `value2` LIKE '%"+str.split(" ")[0]+"%'" 
                    end
                    #sql_b = " ORDER BY `prefer` DESC" 
                    sql_b = ""
                end
                if not str.split(" ")[2].blank?
                    find_bom = " AND `package2` = '"+str.split(" ")[2]+"' "
                else
                    find_bom = ""
                end
                if str.split(" ")[1].blank?
                    result_w = Product.find_by_sql(sql_a+" AND `ptype` = '"+part.part_name+"' "+find_bom+sql_b).to_ary
                    if result_w.blank?
                        result = Product.find_by_sql(sql_a+" AND `ptype` = '"+part.part_name+"'"+sql_b).to_ary
                    else
                        result = result_w 
                    end
                else
                    result_w = Product.find_by_sql(sql_a+" AND `value3` = '"+str.split(" ")[1]+"' AND `ptype` = '"+part.part_name+"' "+find_bom+sql_b).to_ary
                    if result_w.blank?
                        result_w = Product.find_by_sql(sql_a+" AND `value3` = '"+str.split(" ")[1]+"' AND `ptype` = '"+part.part_name+"'"+  sql_b).to_ary
                        if result_w.blank?
                            if (part_code[0] =~ /[Cc]/ and str.split(" ")[0]=~ /[^uU]/)
                                result_w = Product.find_by_sql(sql_a+" AND `value3` = '50v' AND `ptype` = '"+part.part_name+"' "+find_bom+sql_b).to_ary
                                if result_w.blank?
                                    result = Product.find_by_sql(sql_a+" AND `value3` = '50v' AND `ptype` = '"+part.part_name+"'"+sql_b).to_ary    
                                else
                                    result = result_w 
                                end
                            else
                                result_w = Product.find_by_sql(sql_a+" AND `ptype` = '"+part.part_name+"' "+find_bom+sql_b).to_ary
                                if result_w.blank?
                                    result = Product.find_by_sql(sql_a+" AND `ptype` = '"+part.part_name+"'"+sql_b).to_ary
                                else
                                    result = result_w
                                end 
                            end
                        else
                            result = result_w 
                        end
                    else
                        result = result_w     
                    end
                end
	    else
            #result =Product.search(str,star: true,order: 'prefer DESC').to_ary
                #result = Product.find_by_sql(sql_a+str.split(" ")[0]+"%'"+sql_b).to_ary
                #result = Product.find_by_sql("SELECT * FROM `products` WHERE `description` LIKE '%"+str.split(" ")[0]+"%' ORDER BY `prefer` DESC").to_ary
                result = Product.find_by_sql("SELECT * FROM `products` WHERE `description` LIKE '%"+str.split(" ")[0]+"%' ").to_ary
        	@query_str = str +" without part_name "
            end
        end
    end

    def new
        @bom = Bom.new
    end

    def show
        if not params[:bom_data].blank?
            if not params[:bom_data][1..-2][1..-2].blank?
                @all_bom_data = params[:bom_data][1..-2][1..-2].split("],[")
                Rails.logger.info("@all_bom_data-----------------------------------------------------@all_bom_data")
                Rails.logger.info(@all_bom_data)
                Rails.logger.info("@all_bom_data---------------------------------------------------@all_bom_data")           
            end
        end
        @bom = Bom.find(params[:id])
        Rails.logger.info("aaaaaaaaaaaaaaaaaaaaaaaaaaaa")
        Rails.logger.info(@bom.inspect)
        Rails.logger.info("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
        #file_name = @bom.excel_file.to_s.scan(/[^\/]+\.xls$/).join('')
        file_name = @bom.excel_file.to_s.scan(/[^\/]+$/).join('').split(".xls")[0]+".xls"
        path = Rails.root.to_s+"/public/uploads/bom/excel_file/"

        respond_to do |format|

            format.html {
                Rails.logger.info("cccccccccccccccccccccccccccccccccccccccccccccccccccc11111q")
                #Rails.logger.info(Product.find(@bom.bom_items.first.product_id).inspect)
                Rails.logger.info("cccccccccccccccccccccccccccccccccccccccccccccccc1111111q")
                #matched_items = @bom.bom_items.select { |item| item.product }
                #matched_items = @bom.bom_items.select { |item| return Product.find(item.product_id) unless item.product_id.blank?}
                @matched_items = Product.find_by_sql("
SELECT
	bom_items.id,
	bom_items.quantity,
	bom_items.description,
	bom_items.part_code,
	bom_items.bom_id,
	bom_items.product_id,
	bom_items.created_at,
	bom_items.updated_at,
	bom_items.warn,
	bom_items.user_id,
	bom_items.danger,
	bom_items.manual,
	bom_items.mark,
	bom_items.mpn,
	bom_items.mpn_id,

IF (
	bom_items.mpn_id > 0,
	mpn_items.price,
	products.price
) AS price,

IF (
	bom_items.mpn_id > 0,
	mpn_items.description,
	products.description
) AS description_p
FROM
	bom_items
LEFT JOIN products ON bom_items.product_id = products.id
LEFT JOIN mpn_items ON bom_items.mpn_id = mpn_items.id
WHERE
	bom_items.bom_id = "+params[:id])
                #@bom.bom_items.each do |item|
                    #unless item.product_id.blank?
                        #matched_items << Product.find(item.product_id)
                    #end   
                #end
                #begin
                #    matched_items = @bom.bom_items.select { |item| Product.find(item.product_id).blank? }
                #rescue
                   # matched_items = []
                #end

                Rails.logger.info("cccccccccccccccccccccccccccccccccccccccccccccccccccc111111")
                
                Rails.logger.info("cccccccccccccccccccccccccccccccccccccccccccccccccccc22222")
                Rails.logger.info("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb")
                Rails.logger.info(@matched_items)
                Rails.logger.info("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb22222222222222222222")
		@match_str = "#{@bom.bom_items.count('product_id')+@bom.bom_items.count('mpn_id')} / #{@bom.bom_items.count}"
		@total_price = 0.00
                #Rails.logger.info(matched_items.inspect)
                Rails.logger.info(@match_str.inspect)
                Rails.logger.info(@total_price.inspect)
                Rails.logger.info("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb22222222222222222")
		unless @matched_items.empty?
                    @bom_api_all = []
		    @matched_items.each do |item|
                        if not item.price.blank?
                            @total_price += item.price * item.quantity  
                        end
                        #if item.product_id.blank?
                            #if not item.mpn.blank?
                                #bom_api = search_in_api(item.mpn)
                                #if not bom_api == []
                                    #bom_api << item.id
                                    #@bom_api_all << bom_api
                                #end
                            #end    
                        #end 
		    end
                    Rails.logger.info("@bom_api_all_________________________________________________________")
                    Rails.logger.info(@bom_api_all.inspect)
                    Rails.logger.info("@bom_api_all---------------------------------------------------------")
		end
		    }
            
	    format.xls { 
                Spreadsheet.client_encoding = 'UTF-8'
		ff = Spreadsheet::Workbook.new

		sheet1 = ff.create_worksheet

		sheet1.row(0).concat %w{No Intention_product Location_code Matching_products Material_code unit_price quantity total_price}

		@bom.bom_items.each_with_index do |item,index|
		    rowNum = index+1
                    title_format = Spreadsheet::Format.new({
                    :weight           => :bold,
                    :pattern_bg_color => :red,
                    :size             => 10,
                    :color => :red
                    })
		    row = sheet1.row(rowNum)
                    if item.warn
                        #[0,1,2,3,4,5,6,7].each{|col|
                        row.set_format(2,title_format)
                        #row.default_format = color
                        #}
                    end
		    row.push(rowNum)
		    row.push(item.description)
		    row.push(item.part_code)
		    row.push(item.product_id.nil?? "" : Product.find(item.product_id).description)
		    row.push(item.product_id.nil?? "" : Product.find(item.product_id).name)
		    row.push(item.product_id.nil?? "" : Product.find(item.product_id).price)
		    row.push(item.quantity)
		    row.push(item.product_id.nil?? "" : Product.find(item.product_id).price*item.quantity)
                end
                
                ff.write (path+file_name)              
                if Rails.env = 'production'
                    #return head(
                       # 'X-Accel-Redirect' => "#{path}",
                        #'Content-Type' => "application/excel",
                       # 'Content-Disposition' => "attachment; filename=\"#{file_name}\""
                     #)
                    redirect_to "/uploads/bom/excel_file/"+file_name
                else
                    send_file(path+file_name, type: "application/vnd.ms-excel")
                end
                #file_contents = StringIO.new
	        #ff.write (file_contents)
	        #send_data(file_contents.string.force_encoding('binary'), filename: file_name)
            }
        end

    end

    def show_excel
        if not params[:bom_data].blank?
            if not params[:bom_data][1..-2][1..-2].blank?
                @all_bom_data = params[:bom_data][1..-2][1..-2].split("],[")
                Rails.logger.info("@all_bom_data-----------------------------------------------------@all_bom_data")
                Rails.logger.info(@all_bom_data)
                Rails.logger.info("@all_bom_data---------------------------------------------------@all_bom_data")           
            end
        end
        @bom = Bom.find(params[:id])
        Rails.logger.info("aaaaaaaaaaaaaaaaaaaaaaaaaaaa")
        Rails.logger.info(@bom.inspect)
        Rails.logger.info("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
        #file_name = @bom.excel_file.to_s.scan(/[^\/]+\.xls$/).join('')
        file_name = @bom.excel_file.to_s.scan(/[^\/]+$/).join('').split(".xls")[0]+".xls"
        path = Rails.root.to_s+"/public/uploads/bom/excel_file/"

        
                Spreadsheet.client_encoding = 'UTF-8'
		ff = Spreadsheet::Workbook.new

		sheet1 = ff.create_worksheet

		sheet1.row(0).concat %w{No Intention_product Location_code Matching_products Material_code unit_price quantity total_price}

		@bom.bom_items.each_with_index do |item,index|
		    rowNum = index+1
                    title_format = Spreadsheet::Format.new({
                    :weight           => :bold,
                    :pattern_bg_color => :red,
                    :size             => 10,
                    :color => :red
                    })
		    row = sheet1.row(rowNum)
                    if item.warn
                        #[0,1,2,3,4,5,6,7].each{|col|
                        row.set_format(2,title_format)
                        #row.default_format = color
                        #}
                    end
		    row.push(rowNum)
		    row.push(item.description)
		    row.push(item.part_code)
		    row.push(item.product_id.nil?? "" : Product.find(item.product_id).description)
		    row.push(item.product_id.nil?? "" : Product.find(item.product_id).name)
		    row.push(item.product_id.nil?? "" : Product.find(item.product_id).price)
		    row.push(item.quantity)
		    row.push(item.product_id.nil?? "" : Product.find(item.product_id).price*item.quantity)
                end
                
                ff.write (path+file_name)              
                if Rails.env = 'production'
                    #return head(
                       # 'X-Accel-Redirect' => "#{path}",
                        #'Content-Type' => "application/excel",
                       # 'Content-Disposition' => "attachment; filename=\"#{file_name}\""
                     #)
                    redirect_to "/uploads/bom/excel_file/"+file_name
                else
                    send_file(path+file_name, type: "application/vnd.ms-excel")
                end
    end

    def upbom        
        if params[:bom_id] and params[:bak_bom].blank?
            old_bom = BomItem.where(bom_id: params[:bom_id]) 
            old_bom.each do |old_item|
                old_item.destroy
            end
            @bom = Bom.find(params[:bom_id]) 
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
            #Rails.logger.info("------------------------------------------------------------3")
            #Rails.logger.info(params[:select_refDes].inspect)
            #Rails.logger.info("------------------------------------------------------------3")
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
	     @parse_result.select! {|item| !item["#{@sheet.row(1)[params[:partCol].to_i]}"].blank? } #选择非空行
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
            other_all = @sheet.row(1)-@sheet.row(1)[params[:partCol].to_i].split("")-@sheet.row(1)[params[:quantityCol].to_i].split("")-@sheet.row(1)[params[:refdesCol].to_i].split("")
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
                #desa = ""
                #params[:select_description].each do |des|                    
                    #if item["#{des}"].blank?
                        #desa += ""
                    #else
                        #desa += item["#{des}"].to_s + " "
                    #end
                #end
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
                #Rails.logger.info(desa.inspect)
                Rails.logger.info(othera.inspect)
                Rails.logger.info("------------------------------------------------------------des")
                find_mpn = BomItem.where(bom_id: params[:bom_id],mpn: mpna)
                if find_mpn.blank?
                    bom_item = @bom.bom_items.build() #创建bom_items对象
                    bom_item.part_code = refa
		    #bom_item.description = desa
                    bom_item.quantity = qtya.to_i
                    bom_item.mpn = mpna
                    bom_item.other = othera
                    bom_item.user_id = current_user.id
                    bom_item.save
                end
            end
            
            #render "select_column.html.erb" 
            #redirect_to search_part_path(:bom_id => params[:bom_id])
            #return false
            @bom_item = BomItem.where(bom_id: params[:bom_id])
            render "search_part.html.erb"
            return false
        end
                
        if not params[:bak_bom].blank? 
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
        end

        @bom = Bom.new(bom_params)#使用页面传进来的文件名字作为参数创建一个bom对象
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
            redirect_to select_column_path(bom: @bom)  
            return false
        end 
    end

    def select_column
        @sheet = params[:sheet]
        @bom = Bom.find(params[:bom])
        if @bom.excel_file_identifier.split('.')[-1] == 'xls'
	    @xls_file = Roo::Excel.new(@bom.excel_file.current_path)
        else
            @xls_file = Roo::Excelx.new(@bom.excel_file.current_path)
        end
        @sheet = @xls_file.sheet(0)
    end

    def up_order_info
        if params[:bom_id]
            Rails.logger.info("------------------------------------------------------------11")
            @bom = Bom.find(params[:bom_id]) 
            @bom.p_name = params[:p_name]
            @bom.qty = params[:qty]
            @bom.d_day = params[:day]
            Rails.logger.info("------------------------------------------------------------22")
            if @bom.save
                Rails.logger.info("------------------------------------------------------------33")
                @bom_item = BomItem.where(bom_id: params[:bom_id],mpn_id: nil)
                if not @bom_item.blank?
                    render "up_order_info.js.erb" and return
                else
                    @bom_item = BomItem.where(bom_id: params[:bom_id])
                    @total_p = 0 
                    @bom_item.each do |bomitem|
                        api_info = find_price(bomitem.mpn_id,@bom.qty)
                        if not api_info.blank?
                            bomitem.price = api_info[0]
                            bomitem.mf = api_info[1]
                            bomitem.dn = api_info[2]
                            bomitem.save
                            @total_p += bomitem.price*bomitem.quantity
                        end
                    end
                    @total_p = @total_p*@bom.qty.to_i
                    @bom.t_p = @total_p
                    @bom.save
                    @bom_id = params[:bom_id]
                    render "to_viewbom_info.js.erb" and return
                    #render inline: "window.location='/viewbom?bom_id=#{params[:bom_id]}';" and return
                end
            end         
        end
        render nothing: true
    end
    
    def up_pcb_info
        Rails.logger.info("@parse_result------------------------------------------------------------1111111")
        #Rails.logger.info(params[:bom_pcb_file].current_path.inspect)params.require(:bom).permit(:name, :bom_pcb_file)
        Rails.logger.info("@parse_result------------------------------------------------------------1111111")
        @bom = Bom.new
        
        if params[:bom_id]
            @boms = Bom.find(params[:bom_id])
            @bom_item = BomItem.where(bom_id: params[:bom_id])
        else
            #render nothing: true and return
        end
        if params[:bom_pcb_file]
            uploaded_io = params[:bom_pcb_file]
            File.open(Rails.root.join('public', 'uploads', 'bom', 'excel_file', params[:bom_id].to_s, uploaded_io.original_filename), 'wb') do |file|
                file.write(uploaded_io.read)
            end
            if params[:pcb_qty].to_i < 5
                pcb_qty = 5
            else
                pcb_qty = params[:pcb_qty].to_i
            end 
            if (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty) <= 150000
                if params[:pcb_layer] == "1" or params[:pcb_layer] == "2"
                    if params[:pcb_t] == "1.6" or params[:pcb_t] == "1.2" or params[:pcb_t] == "0.8" or params[:pcb_t] == "0.6" 
                        if params[:pcb_sf] == "HASL" or params[:pcb_sf] == "OSP"
                            if params[:pcb_sc] == "Green"
                                if params[:pcb_size_c].to_i > 100 or params[:pcb_size_k].to_i > 100
                                    @pcb_p = 13 + 7.6
                                else
                                    @pcb_p = 13
                                end
                            elsif params[:pcb_sc] != "Green"
                                if params[:pcb_size_c].to_i > 100 or params[:pcb_size_k].to_i > 100
                                    @pcb_p = 13 + 15.2
                                else
                                    @pcb_p = 13 + 7.6
                                end
                            end
                        elsif params[:pcb_sf] == "ENIG" 
                            if params[:pcb_sc] == "Green"
                                if params[:pcb_size_c].to_i > 100 or params[:pcb_size_k].to_i > 100
                                    @pcb_p = 31 + 7.6
                                else
                                    @pcb_p = 31
                                end
                            elsif params[:pcb_sc] != "Green"
                                if params[:pcb_size_c].to_i > 100 or params[:pcb_size_k].to_i > 100
                                    @pcb_p = 31 + 15.2
                                else
                                    @pcb_p = 31 + 7.6
                                end
                            end                        
                        end
                    elsif params[:pcb_t] == "2.0" or params[:pcb_t] == "0.4"
                        if params[:pcb_sf] == "HASL" or params[:pcb_sf] == "OSP"
                            @pcb_p = 31
                        elsif params[:pcb_sf] == "ENIG"
                            @pcb_p = 46.2
                        end
                    end
                elsif params[:pcb_layer] == "4"
                    if params[:pcb_t] == "1.6" or params[:pcb_t] == "1.2" or params[:pcb_t] == "0.8" or params[:pcb_t] == "0.6" 
                        if params[:pcb_sf] == "HASL" or params[:pcb_sf] == "OSP"
                            if params[:pcb_sc] == "Green"
                                if params[:pcb_size_c].to_i > 100 or params[:pcb_size_k].to_i > 100
                                    @pcb_p = 40 + 7.6
                                else
                                    @pcb_p = 40
                                end
                            elsif params[:pcb_sc] != "Green"
                                if params[:pcb_size_c].to_i > 100 or params[:pcb_size_k].to_i > 100
                                    @pcb_p = 40 + 15.2
                                else
                                    @pcb_p = 40 + 7.6
                                end
                            end
                        elsif params[:pcb_sf] == "ENIG" 
                            if params[:pcb_sc] == "Green"
                                if params[:pcb_size_c].to_i > 100 or params[:pcb_size_k].to_i > 100
                                    @pcb_p = 55.4 + 7.6
                                else
                                    @pcb_p = 55.4
                                end
                            elsif params[:pcb_sc] != "Green"
                                if params[:pcb_size_c].to_i > 100 or params[:pcb_size_k].to_i > 100
                                    @pcb_p = 55.4 + 15.2
                                else
                                    @pcb_p = 55.4 + 7.6
                                end
                            end                        
                        end
                    elsif params[:pcb_t] == "2.0" or params[:pcb_t] == "0.4"
                        if params[:pcb_sf] == "HASL" or params[:pcb_sf] == "OSP"
                            @pcb_p = 77
                        elsif params[:pcb_sf] == "ENIG"
                            @pcb_p = 92.3
                        end
                    end
                elsif params[:pcb_layer] == "6"
                    if params[:pcb_t] == "1.6" or params[:pcb_t] == "1.2" or params[:pcb_t] == "0.8" or params[:pcb_t] == "0.6" 
                        if params[:pcb_sf] == "HASL" or params[:pcb_sf] == "OSP"
                            if params[:pcb_sc] == "Green"
                                if params[:pcb_size_c].to_i > 100 or params[:pcb_size_k].to_i > 100
                                    @pcb_p = 200 + 7.6
                                else
                                    @pcb_p = 200
                                end
                            elsif params[:pcb_sc] != "Green"
                                if params[:pcb_size_c].to_i > 100 or params[:pcb_size_k].to_i > 100
                                    @pcb_p = 200 + 15.2
                                else
                                    @pcb_p = 200 + 7.6
                                end
                            end
                        elsif params[:pcb_sf] == "ENIG" 
                            if params[:pcb_sc] == "Green"
                                if params[:pcb_size_c].to_i > 100 or params[:pcb_size_k].to_i > 100
                                    @pcb_p = 245 + 7.6
                                else
                                    @pcb_p = 245
                                end
                            elsif params[:pcb_sc] != "Green"
                                if params[:pcb_size_c].to_i > 100 or params[:pcb_size_k].to_i > 100
                                    @pcb_p = 245 + 15.2
                                else
                                    @pcb_p = 245 + 7.6
                                end
                            end                        
                        end
                    elsif params[:pcb_t] == "2.0" or params[:pcb_t] == "0.4"
                        if params[:pcb_sf] == "HASL" or params[:pcb_sf] == "OSP"
                            @pcb_p = 231
                        elsif params[:pcb_sf] == "ENIG"
                            @pcb_p = 246
                        end
                    end
                end
            elsif (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty) >= 150000 and (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty) <= 3000000
                if params[:pcb_layer] == "1"
                    if params[:pcb_t] == "1.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.0000625) + 19
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00007077) + 19
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00007692) + 19
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00009231) + 19
                            end 
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005846) + 19
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00007077) + 19
                            end 
                        end
                    elsif params[:pcb_t] == "1.2" or params[:pcb_t] == "1.0" or params[:pcb_t] == "0.8" or params[:pcb_t] == "0.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005846) + 19
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00007077) + 19
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00007385) + 19
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00008932) + 19
                            end 
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005846) + 19
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00007077) + 19
                            end 
                        end
                    end
                elsif params[:pcb_layer] == "2"
                    if params[:pcb_t] == "1.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00007692) + 19
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00008923) + 19
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00009231) + 19
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000108) + 19
                            end 
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00008923) + 19
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00008923) + 19
                            end 
                        end
                    elsif params[:pcb_t] == "1.2" or params[:pcb_t] == "1.0" or params[:pcb_t] == "0.8" or params[:pcb_t] == "0.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00008923) + 19
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00008923) + 19
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00008923) + 19
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000105) + 19
                            end
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00008923) + 19
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00008923) + 19
                            end  
                        end
                    end
                elsif params[:pcb_layer] == "4"
                    if params[:pcb_t] == "1.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000146) + 95
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000185) + 95
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000162) + 95
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000169) + 95
                            end
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000146) + 95
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000185) + 95
                            end  
                        end
                    elsif params[:pcb_t] == "1.2" or params[:pcb_t] == "1.0" or params[:pcb_t] == "0.8" or params[:pcb_t] == "0.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000146) + 95
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000185) + 95
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.0000146) + 95
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000169) + 95
                            end 
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000146) + 95
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000185) + 95
                            end 
                        end
                    end
                elsif params[:pcb_layer] == "6"
                    if params[:pcb_t] == "1.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.0003) + 188
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000339) + 188
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.0003) + 188
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000346) + 188
                            end
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.0003) + 188
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000339) + 188
                            end  
                        end
                    elsif params[:pcb_t] == "1.2" or params[:pcb_t] == "1.0" or params[:pcb_t] == "0.8" or params[:pcb_t] == "0.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.0003) + 188
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000339) + 188
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.0003) + 188
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000346) + 188
                            end 
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.0003) + 188
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000339) + 188
                            end  
                        end
                    end
                end
            elsif (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty) >= 3000000 and (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty) <= 10000000
                if params[:pcb_layer] == "1"
                    if params[:pcb_t] == "1.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000043085) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005846) + 123
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005846) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00007077) + 123
                            end
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00004308) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005846) + 123
                            end  
                        end
                    elsif params[:pcb_t] == "1.2" or params[:pcb_t] == "1.0" or params[:pcb_t] == "0.8" or params[:pcb_t] == "0.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00004308) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005846) + 123
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005538) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00006769) + 123
                            end
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00004308) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005846) + 123
                            end  
                        end  
                    end
                elsif params[:pcb_layer] == "2"
                    if params[:pcb_t] == "1.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005846) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00007077) + 123
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00007385) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00008615) + 123
                            end 
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005846) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00007077) + 123
                            end 
                        end
                    elsif params[:pcb_t] == "1.2" or params[:pcb_t] == "1.0" or params[:pcb_t] == "0.8" or params[:pcb_t] == "0.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005846) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00007077) + 123
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00007077) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00008308) + 123
                            end
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005846) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00007077) + 123
                            end  
                        end
                    end
                elsif params[:pcb_layer] == "4"
                    if params[:pcb_t] == "1.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000131) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000169) + 123
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000146) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000177) + 123
                            end 
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000131) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000169) + 123
                            end 
                        end
                    elsif params[:pcb_t] == "1.2" or params[:pcb_t] == "1.0" or params[:pcb_t] == "0.8" or params[:pcb_t] == "0.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000131) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000169) + 123
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000146) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000177) + 123
                            end
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000131) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000169) + 123
                            end  
                        end
                    end
                elsif params[:pcb_layer] == "6"
                    if params[:pcb_t] == "1.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000281) + 188
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000281) + 188
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000292) + 188
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000323) + 188
                            end 
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000281) + 188
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000281) + 188
                            end 
                        end
                    elsif params[:pcb_t] == "1.2" or params[:pcb_t] == "1.0" or params[:pcb_t] == "0.8" or params[:pcb_t] == "0.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000281) + 188
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000281) + 188
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000292) + 188
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000323) + 188
                            end 
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000281) + 188
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000281) + 188
                            end 
                        end
                    end
                end
            elsif (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty) >= 10000000
                if params[:pcb_layer] == "1"
                    if params[:pcb_t] == "1.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00004) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005231) + 123
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005538) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00006769) + 123
                            end 
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00004) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005231) + 123
                            end 
                        end
                    elsif params[:pcb_t] == "1.2" or params[:pcb_t] == "1.0" or params[:pcb_t] == "0.8" or params[:pcb_t] == "0.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00004) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005231) + 123
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005231) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00006462) + 123
                            end 
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00004) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005231) + 123
                            end 
                        end
                    end
                elsif params[:pcb_layer] == "2"
                    if params[:pcb_t] == "1.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005538) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00006769) + 123
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00007077) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00008308) + 123
                            end
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005231) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00006769) + 123
                            end  
                        end
                    elsif params[:pcb_t] == "1.2" or params[:pcb_t] == "1.0" or params[:pcb_t] == "0.8" or params[:pcb_t] == "0.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005231) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00006769) + 123
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00006769) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00008) + 123
                            end 
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00005231) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.00006769) + 123
                            end  
                        end
                    end
                elsif params[:pcb_layer] == "4"
                    if params[:pcb_t] == "1.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000128) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000154) + 123
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000143) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000169) + 123
                            end 
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000128) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000154) + 123
                            end 
                        end
                    elsif params[:pcb_t] == "1.2" or params[:pcb_t] == "1.0" or params[:pcb_t] == "0.8" or params[:pcb_t] == "0.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000128) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000154) + 123
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000143) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000169) + 123
                            end 
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000128) + 123
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000154) + 123
                            end 
                        end
                    end
                elsif params[:pcb_layer] == "6"
                    if params[:pcb_t] == "1.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000281) + 188
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000308) + 188
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000297) + 188
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000323) + 188
                            end 
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000281) + 188
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000308) + 188
                            end 
                        end
                    elsif params[:pcb_t] == "1.2" or params[:pcb_t] == "1.0" or params[:pcb_t] == "0.8" or params[:pcb_t] == "0.6"
                        if params[:pcb_sf] == "HASL"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000281) + 188
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000308) + 188
                            end
                        elsif params[:pcb_sf] == "ENIG"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000297) + 188
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000323) + 188
                            end 
                        elsif params[:pcb_sf] == "OSP"
                            if params[:pcb_ct] == "1"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000281) + 188
                            elsif params[:pcb_ct] == "2"
                                @pcb_p = (params[:pcb_size_c].to_i * params[:pcb_size_k].to_i * pcb_qty * 0.000308) + 188
                            end 
                        end
                    end
                end
            end




            Rails.logger.info("@pcb_p------------------------------------------------------------1111111")
            Rails.logger.info(@pcb_p.inspect)
            Rails.logger.info("@pcb_p------------------------------------------------------------1111111")
            @boms = Bom.find(params[:bom_id])
            @boms.pcb_file = uploaded_io.original_filename
            @boms.pcb_layer = params[:pcb_layer]
            @boms.pcb_qty = params[:pcb_qty]
            @boms.pcb_size_c = params[:pcb_size_c]
            @boms.pcb_size_k = params[:pcb_size_k]
            @boms.pcb_sc = params[:pcb_sc]
            @boms.pcb_material = params[:pcb_material]
            @boms.pcb_cc = params[:pcb_cc]
            @boms.pcb_ct = params[:pcb_ct]
            @boms.pcb_sf = params[:pcb_sf]
            @boms.pcb_t = params[:pcb_t]
            @boms.pcb_p = @pcb_p
            @boms.save
            @shipping_info = ShippingInfo.where(user_id: current_user.id) 
            render "submit_order.html.erb" and return
        end
    end

    def create_order
        if params[:bom_id]
            bom = Bom.find(params[:bom_id])
            Rails.logger.info("bom------------------------------------------------------------1111111")
            Rails.logger.info(bom.class.inspect)
            Rails.logger.info("bom------------------------------------------------------------1111111")
            @order = Order.new
            @order.order_no = "MO" + Time.new.strftime('%Y').to_s[-1] + Time.new.strftime('%m%d').to_s + "B" + Order.find_by_sql('SELECT Count(orders.id)+1 AS all_no FROM orders WHERE to_days(orders.created_at) = to_days(NOW())').first.all_no.to_s + "B"
            @order.no = bom.no
            @order.shipping_info = params[:shipping_info]
            @order.bom_id = bom.id
            @order.name = bom.name
            @order.p_name = bom.p_name
            @order.qty = bom.qty
            @order.t_p = bom.t_p
            @order.d_day = bom.d_day
            @order.description = bom.description
            @order.excel_file = bom.excel_file
            @order.pcb_p = bom.pcb_p
            @order.pcb_file = bom.pcb_file
            @order.pcb_layer = bom.pcb_layer
            @order.pcb_qty = bom.pcb_qty
            @order.pcb_size_c = bom.pcb_size_c
            @order.pcb_size_k = bom.pcb_size_k
            @order.pcb_sc = bom.pcb_sc
            @order.pcb_material = bom.pcb_material
            @order.pcb_cc = bom.pcb_cc
            @order.pcb_ct = bom.pcb_ct
            @order.pcb_sf = bom.pcb_sf
            @order.pcb_t = bom.pcb_t
            @order.t_c = bom.t_c
            @order.c_p = bom.c_p
            @order.user_id = bom.user_id
            @order.save
            bom_item = BomItem.where(bom_id: params[:bom_id])
            bom_item.each do |bomitem|
                order_item = OrderItem.new
                order_item.quantity = bomitem.quantity
                order_item.description = bomitem.description
                order_item.part_code = bomitem.part_code
                order_item.order_id = @order.id
                order_item.product_id = bomitem.product_id
                order_item.warn = bomitem.warn
                order_item.user_id = bomitem.user_id
                order_item.danger = bomitem.danger
                order_item.manual = bomitem.manual
                order_item.mark = bomitem.mark
                order_item.mpn = bomitem.mpn
                order_item.mpn_id = bomitem.mpn_id
                order_item.price = bomitem.price
                order_item.mf = bomitem.mf
                order_item.dn = bomitem.dn
                order_item.other = bomitem.other
                order_item.save
            end
                
            redirect_to vieworder_path(order_id: @order.id)
        end
    end

    def search_part
        if params[:bom_id]
            @bom_item = BomItem.where(bom_id: params[:bom_id])
            @bom_item.each do |item|
                if item.mpn_id.blank? 
                    mpn = item.mpn
                    url = 'http://api.findchips.com/v1/search?apiKey=RDQCwiQN4yhvRYKulcgw&part='
                    url += mpn
                    begin
                        resp = Net::HTTP.get_response(URI.parse(url))
                        server_response = JSON.parse(resp.body) 
                    rescue
                        retry
                    end   
                    info_mpn = InfoPart.new
                    info_mpn.mpn = mpn
                    info_mpn.info = resp.body
                    info_mpn.save
                    item.mpn_id = info_mpn.id
                    item.save
                    @item = item
                    render "search_part.js.erb" and return
                end                          
            end 
            @bom = Bom.find(params[:bom_id])      
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
                render inline: "window.location='/viewbom?bom_id=#{params[:bom_id]}';" 
            end           
        end      
    end
    
    def viewbom
        @bom = Bom.new
        @boms = Bom.find(params[:bom_id])
        @bom_item = BomItem.where(bom_id: params[:bom_id])
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
            render "viewbom.html.erb"
            return false  
        else
            @shipping_info = ShippingInfo.where(user_id: current_user.id)
            render "submit_order.html.erb"
            return false
        end
    end

    def bomlist
        @bom = Bom.new
        @boms = Bom.find_by_sql("SELECT * FROM `boms` WHERE `user_id` = '" + current_user.id.to_s + "' AND `name` IS NULL ORDER BY `id` DESC ").paginate(:page => params[:page], :per_page => 10)
    end
   
    def orderlist
        @bom = Bom.new
        @order = Bom.find_by_sql("SELECT * FROM `orders` WHERE `user_id` = '" + current_user.id.to_s + "' AND `name` IS NULL ORDER BY `id` DESC ").paginate(:page => params[:page], :per_page => 10)
    end
   
    def vieworder
        @order = Order.find(params[:order_id])
        @order_item = OrderItem.where(order_id: params[:order_id])
        if not @order.pcb_dc_p.blank?
            @pcb_p = @order.pcb_dc_p
        elsif not @order.pcb_r_p.blank?
            @pcb_p = @order.pcb_r_p
        else
            @pcb_p = @order.pcb_p
        end
        if not @order.pcb_dc_remark.blank?
            @remark = @order.pcb_dc_remark
        elsif not @order.pcb_r_remark.blank?
            @remark = @order.pcb_r_remark
        else
            @remark = ""
        end
    end
   
    def order_review_list
        @bom = Bom.new
        @order = Order.where(state: "review", double_check_state: nil).order(id: :desc).paginate(:page => params[:page], :per_page => 10)
    end

    def order_review    
        @order = Order.find(params[:order_id])
        @order_item = OrderItem.where(order_id: params[:order_id])
        if not @order.pcb_dc_p.blank?
            @pcb_p = @order.pcb_dc_p
        elsif not @order.pcb_r_p.blank?
            @pcb_p = @order.pcb_r_p
        else
            @pcb_p = @order.pcb_p
        end
    end

    def review_pass
        order = Order.find(params[:order_id])
        order.double_check_state = "pass_one"
        order.save
        @order = Order.where(state: "review", double_check_state: nil).paginate(:page => params[:page], :per_page => 10)
        @bom = Bom.new
        render "order_review_list.html.erb"
    end
  
    def order_dc_list
        @bom = Bom.new
        @order = Order.where(state: "review", double_check_state: "pass_one").order(id: :desc).paginate(:page => params[:page], :per_page => 10)
        render "order_dc_list.html.erb"
    end

    def order_dc
        @order = Order.find(params[:order_id])
        @order_item = OrderItem.where(order_id: params[:order_id])
        if not @order.pcb_dc_p.blank?
            @pcb_p = @order.pcb_dc_p
        elsif not @order.pcb_r_p.blank?
            @pcb_p = @order.pcb_r_p
        else
            @pcb_p = @order.pcb_p
        end
    end

    def dc_pass
        order = Order.find(params[:order_id])
        order.double_check_state = "pass_dc"
        order.state = "review pass"
        order.save
        @order = Order.where(state: "review", double_check_state: "pass_one").paginate(:page => params[:page], :per_page => 10)
        @bom = Bom.new
        render "order_dc_list.html.erb"
    end

    def pcb_dc_change
        @order = Order.find(params[:order_id])
        @order.pcb_dc_p = params[:pcb_dc_p]
        @order.pcb_dc_remark = params[:pcb_dc_remark]
        @order.save
        redirect_to order_dc_path(order_id: @order.id)
    end

    def pcb_r_change
        @order = Order.find(params[:order_id])
        @order.pcb_r_p = params[:pcb_r_p]
        @order.pcb_r_remark = params[:pcb_r_remark]
        @order.save
        redirect_to order_review_path(order_id: @order.id)
    end

    def user_profile
        @bom = Bom.new
        @user_profile = User.find(current_user.id)
        @billing_info = BillingInfo.where(user_id: current_user.id)
        @shipping_info = ShippingInfo.where(user_id: current_user.id)
    end

    def edit_billing
        billing = BillingInfo.find(params[:billing_id])  
        if billing.user_id = current_user.id
            billing.first_name = params[:first_name]
            billing.last_name = params[:last_name]
            billing.address_line = params[:address_line]
            billing.postal_code = params[:postal_code]
            billing.email = params[:email]
            billing.phone = params[:phone]
            billing.city = params[:city]
            billing.country = params[:user][:country_code]
            country = ISO3166::Country[params[:user][:country_code]]
            billing.country_name = country.translations['es'] || country.name
            billing.company = params[:company]
            billing.save
        else
            redirect_to user_profile_path()
        end 
        redirect_to user_profile_path()
    end

    def edit_shipping
        shipping = ShippingInfo.find(params[:shipping_id])  
        if shipping.user_id = current_user.id
            shipping.first_name = params[:first_name]
            shipping.last_name = params[:last_name]
            shipping.address_line = params[:address_line]
            shipping.postal_code = params[:postal_code]
            shipping.email = params[:email]
            shipping.phone = params[:phone]
            shipping.city = params[:city]
            shipping.country = params[:user][:country_code]
            country = ISO3166::Country[params[:user][:country_code]]
            shipping.country_name = country.translations['es'] || country.name
            shipping.company = params[:company]
            shipping.save
        else
            redirect_to user_profile_path()
        end 
        redirect_to user_profile_path()
    end

    def edit_shipping_js
        shipping = ShippingInfo.find(params[:shipping_id])  
        if shipping.user_id = current_user.id
            shipping.first_name = params[:first_name]
            shipping.last_name = params[:last_name]
            shipping.address_line = params[:address_line]
            shipping.postal_code = params[:postal_code]
            shipping.email = params[:email]
            shipping.phone = params[:phone]
            shipping.city = params[:city]
            shipping.country = params[:user][:country_code]
            country = ISO3166::Country[params[:user][:country_code]]
            shipping.country_name = country.translations['es'] || country.name
            shipping.company = params[:company]
            shipping.save
        else
            redirect_to user_profile_path()
        end 
        redirect_to user_profile_path()
    end

    def del_billing
        billing = BillingInfo.find_by(id: params[:billing_id],user_id: current_user.id)
        if not billing.blank?
            billing.destroy
        end
        redirect_to user_profile_path()
    end

    def del_shipping
        shipping = ShippingInfo.find_by(id: params[:shipping_id],user_id: current_user.id)
        if not shipping.blank?
            shipping.destroy
        end
        redirect_to user_profile_path()
    end

    def up_user_profile
        @bom = Bom.new
        if params[:commit] == "UPDATE"
            user_profile = User.find(current_user.id)   
            user_profile.first_name = params[:first_name]
            user_profile.last_name = params[:last_name]
            user_profile.country = params[:user][:country_code]
            country = ISO3166::Country[params[:user][:country_code]]
            user_profile.country_name = country.translations['es'] || country.name         
            user_profile.skype = params[:skype]
            user_profile.save
        elsif params[:commit] == "DELIVER TO THIS ADDRESS" 
            if params[:shipping] == "yes"
                user_billing = BillingInfo.new
                user_billing.user_id = current_user.id
                user_billing.first_name = params[:shipping_first_name]
                user_billing.last_name = params[:shipping_last_name]
                user_billing.address_line = params[:shipping_address_line]
                user_billing.postal_code = params[:shipping_postal_code]
                user_billing.email = params[:shipping_email]
                user_billing.phone = params[:shipping_phone]
                user_billing.city = params[:shipping_city]
                user_billing.country = params[:shipping_c][:country]
                country = ISO3166::Country[params[:shipping_c][:country]]
                user_billing.country_name = country.translations['es'] || country.name
                user_billing.company = params[:shipping_company]
                user_billing.save 
                user_shipping = ShippingInfo.new
                user_shipping.user_id = current_user.id
                user_shipping.first_name = params[:shipping_first_name]
                user_shipping.last_name = params[:shipping_last_name]
                user_shipping.address_line = params[:shipping_address_line]
                user_shipping.postal_code = params[:shipping_postal_code]
                user_shipping.email = params[:shipping_email]
                user_shipping.phone = params[:shipping_phone]
                user_shipping.city = params[:shipping_city]
                user_shipping.country = params[:shipping_c][:country]
                country = ISO3166::Country[params[:shipping_c][:country]]
                user_shipping.country_name = country.translations['es'] || country.name
                user_shipping.company = params[:shipping_company]
                user_shipping.save 
            elsif params[:shipping] == "no"
                user_billing = BillingInfo.new
                user_billing.user_id = current_user.id
                user_billing.first_name = params[:billing_first_name]
                user_billing.last_name = params[:billing_last_name]
                user_billing.address_line = params[:billing_address_line]
                user_billing.postal_code = params[:billing_postal_code]
                user_billing.email = params[:billing_email]
                user_billing.phone = params[:billing_phone]
                user_billing.city = params[:billing_city]
                user_billing.country = params[:billing][:country]
                country = ISO3166::Country[params[:billing][:country]]
                user_billing.country_name = country.translations['es'] || country.name
                user_billing.company = params[:billing_company]
                user_billing.save
                user_shipping = ShippingInfo.new
                user_shipping.user_id = current_user.id
                user_shipping.first_name = params[:shipping_first_name]
                user_shipping.last_name = params[:shipping_last_name]
                user_shipping.address_line = params[:shipping_address_line]
                user_shipping.postal_code = params[:shipping_postal_code]
                user_shipping.email = params[:shipping_email]
                user_shipping.phone = params[:shipping_phone]
                user_shipping.city = params[:shipping_city]
                user_shipping.country = params[:shipping_c][:country]
                country = ISO3166::Country[params[:shipping_c][:country]]
                user_shipping.country_name = country.translations['es'] || country.name
                user_shipping.company = params[:shipping_company]
                user_shipping.save 
            end             
        end
        redirect_to user_profile_path()
    end

    def update_bom
        bom_item = BomItem.find(params[:pk])
        @bom = Bom.find(bom_item.bom_id)
        if not params[:value].blank? 
            mpn = params[:value].strip
            url = 'http://api.findchips.com/v1/search?apiKey=RDQCwiQN4yhvRYKulcgw&part='
            url += mpn
            begin
                resp = Net::HTTP.get_response(URI.parse(url))
            rescue
                retry
            end
            server_response = JSON.parse(resp.body)    
            info_mpn = InfoPart.new
            info_mpn.mpn = mpn
            info_mpn.info = resp.body
            info_mpn.save
            bom_item.mpn_id = info_mpn.id
            bom_item.mpn = params[:value]
            api_info = find_price(bom_item.mpn_id,@bom.qty)
            if not api_info.blank?  
               bom_item.price = api_info[0]
               bom_item.mf = api_info[1]
               bom_item.dn = api_info[2]
            end
            bom_item.save
        end                          
        @bom_item = BomItem.where(bom_id: bom_item.bom_id)
        if not @bom.qty.blank?
            @total_p = 0   
            all_c = 0           
            @bom_item.each do |bomitem|
                if not bomitem.price.blank?
                    @total_p += bomitem.price*bomitem.quantity
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
        end
        #render inline: "window.location='/viewbom?bom_id=#{bom_item.bom_id}';"  
        #redirect_to viewbom_path(bom_id: bom_item.bom_id)     
        bom_all = BomItem.find_by_sql("SELECT id,mpn,part_code,quantity,price,(price*quantity) AS total,mf,dn FROM bom_items WHERE bom_items.bom_id = '#{bom_item.bom_id}'")
        render json: bom_all and return
    end

    def get_bom      
        @bom_item = BomItem.find_by_sql("SELECT id,mpn,part_code,quantity,price,(price*quantity) AS total,mf,dn FROM bom_items WHERE bom_items.bom_id = '#{params[:bom_id]}'")
        render json: @bom_item
    end

    def del_bom     
        bom_item = BomItem.where(id: params[:id],user_id: current_user.id).first
        Rails.logger.info("----------------------------------------------------1")
        @bomitem = bom_item.mpn
        Rails.logger.info("----------------------------------------------------2")
        if not bom_item.blank?
            Rails.logger.info("----------------------------------------------------3")
            @bom_id = bom_item.bom_id
            bom_item.destroy 
            Rails.logger.info("----------------------------------------------------")
            Rails.logger.info(@bom_id.inspect)
            Rails.logger.info("----------------------------------------------------")
        end
        @bom = Bom.find(@bom_id)
        Rails.logger.info("----------------------------------------------------4")                               
        @bom_item = BomItem.where(bom_id: @bom_id)
        Rails.logger.info("----------------------------------------------------5")
        if not @bom.qty.blank?
            Rails.logger.info("----------------------------------------------------6")
            @total_p = 0   
            all_c = 0           
            @bom_item.each do |bomitem|
                Rails.logger.info("----------------------------------------------------7")
                if not bomitem.price.blank?
                    @total_p += bomitem.price*bomitem.quantity
                end
                all_c += bomitem.quantity
            end
            Rails.logger.info("----------------------------------------------------8")
            @total_p = @total_p*@bom.qty.to_i
            @bom.t_p = @total_p
            @bom.t_c = all_c*@bom.qty.to_i
            c_p = all_c*@bom.qty.to_i*0.06
            if c_p < 200
                c_p = 200
            end
            @bom.c_p = c_p
            @bom.save 
            Rails.logger.info("----------------------------------------------------9")          
        end
        Rails.logger.info("----------------------------------------------------10")
        #render del_bom.js.erb and return
        #redirect_to viewbom_path(bak: "bak",bom_id: bom_id)
    end
    
    def add_bom
        bom_item = BomItem.new
        bom_id = params[:bom_id]
        @bom = Bom.find(params[:bom_id])
        if not params[:part].blank? 
            mpn = params[:part].strip
            url = 'http://api.findchips.com/v1/search?apiKey=RDQCwiQN4yhvRYKulcgw&part='
            url += mpn
            begin
                resp = Net::HTTP.get_response(URI.parse(url))
            rescue
                retry
            end
            server_response = JSON.parse(resp.body)    
            info_mpn = InfoPart.new
            info_mpn.mpn = mpn
            info_mpn.info = resp.body
            info_mpn.save
            bom_item.mpn_id = info_mpn.id
            bom_item.mpn = params[:part]
            bom_item.quantity = params[:qty]
            bom_item.part_code = params[:code]
            bom_item.bom_id = params[:bom_id]
            bom_item.user_id = current_user.id
            api_info = find_price(bom_item.mpn_id,@bom.qty)
            if not api_info.blank?  
               bom_item.price = api_info[0]
               bom_item.mf = api_info[1]
               bom_item.dn = api_info[2]
            end
            bom_item.save
        end                          
        @bom_item = BomItem.where(bom_id: bom_item.bom_id)
        if not @bom.qty.blank?
            @total_p = 0   
            all_c = 0           
            @bom_item.each do |bomitem|
                if not bomitem.price.blank?
                    @total_p += bomitem.price*bomitem.quantity
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
        end
        redirect_to viewbom_path(bak: "bak",bom_id: bom_id)
    end

    def create
       
        @bom = Bom.new(bom_params)#使用页面传进来的文件名字作为参数创建一个bom对象
        @bom.user_id = current_user.id
        #如果上传成功
	if @bom.save
            
            if @bom.excel_file_identifier.split('.')[-1] == 'xls'
	        @xls_file = Roo::Excel.new(@bom.excel_file.current_path)
            else
                @xls_file = Roo::Excelx.new(@bom.excel_file.current_path)
            end
	    @sheet = @xls_file.sheet(0)

	    #@parse_result = @sheet.parse(header_search: [/(?im)qty/,/(?im)des/,/(?im)ref/,/(?im)mpn/],clean:true)
            @parse_result = @sheet.parse(:qty => /(?im)qty/,:des => /(?im)des/,:ref => /(?im)ref/,:mpn => /(?im)mpn/,clean:true)
            #@parse_result = @sheet.parse(header_search: [RegExReplace(/(?im)qty/,"qty"),/(?im)des/,/(?im)ref/,/(?im)mpn/],clean:true)
            Rails.logger.info("@parse_result------------------------------------------------------------1111111")
            Rails.logger.info(@parse_result.inspect)
            #Rails.logger.info(@parse_result.upcase.inspect)
            Rails.logger.info("@parse_result-------------------------------------------------------------1111111111")
	    #remove first row 
	    @parse_result.shift
	    @parse_result.select! {|item| !item[:des].blank?||!item[:mpn].blank? } #选择非空行
            Rails.logger.info("@parse_result------------------------------------------------------------22222222222")
            Rails.logger.info(@parse_result.inspect)
            Rails.logger.info("@parse_result-------------------------------------------------------------2222222222")
            #行号
            row_num = 0
           # all_m_bom = []
            #one_m_bom = []
	    @parse_result.each do |item| #处理每一行的数据 
	        part_code = item[:ref]
		desc = item[:des]
                #if desc.include?".0uF"
                    #desc[".0uF"]="uF"
                    #Rails.logger.info("0000000000000000000000000000000000000")
                    #Rails.logger.info(desc)
                    #Rails.logger.info("0000000000000000000000000000000")
                #end
	        quantity = item[:qty]
    
                mpn = item[:mpn]
		bom_item = @bom.bom_items.build() #创建bom_items对象
		
                bom_item.part_code = part_code
                		
		
		bom_item.description = desc
		
 
                #标记part数量与购买数量不一致的行，提取partcode代码
  	  	#ary2 = part_code.to_s.scan(/[A-Z]+/)
                
                ary2 = part_code.to_s.split(",")
                Rails.logger.info("ary2ary2ary2ary2ary2ary2ccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000")
                Rails.logger.info(ary2.inspect)
                Rails.logger.info("ary2ary2ary2ary2ary2ary2ccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000")
                if ary2.size < 2
                    ary2 = part_code.to_s.split(" ")
                end
  	  	ary3 = part_code.to_s.scan(/[a-zA-Z][0-9]+/)
  	  	part_code = part_code.to_s.scan(/[A-Z]+/)[0]
  	  	Rails.logger.info("ary3ary3ary3ary3ary3ary3ccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000")
                Rails.logger.info(ary3.inspect)
                Rails.logger.info("ary3ary3ary3ary3ary3ary3ccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000")
                #把没写位号的找出来
                if quantity.blank?
                    quantity = ary2.size
                    bom_item.danger = true
                else
  	  	    bom_item.danger = false
                end
  	  	#比较位号的个数与采购的数量，如果不相等则标记出来
  	  	if quantity != ary2.size
  	  	    bom_item.danger = true
                    quantity = ary2.size
  	  	elsif ary3.uniq!   #去除数组中重复的位号并返回新数组，如果没有重复则返回nil 
  	  	    bom_item.danger = true
  	  	else
  	  	    bom_item.danger = false
  	  	end
                bom_item.quantity = quantity
                bom_item.mpn = mpn
		Rails.logger.info("ccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000")
                Rails.logger.info(ary2.inspect)
                Rails.logger.info(part_code)
                match_product = search_bom_use(desc,mpn)
                if match_product == []
                    match_product = search_bom(desc,part_code) #根据关键字和位号查询产品
                end
                bom_item.product_id = match_product.first.id if match_product.count > 0
                
                Rails.logger.info("ccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000")
                Rails.logger.info(match_product.inspect)   
                Rails.logger.info("wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")     
		
		#bom_item.match_product = match_product.first unless match_product.empty?
		#bom_item.product = match_product.first unless match_product.empty?
                bom_item.user_id = current_user.id
                
                
		if bom_item.save
                    #match_product.collect! {|x| x[bomitemid] = bom_item.id)}
                    #match_product.each do |x|
                        
                        #one_m_bom << bom_item.id
                       # one_m_bom << x.id
                        #all_m_bom << one_m_bom
                        #one_m_bom = []
                        #x[bomitemid] = bom_item.id
                        #Rails.logger.info("match_product -------------------------------------------------xxxxxxxxxx")
                        #Rails.logger.info(x) 
                        #Rails.logger.info("match_product -------------------------------------------------xxxxxxxxx")
                    #end
                    #Rails.logger.info("match_product -------------------------------------------------match_product")
                    #Rails.logger.info(match_product.inspect) 
                    #Rails.logger.info("match_product -------------------------------------------------match_product")
                else
                    #Rails.logger.info(bom_item.part_code.inspect) 
                    Rails.logger.info("bom item bad -------------------------------------------------bom item bad")
                end
				
	    end
            
            #Rails.logger.info("match_product -------------------------------------------------match_product")
            #Rails.logger.info(all_m_bom.inspect) 
            #Rails.logger.info("match_product -------------------------------------------------match_product")	
	    redirect_to @bom,  notice: t('file') + " #{@bom.name} " + t('success_b')
            #redirect_to bom_url(@bom, bom_data: all_m_bom.to_json)
	else
            flash[:error] = "Upload file error,please upload the XLS or XLSX file."
	    redirect_to action: 'upload'
	end
    rescue
        flash[:error] = "Upload file error,please upload the XLS or XLSX file."
        redirect_to :back
    end

    def destroy
         Rails.logger.info("-------------------------111111111")
         Rails.logger.info(request.original_fullpath.inspect)   
         Rails.logger.info("----------------------------------222222222222222") 
	 @bom = Bom.find(params[:id])
         if current_user.email == "web@mokotechnology.com" and User.find(@bom.user_id).email == current_user.email
             @bom.destroy
         else
	     @bom.name = "del"
             @bom.save
         end
         if params[:do]
             redirect_to bomlist_path, notice:  "BOM #{@bom.name} " + t('success_c')
         else
	     redirect_to boms_path, notice:  "BOM #{@bom.name} " + t('success_c')
         end
    end
   
    def mark
	 @bom_item = BomItem.find(params[:id])
	 @bom_item.product_id = nil
         @bom_item.mpn_id = nil
         @bom_item.mark = true
         @bom_item.save
         @bom_n = Bom.find(@bom_item.bom_id)
         @match_str_n = "#{@bom_n.bom_items.count('product_id')+@bom_n.bom_items.count('mpn_id')} / #{@bom_n.bom_items.count}"
         @matched_items_n = Product.find_by_sql("
SELECT
	bom_items.id,
	bom_items.quantity,
	bom_items.description,
	bom_items.part_code,
	bom_items.bom_id,
	bom_items.product_id,
	bom_items.created_at,
	bom_items.updated_at,
	bom_items.warn,
	bom_items.user_id,
	bom_items.danger,
	bom_items.manual,
	bom_items.mark,
	bom_items.mpn,
	bom_items.mpn_id,

IF (
	bom_items.mpn_id > 0,
	mpn_items.price,
	products.price
) AS price,

IF (
	bom_items.mpn_id > 0,
	mpn_items.description,
	products.description
) AS description_p
FROM
	bom_items
LEFT JOIN products ON bom_items.product_id = products.id
LEFT JOIN mpn_items ON bom_items.mpn_id = mpn_items.id
WHERE
	bom_items.bom_id = "+@bom_item.bom_id.to_s)             
         @total_price_n = 0.00               
	 unless @matched_items_n.empty?
             @bom_api_all = []
             @matched_items_n.each do |item|
                 if not item.price.blank?
                     @total_price_n += item.price * item.quantity  
                 end                      
	     end
         end
	 #redirect_to :back
         #redirect_to bom_path(@bom_item.bom, :anchor => "Comment", :bomitem => @bom_item.id );
         render "mark_local.js.erb"
    end    

    def upload
        Rails.logger.info("-------------------------")
        Rails.logger.info(request.original_fullpath.inspect)   
        Rails.logger.info("----------------------------------") 
        
        @bom = Bom.new
        #@mpn_show = MpnItem.find_by_sql("SELECT * FROM `mpn_items` LIMIT 0, 30")
        @mpn_show = MpnItem.find_by_sql("SELECT * FROM mpn_items WHERE mpn IS NOT NULL AND id >= ((SELECT MAX(id) FROM mpn_items)-(SELECT MIN(id) FROM mpn_items)) * RAND() + (SELECT MIN(id) FROM mpn_items) LIMIT 100")
        @des_show = Product.find_by_sql("SELECT * FROM products WHERE id >= ((SELECT MAX(id) FROM products)-(SELECT MIN(id) FROM products)) * RAND() + (SELECT MIN(id) FROM products) LIMIT 100")
    end
    def root
        Rails.logger.info("-------------------------")
        Rails.logger.info(request.original_fullpath.inspect)   
        Rails.logger.info("----------------------------------") 
        
        @bom = Bom.new
        #@mpn_show = MpnItem.find_by_sql("SELECT * FROM `mpn_items` LIMIT 0, 30")
        @mpn_show = MpnItem.find_by_sql("SELECT * FROM mpn_items WHERE mpn IS NOT NULL AND id >= ((SELECT MAX(id) FROM mpn_items)-(SELECT MIN(id) FROM mpn_items)) * RAND() + (SELECT MIN(id) FROM mpn_items) LIMIT 100")
        @des_show = Product.find_by_sql("SELECT * FROM products WHERE id >= ((SELECT MAX(id) FROM products)-(SELECT MIN(id) FROM products)) * RAND() + (SELECT MIN(id) FROM products) LIMIT 100")
    end

    def choose
        if not params[:product_id].blank?
            @bom_item = BomItem.find(params[:id]) #取回bom_items表bomitem记录，在解析bom是存入，可能没有匹配到product
            if @bom_item.update_attribute("product_id", params[:product_id])
                if @bom_item.product_id
	            #@bom_item.product = Product.find(@bom_item.product_id)
                    @bom_item.warn = false
                    @bom_item.mark = false
                    @bom_item.manual = true
	            @bom_item.save!
  

                    #累加产品被选择的次数
                    prefer = (Product.find(@bom_item.product_id)).prefer + 1
                    Product.find(@bom_item.product_id).update(prefer: prefer) 
        
                    flash[:success] = t('success_a')

                    redirect_to boms_path(@bom_item.bom, :anchor => "Comment", :bomitem => @bom_item.id );
                else
	            flash[:error] = t('error_d')
	  	    redirect_to boms_path(@bom_item.bom, :anchor => "Comment", :bomitem => @bom_item.id );
	        end
            else
                render 'edit'
            end
        elsif not params[:mpn_id].blank?
            @bom_item = BomItem.find(params[:id]) #取回bom_items表bomitem记录，在解析bom是存入，可能没有匹配到product
            @bom_n = Bom.find(@bom_item.bom_id)
            
            
            if @bom_item.update_attribute("mpn_id", params[:mpn_id])
                if @bom_item.mpn_id
	            #@bom_item.product = Product.find(@bom_item.product_id)
                    @bom_item.warn = false
                    @bom_item.mark = false
                    @bom_item.manual = true
                    @bom_item.product_id = nil
	            @bom_item.save!
                    @match_str_n = "#{@bom_n.bom_items.count('product_id')+@bom_n.bom_items.count('mpn_id')} / #{@bom_n.bom_items.count}"
                    @matched_items_n = Product.find_by_sql("
SELECT
	bom_items.id,
	bom_items.quantity,
	bom_items.description,
	bom_items.part_code,
	bom_items.bom_id,
	bom_items.product_id,
	bom_items.created_at,
	bom_items.updated_at,
	bom_items.warn,
	bom_items.user_id,
	bom_items.danger,
	bom_items.manual,
	bom_items.mark,
	bom_items.mpn,
	bom_items.mpn_id,

IF (
	bom_items.mpn_id > 0,
	mpn_items.price,
	products.price
) AS price,

IF (
	bom_items.mpn_id > 0,
	mpn_items.description,
	products.description
) AS description_p
FROM
	bom_items
LEFT JOIN products ON bom_items.product_id = products.id
LEFT JOIN mpn_items ON bom_items.mpn_id = mpn_items.id
WHERE
	bom_items.bom_id = "+@bom_item.bom_id.to_s)             
                    @total_price_n = 0.00               
	            unless @matched_items_n.empty?
                        @bom_api_all = []
		        @matched_items_n.each do |item|
                            if not item.price.blank?
                                @total_price_n += item.price * item.quantity  
                            end                      
		        end
                    end
                    #flash[:success] = t('success_a')

                    #redirect_to bom_path(@bom_item.bom, :anchor => "Comment", :bomitem => @bom_item.id );
                    
                    render "choose.js.erb"
                    #render "choose.html.erb"
                    #respond_to do |format|
                        #format.html {render nothing: true}
                        #format.js {render "choose.js.erb"}

                    #end
                else
	            flash[:error] = t('error_d')
	  	    redirect_to bom_path(@bom_item.bom, :anchor => "Comment", :bomitem => @bom_item.id );
	        end
            else
                render 'edit'
            end     
        end
    end

    def search_in_api(mpn)
        if mpn == nil
            mpn = ""
        end
        mpn = mpn.strip
        @item_id = params[:itemid]
        mpn_item = MpnItem.find_by_sql("SELECT * FROM `mpn_items` WHERE `mpn` LIKE '%"+mpn+"%'").first
        Rails.logger.info("mpn_item--------------------------------------------------------------------------mpn_item")
        Rails.logger.info(mpn_item.inspect)   
        Rails.logger.info("mpn_item--------------------------------------------------------------------------mpn_item") 
        if mpn_item.blank?
            @mpn_item = search_findchips(params[:mpn])
            prices_all = []
            naive_id_all = []
            part_all = []
            @mpn_item.each do |result|
                result['parts'].each do |part|
                    Rails.logger.info("part--------------------------------------------------------------------------part")
                    Rails.logger.info(part.inspect)   
                    Rails.logger.info("part--------------------------------------------------------------------------part") 
                    part['price'].each do |f|     
                        if f.has_value?"USD"
                            prices_all << f['price'].to_f
                            naive_id_all << result['distributor']['id'] 
                            part_all << part['part']                                    
                        end
                    end
                end
            end
            Rails.logger.info("prices_all--------------------------------------------------------------------------")
            Rails.logger.info(prices_all.inspect)   
            Rails.logger.info("prices_all--------------------------------------------------------------------------")    
            @api_result = []
            if not prices_all == []
                mpn_new = MpnItem.new
                naive_id= naive_id_all[(prices_all.index prices_all.min)]
                naive_part= part_all[(prices_all.index prices_all.min)]
                @mpn_item.each do |result|
                    if result['distributor']['id'] == naive_id
                        result['parts'].each do |part|
                            if part['part'] == naive_part
                                @api_result << part['part']
                                @api_result << part['manufacturer']
                                @api_result << result['distributor']['name']
                                @api_result << part['description']
                                @api_result << prices_all.min
                                @api_result << "http://www.alldatasheet.com/view.jsp?Searchword=" + part['part'].to_s
                                mpn_new.mpn = part['part']
                                mpn_new.manufacturer = part['manufacturer']
                                mpn_new.authorized_distributor = result['distributor']['name']
                                mpn_new.description = part['description']
                                mpn_new.price = prices_all.min
                                mpn_new.datasheets = "http://www.alldatasheet.com/view.jsp?Searchword=" + part['part'].to_s
                            end                            
                        end
                    end
                    mpn_new.save
                    @api_result << mpn_new.id 
                end
            end
        else
            @api_result = []
            @api_result << mpn_item['mpn']
            @api_result << mpn_item['manufacturer'] 
            @api_result << mpn_item['authorized_distributor']
            @api_result << mpn_item['description']
            @api_result << mpn_item['price']
            @api_result << mpn_item['datasheets']
            @api_result << mpn_item['id'] 
        end
        result = @api_result
    end

    def search_api
        mpn = params[:mpn].strip
        @item_id = params[:itemid]
        mpn_item = MpnItem.find_by_sql("SELECT * FROM `mpn_items` WHERE `mpn` LIKE '%"+mpn+"%'").first
        Rails.logger.info("mpn_item--------------------------------------------------------------------------mpn_item")
        Rails.logger.info(mpn_item.inspect)   
        Rails.logger.info("mpn_item--------------------------------------------------------------------------mpn_item") 
        if mpn_item.blank?
            @mpn_item = search_findchips(params[:mpn])
            prices_all = []
            naive_id_all = []
            part_all = []
            @mpn_item.each do |result|
                result['parts'].each do |part|
                    Rails.logger.info("part--------------------------------------------------------------------------part")
                    Rails.logger.info(part.inspect)   
                    Rails.logger.info("part--------------------------------------------------------------------------part") 
                    part['price'].each do |f|     
                        if f.has_value?"USD"
                            prices_all << f['price'].to_f
                            naive_id_all << result['distributor']['id'] 
                            part_all << part['part']                                    
                        end
                    end
                end
            end
            Rails.logger.info("prices_all--------------------------------------------------------------------------")
            Rails.logger.info(prices_all.inspect)   
            Rails.logger.info("prices_all--------------------------------------------------------------------------")    
            @api_result = []
            if not prices_all == []
                mpn_new = MpnItem.new
                naive_id= naive_id_all[(prices_all.index prices_all.min)]
                naive_part= part_all[(prices_all.index prices_all.min)]
                @mpn_item.each do |result|
                    if result['distributor']['id'] == naive_id
                        result['parts'].each do |part|
                            if part['part'] == naive_part
                                @api_result << part['part']
                                @api_result << part['manufacturer']
                                @api_result << result['distributor']['name']
                                @api_result << part['description']
                                @api_result << prices_all.min
                                @api_result << "http://www.alldatasheet.com/view.jsp?Searchword=" + part['part'].to_s
                                mpn_new.mpn = part['part']
                                mpn_new.manufacturer = part['manufacturer']
                                mpn_new.authorized_distributor = result['distributor']['name']
                                mpn_new.description = part['description']
                                mpn_new.price = prices_all.min
                                mpn_new.datasheets = "http://www.alldatasheet.com/view.jsp?Searchword=" + part['part'].to_s
                            end                            
                        end
                    end
                    mpn_new.save
                    @api_result << mpn_new.id 
                end
            end
        else
            @api_result = []
            @api_result << mpn_item['mpn']
            @api_result << mpn_item['manufacturer'] 
            @api_result << mpn_item['authorized_distributor']
            @api_result << mpn_item['description']
            @api_result << mpn_item['price']
            @api_result << mpn_item['datasheets']
            @api_result << mpn_item['id'] 
        end
    end

    def search_api_bak
        mpn = params[:mpn]
        @item_id = params[:itemid]
        mpn_item = MpnItem.find_by_sql("SELECT * FROM `mpn_items` WHERE `mpn` LIKE '%"+mpn+"%'").first
        Rails.logger.info("mpn_item--------------------------------------------------------------------------mpn_item")
        Rails.logger.info(mpn_item.inspect)   
        Rails.logger.info("mpn_item--------------------------------------------------------------------------mpn_item") 
        if mpn_item.blank?
            url = 'http://octopart.com/api/v3/parts/match?'
            url += '&queries=' + URI.encode(JSON.generate([{:mpn => mpn}]))
            url += '&apikey=809ad885'
            url += '&include[]=descriptions'
            url += '&include[]=datasheets'

            resp = Net::HTTP.get_response(URI.parse(url))
            server_response = JSON.parse(resp.body)
            Rails.logger.info("prices_all--------------------------------------------------------------------------")
            Rails.logger.info(server_response['results'].inspect)   
            Rails.logger.info("prices_all--------------------------------------------------------------------------")     
            prices_all = []
            naive_id_all = []
            server_response['results'].each do |result|
                result['items'].each do |part|
                    for f in part['offers']      
                        if f['prices'].has_key?"USD"
                            for p in f['prices']['USD']
                                prices_all << p[-1].to_f
                                naive_id_all << f['_naive_id']
                            end
                        end
                    end
                end
            end
            Rails.logger.info("prices_all--------------------------------------------------------------------------")
            Rails.logger.info(prices_all.inspect)   
            Rails.logger.info("prices_all--------------------------------------------------------------------------")    
            @api_result = []
            if not prices_all == []
                naive_id= naive_id_all[(prices_all.index prices_all.min)]
                
                mpn_new = MpnItem.new
                server_response['results'].each do |result|
                    result['items'].each do |part|
                        if part['mpn'].upcase == mpn.upcase
                            Rails.logger.info("part['mpn']------------------------------------------------------------------part['mpn']")
                            Rails.logger.info(part['mpn'].inspect) 
                            #Rails.logger.info(part['datasheets'][0].inspect)   
                            Rails.logger.info("part['mpn']------------------------------------------------------------------part['mpn']") 
                            @api_result << part['mpn']
                            #mpn_new.mpn = part['mpn']
                            mpn_new.mpn = mpn
                            if part['datasheets'] != []
                                mpn_new.datasheets = part['datasheets'][0]['url']
                            else
                                mpn_new.datasheets = nil   
                            end
                            @api_result << part['brand']['name'] 
                            mpn_new.manufacturer = part['brand']['name'] 
                            for f in part['offers']
                                if f['_naive_id'] == naive_id

                                    @api_result << f['seller']['name'] 
                                    mpn_new.authorized_distributor = f['seller']['name'] 
                                    d_value = ""
                                    for d in part['descriptions']     
                                        #if d['attribution']['sources'][0]['name'] == f['seller']['name']Digi-Key
                                        if d['attribution']['sources'][0]['name'] == "Digi-Key"
                                            d_value = d['value'] 
                                        end
                                    end
                                    if d_value == ""
                                        if d['attribution']['sources'][0]['name'] == f['seller']['name']
                                        #if d['attribution']['sources'][0]['name'] == "Digi-Key"
                                            d_value = d['value'] 
                                        end  
                                    end
                                    if d_value == ""
                                        if d['value'] != ""
                                        #if d['attribution']['sources'][0]['name'] == "Digi-Key"
                                            d_value = d['value'] 
                                        end  
                                    end
                                    @api_result << d_value
                                    @api_result << f['prices']['USD'][-1][-1]
                                    mpn_new.description = d_value
                                    mpn_new.price = f['prices']['USD'][-1][-1]
                                end
                            end  
                        end
                    end
                end
                
                mpn_new.save
                @api_result << mpn_new.datasheets
                @api_result << mpn_new.id
                #result = api_result
            end
        else
            @api_result = []
            @api_result << mpn_item['mpn']
            @api_result << mpn_item['manufacturer'] 
            @api_result << mpn_item['authorized_distributor']
            @api_result << mpn_item['description']
            @api_result << mpn_item['price']
            @api_result << mpn_item['datasheets']
            @api_result << mpn_item['id']
        end
        #result = @api_result
        #render "search_api.js.erb"
    end

  	### private methods

    def mpn
        if not params[:bom_data].blank?
            if not params[:bom_data][1..-2][1..-2].blank?
                @all_bom_data = params[:bom_data][1..-2][1..-2].split("],[")
                Rails.logger.info("@all_bom_data-----------------------------------------------------@all_bom_data")
                Rails.logger.info(@all_bom_data)
                Rails.logger.info("@all_bom_data---------------------------------------------------@all_bom_data")           
            end
        end
        @bom = Bom.find(params[:id])
        Rails.logger.info("aaaaaaaaaaaaaaaaaaaaaaaaaaaa")
        Rails.logger.info(@bom.inspect)
        Rails.logger.info("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
        #file_name = @bom.excel_file.to_s.scan(/[^\/]+\.xls$/).join('')
        file_name = @bom.excel_file.to_s.scan(/[^\/]+$/).join('').split(".xls")[0]+".xls"
        path = Rails.root.to_s+"/public/uploads/bom/excel_file/"

        respond_to do |format|

            format.html {
                Rails.logger.info("cccccccccccccccccccccccccccccccccccccccccccccccccccc11111q")
                #Rails.logger.info(Product.find(@bom.bom_items.first.product_id).inspect)
                Rails.logger.info("cccccccccccccccccccccccccccccccccccccccccccccccc1111111q")
                #matched_items = @bom.bom_items.select { |item| item.product }
                #matched_items = @bom.bom_items.select { |item| return Product.find(item.product_id) unless item.product_id.blank?}
                @matched_items = Product.find_by_sql("
SELECT
	bom_items.id,
	bom_items.quantity,
	bom_items.description,
	bom_items.part_code,
	bom_items.bom_id,
	bom_items.product_id,
	bom_items.created_at,
	bom_items.updated_at,
	bom_items.warn,
	bom_items.user_id,
	bom_items.danger,
	bom_items.manual,
	bom_items.mark,
	bom_items.mpn,
	bom_items.mpn_id,

IF (

	bom_items.mpn_id > 0,
	mpn_items.price,
	products.price
) AS price,


IF (
	bom_items.mpn_id > 0,
	mpn_items.description,
	products.description
) AS description_p
FROM
	bom_items
LEFT JOIN products ON bom_items.product_id = products.id
LEFT JOIN mpn_items ON bom_items.mpn_id = mpn_items.id

WHERE
	bom_items.bom_id = "+params[:id])
                #@bom.bom_items.each do |item|
                    #unless item.product_id.blank?
                        #matched_items << Product.find(item.product_id)
                    #end   
                #end
                #begin
                #    matched_items = @bom.bom_items.select { |item| Product.find(item.product_id).blank? }
                #rescue
                   # matched_items = []
                #end

                Rails.logger.info("cccccccccccccccccccccccccccccccccccccccccccccccccccc111111")
                
                Rails.logger.info("cccccccccccccccccccccccccccccccccccccccccccccccccccc22222")
                Rails.logger.info("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb")
                Rails.logger.info(@matched_items)
                Rails.logger.info("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb22222222222222222222")
		@match_str = "#{@bom.bom_items.count('product_id')+@bom.bom_items.count('mpn_id')} / #{@bom.bom_items.count}"
		@total_price = 0.00
                #Rails.logger.info(matched_items.inspect)
                Rails.logger.info(@match_str.inspect)
                Rails.logger.info(@total_price.inspect)
                Rails.logger.info("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb22222222222222222")
		unless @matched_items.empty?
                    @bom_api_all = []
		    @matched_items.each do |item|
                        if not item.price.blank?
                            @total_price += item.price * item.quantity  
                        end
                        #if item.product_id.blank?
                            #if not item.mpn.blank?
                                #bom_api = search_in_api(item.mpn)
                                #if not bom_api == []
                                    #bom_api << item.id
                                    #@bom_api_all << bom_api
                                #end
                            #end    
                        #end 
		    end
                    Rails.logger.info("@bom_api_all_________________________________________________________")
                    Rails.logger.info(@bom_api_all.inspect)
                    Rails.logger.info("@bom_api_all---------------------------------------------------------")
		end
		    }

	    format.xls { 
                Spreadsheet.client_encoding = 'UTF-8'
		ff = Spreadsheet::Workbook.new

		sheet1 = ff.create_worksheet

		sheet1.row(0).concat %w{No Intention_product Location_code Matching_products Material_code unit_price quantity total_price}

		@bom.bom_items.each_with_index do |item,index|
		    rowNum = index+1
                    title_format = Spreadsheet::Format.new({
                    :weight           => :bold,
                    :pattern_bg_color => :red,
                    :size             => 10,
                    :color => :red
                    })
		    row = sheet1.row(rowNum)
                    if item.warn
                        #[0,1,2,3,4,5,6,7].each{|col|
                        row.set_format(2,title_format)
                        #row.default_format = color
                        #}
                    end
		    row.push(rowNum)
		    row.push(item.description)
		    row.push(item.part_code)
		    row.push(item.product_id.nil?? "" : Product.find(item.product_id).description)
		    row.push(item.product_id.nil?? "" : Product.find(item.product_id).name)
		    row.push(item.product_id.nil?? "" : Product.find(item.product_id).price)
		    row.push(item.quantity)
		    row.push(item.product_id.nil?? "" : Product.find(item.product_id).price*item.quantity)
                end
                ff.write (path+file_name)              
                send_file(path+file_name, type: "application/vnd.ms-excel")
                #file_contents = StringIO.new
	        #ff.write (file_contents)
	        #send_data(file_contents.string.force_encoding('binary'), filename: file_name)
            }
        end
        
    end

    def s_mpn
        bom_items = BomItem.find_by_sql("SELECT * FROM bom_items WHERE bom_items.bom_id = "+params[:id].to_s)
        bom_items.each do |bom|
            find_mpn = search_in_api(bom.mpn)

            if find_mpn != []
                @bom_item = BomItem.find(bom.id) #取回bom_items表bomitem记录，在解析bom是存入，可能没有匹配到product
                if @bom_item.update_attribute("mpn_id", find_mpn[-1])
                    if @bom_item.mpn_id
	                #@bom_item.product = Product.find(@bom_item.product_id)
                        @bom_item.warn = false
                        @bom_item.mark = false
                        @bom_item.manual = true
	                @bom_item.save!
                        
                        #flash[:success] = t('success_a')                   
                        #render "choose.js.erb"
	            end
                end     
            end



        end
        #flash.now[:alert] = "MPN of query is done"
        #redirect_to(:back)
        #redirect_to action: "mpn", id: params[:id].to_s
        redirect_to boms_mpn_path(id: params[:id].to_s, new: "yes" ),  notice: "MPN of query is done!"
        #redirect_to action: "upload"
        #render ()  
    end

    def mpn_item
        @mpn_item = MpnItem.find_by_sql("SELECT * FROM `mpn_items` WHERE `mpn` ='" + params[:mpn]+"'").first
    end

    def des_item
        @des_item = Product.find_by_sql("SELECT * FROM `products` WHERE `description` ='" + params[:mpn]+"'").first
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
                                        Rails.logger.info("--------------------------")
                                        Rails.logger.info(f['price'].to_f.inspect)
                                        mf_all << part['manufacturer']
                                        Rails.logger.info("--------------------------")
                                        Rails.logger.info(part['manufacturer'].inspect)
                                        dm_all << result['distributor']['name']
                                        Rails.logger.info("--------------------------")
                                        Rails.logger.info(result['distributor']['name'].inspect)
                                    end
                                    #naive_id_all << result['distributor']['id']                         
                                end
                            end
                            #mpn_stock += part['stock'].to_i
                        end  
                    end                                
                end
                Rails.logger.info("--------------------------")
                Rails.logger.info(mpn_id.inspect)
                Rails.logger.info(prices_all.inspect)
                Rails.logger.info(mf_all.inspect)
                Rails.logger.info(dm_all.inspect)
                Rails.logger.info("--------------------------")
                @mpn_result = []
                if not prices_all.blank?
                    @mpn_result << prices_all.min     
                    @mpn_result << mf_all[(prices_all.index prices_all.min)]   
                    @mpn_result << dm_all[(prices_all.index prices_all.min)]
                end
                result = @mpn_result
            end
        end
 
        def search_findchips(mpn)
            #mpn = "LM2937IMP"
            url = 'http://api.findchips.com/v1/search?apiKey=RDQCwiQN4yhvRYKulcgw&part='
            url += mpn
            Rails.logger.info(mpn.inspect)
            resp = Net::HTTP.get_response(URI.parse(url))
            server_response = JSON.parse(resp.body)
            Rails.logger.info("prices_all--------------------------------------------------------------------------")
            #Rails.logger.info(url.inspect) 
            #Rails.logger.info(resp.code.inspect)                #"200"   
            #Rails.logger.info(resp.content_length.inspect)      #8023   
            #Rails.logger.info(resp.message.inspect)             #"OK"       
            #Rails.logger.info(server_response.inspect)   
            Rails.logger.info("prices_all--------------------------------------------------------------------------")   
            Rails.logger.info("prices_all222222222222222222222222222222222222222222222222222222222222222222222222222") 
            #Rails.logger.info(server_response['response'].inspect)
            Rails.logger.info("prices_all22222222222222222222222222222222222222222222222222222222222222222222") 
            server_response['response'].each do |item|
                Rails.logger.info("prices_44444444444444444444444444444444444")
                Rails.logger.info(item.inspect)
            end            
        end

        def bom_params
  	    params.require(:bom).permit(:name, :excel_file)
  	end
        
        def search_bom_use (query_str,mpn)
            if query_str != ""
                result = MpnItem.find_by_sql("SELECT bom_items.*, products.* FROM products INNER JOIN bom_items ON bom_items.product_id = products.id WHERE bom_items.description = '" + query_str.to_s.strip + "' ORDER BY products.prefer DESC")
            elsif query_str == "" and mpn != ""
                result = MpnItem.find_by_sql("SELECT bom_items.*, mpn_items.* FROM mpn_items INNER JOIN bom_items ON bom_items.mpn = mpn_items.mpn WHERE bom_items.mpn_id IS NOT NULL AND bom_items.mpn = '" + mpn.to_s.strip + "' ")
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
            value2_test = query_str.to_s.scan(/[0-9]*[uUnNpPmM][0-9]/)            
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
            Rails.logger.info("0000000000000000000000000000000000000bbbbb")
            Rails.logger.info(query_str)
            Rails.logger.info(part_code)
            Rails.logger.info("0000000000000000000000000000000000000bbbbb")
            part = Part.find_by(part_code: part_code)
            
            #if  ( part_code[0] =~ /[Cc]/ )
            if  ( part and part.part_name == "CAP" )
                Rails.logger.info("ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc")
                Rails.logger.info("ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc")
                Rails.logger.info("ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc")
                if query_str =~ /[Μμ]/
                    query_str.gsub!(/[Μμ]/, "u")
                end
                if query_str.include?".0uF"
                    query_str[".0uF"]="uF"
                elsif query_str.include?"0.1uF"
                    query_str["0.1uF"]="100nF"
                elsif query_str.include?"0.1UF"
                    query_str["0.1UF"]="100nF"
                elsif query_str.include?"μ"
                    query_str["μ"]="u"
                end
                if query_str.include?"Y5V"    
                    query_str["Y5V"]=""
                end 
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
