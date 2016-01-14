require 'roo'
require 'spreadsheet'

class BomsController < ApplicationController
skip_before_action :verify_authenticity_token
before_filter :authenticate_user!, :except => [:upload]
    def index
        #@boms = Bom.all
        if current_user.email == "web@mokotechnology.com"
            @boms = Bom.find_by_sql("SELECT * FROM `boms` ORDER BY `id` DESC")
        else
            @boms = Bom.find_by_sql("SELECT * FROM `boms` WHERE `user_id` = '" + current_user.id.to_s + "' AND `name` IS NULL ORDER BY `id` DESC")
        end
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        Rails.logger.info(@boms.inspect)
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
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
        file_name = @bom.excel_file.to_s.scan(/[^\/]+\.xls$/).join('')
    

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
		@match_str = "#{@bom.bom_items.count('product_id')} / #{@bom.bom_items.count}"
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

                file_contents = StringIO.new
	        ff.write (file_contents)
	        send_data(file_contents.string.force_encoding('binary'), filename: file_name)
            }
        end

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
                match_product = search_bom(desc,part_code) #根据关键字和位号查询产品
                bom_item.product_id = match_product.first.id if match_product.count > 0
                
                Rails.logger.info("ccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000")
                #Rails.logger.info(match_product.inspect)   
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
	    redirect_to action: 'upload', notice: t('file') + " #{@bom.name} " + t('error_e')
	end
    end

    def destroy
	 @bom = Bom.find(params[:id])
	 @bom.name = "del"
         @bom.save
	 redirect_to boms_path, notice:  "BOM #{@bom.name} " + t('success_c')
    end
   
    def mark
	 @bom_item = BomItem.find(params[:id])
	 @bom_item.product_id = nil
         @bom_item.mpn_id = nil
         @bom_item.mark = true
         @bom_item.save
	 #redirect_to :back
         #redirect_to bom_path(@bom_item.bom, :anchor => "Comment", :bomitem => @bom_item.id );
         render "mark_local.js.erb"
    end    

    def upload
        @bom = Bom.new
        @mpn_show = MpnItem.find_by_sql("SELECT * FROM `mpn_items` LIMIT 0, 30")
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
            if @bom_item.update_attribute("mpn_id", params[:mpn_id])
                if @bom_item.mpn_id
	            #@bom_item.product = Product.find(@bom_item.product_id)
                    @bom_item.warn = false
                    @bom_item.mark = false
                    @bom_item.manual = true
	            @bom_item.save!
 
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
        mpn_item = MpnItem.find_by_sql("SELECT * FROM `mpn_items` WHERE `mpn` LIKE '%"+mpn+"%'").first
        Rails.logger.info("mpn_item--------------------------------------------------------------------------mpn_item")
        Rails.logger.info(mpn_item.inspect)   
        Rails.logger.info("mpn_item--------------------------------------------------------------------------mpn_item") 
        if mpn_item.blank?
            url = 'http://octopart.com/api/v3/parts/match?'
            url += '&queries=' + URI.encode(JSON.generate([{:mpn => mpn}]))
            url += '&apikey=809ad885'
            url += '&include[]=descriptions'
     
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
            api_result = []
            if not prices_all == []
                naive_id= naive_id_all[(prices_all.index prices_all.min)]
                
                mpn_new = MpnItem.new
                server_response['results'].each do |result|
                    result['items'].each do |part|
                        if part['mpn'].upcase == mpn.upcase
                            Rails.logger.info("part['mpn']------------------------------------------------------------------part['mpn']")
                            Rails.logger.info(part['mpn'].inspect)   
                            Rails.logger.info("part['mpn']------------------------------------------------------------------part['mpn']") 
                            api_result << part['mpn']
                            mpn_new.mpn = part['mpn']
                            api_result << part['brand']['name'] 
                            mpn_new.manufacturer = part['brand']['name'] 
                            for f in part['offers']
                                if f['_naive_id'] == naive_id
                                    api_result << f['seller']['name'] 
                                    mpn_new.authorized_distributor = f['seller']['name'] 
                                    d_value = ""
                                    for d in part['descriptions']     
                                        if d['attribution']['sources'][0]['name'] == f['seller']['name']
                                            d_value = d['value'] 
                                        end
                                    end
                                    api_result << d_value
                                    api_result << f['prices']['USD'][-1][-1]
                                    mpn_new.description = d_value
                                    mpn_new.price = f['prices']['USD'][-1][-1]
                                end
                            end  
                        end
                    end
                end
                mpn_new.save
                api_result << mpn_new.id
                #result = api_result
            end
        else
            api_result = []
            api_result << mpn_item['mpn']
            api_result << mpn_item['manufacturer'] 
            api_result << mpn_item['authorized_distributor']
            api_result << mpn_item['description']
            api_result << mpn_item['price']
            api_result << mpn_item['id']
        end
        result = api_result
    end

    def search_api
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
        file_name = @bom.excel_file.to_s.scan(/[^\/]+\.xls$/).join('')
    

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
		@match_str = "#{@bom.bom_items.count('product_id')} / #{@bom.bom_items.count}"
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

                file_contents = StringIO.new
	        ff.write (file_contents)
	        send_data(file_contents.string.force_encoding('binary'), filename: file_name)
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

    private

        def bom_params
  	    params.require(:bom).permit(:name, :excel_file)
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
                    if query_str.to_s =~ /t491/i or query_str.to_s =~ /tantalum/i
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
                            elsif params[:q].to_s =~ /red/i 
                                result_w = Product.find_by_sql("SELECT * FROM `products` WHERE `value1` = '红灯' AND `part_name` = 'LED'"+find_led_p).to_ary
                            elsif params[:q].to_s =~ /blue/i 
                                result_w = Product.find_by_sql("SELECT * FROM `products` WHERE `value1` = '蓝灯' AND `part_name` = 'LED'"+find_led_p).to_ary
                            elsif params[:q].to_s =~ /yellow/i 
                                result_w = Product.find_by_sql("SELECT * FROM `products` WHERE `value1` = '黄灯' AND `part_name` = 'LED'"+find_led_p).to_ary
                            elsif params[:q].to_s =~ /white/i 
                                result_w = Product.find_by_sql("SELECT * FROM `products` WHERE `value1` = '白灯' AND `part_name` = 'LED'"+find_led_p).to_ary
                            elsif params[:q].to_s =~ /orange/i 
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
                ary_q = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                ary_q[3] = "IC"
            elsif  ( part and part.part_name == "Q" )
                Rails.logger.info("QQQ---------------------------------------------------------QQQ")              
                ary_q = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                ary_q[3] = "Q"
            elsif  ( part and part.part_name == "D" )
                Rails.logger.info("DDD---------------------------------------------------------DDD")
                ary_q = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                ary_q[3] = "D"
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
