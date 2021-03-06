require 'rubygems'
require 'json'
require 'net/http'
require 'will_paginate/array'
class BomItemController < ApplicationController
skip_before_action :verify_authenticity_token
    #respond_to :json, :html
    def add
        Rails.logger.info("add-------------------------------------add")
        Rails.logger.info(params.inspect)
        Rails.logger.info("add-------------------------------------add")
        if params[:part_a] == "" or params[:part_b] == "" or params[:part_c] == "" or params[:abc] == ""
            flash[:error] = "Part information can not be empty!!!"
            redirect_to :back
        else
            name_a = "A." + params[:part_a].upcase + "." + params[:part_b].upcase + ".F."
            part_name_find = Product.find_by_sql("SELECT LPAD((MAX(SUBSTRING_INDEX(SUBSTRING_INDEX(products.`name`, '.' ,-1) , '-' ,1))+1 ) ,4,'0') AS part_n   FROM products WHERE `name` LIKE '%"+ name_a +"%'")
            if part_name_find.first.part_n.blank?
               part_name_find = "0001"
            else
               part_name_find = part_name_find.first.part_n.to_s
            end
            new_part = Product.new do |part|
                part.name = name_a + part_name_find.to_s + "-" + params[:package2][:package2]
                part.description = params[:part_c]
                part.part_name = params[:part_c].split[0]
                part.ptype = params[:abc]
                part.package1 = params[:part_b].upcase
                part.package2 = params[:package2][:package2]
                part.value1 = params[:part_c].split[0]
                part.value2 = params[:part_c].split[1]
                part.value3 = params[:part_c].split[2]
                part.value4 = params[:part_c].split[3]
            end
            if new_part.save
                flash[:success] = "New part success"
                redirect_to :back
            end
        end
        
        
    end

    def select_with_ajax        
        @fengzhuang = Product.find_by_sql("SELECT products.part_name, products.package2 FROM products GROUP BY products.package2 HAVING products.part_name = '"+ params[:abc] + "'").collect { |product| [product.package2, product.package2] } 
        render(:layout => false)    
    end

    def edit
        if cookies.permanent[:educator_locale].to_s == "zh"
            part_name_locale = "part_name"
        elsif cookies.permanent[:educator_locale].to_s == "en"
            part_name_locale = "part_name_en"
        end
        #@fengzhuang = Product.find_by_sql("SELECT products.ptype, products.package2 FROM products GROUP BY products.package2 HAVING products.ptype = "+ params[:parent_id])
        @bom_item = BomItem.find(params[:id])
        Rails.logger.info("wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        Rails.logger.info(params[:q].inspect)
        Rails.logger.info("wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        Rails.logger.info(@bom_item.inspect)
        Rails.logger.info("wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
	if params[:q].nil? 
	    params[:q]=@bom_item.description
	    params[:p]=@bom_item.part_code
            Rails.logger.info("111111111111111111111111111111111111111111111111111111")
            Rails.logger.info(params[:q])
            Rails.logger.info("222222222222222222222222222222222222222222222222222")
            Rails.logger.info(params[:p])
            Rails.logger.info("333333333333333333333333333333333333333333333333333")
	    @match_products = search(@bom_item.description,@bom_item.part_code)
            #Rails.logger.info(@match_products.inspect)
            Rails.logger.info("333333333333333333333333333333333333333333333333333")
	    #计算相同类别和封装的个数
	    @counted = Hash.new(0)
            @match_products.each { |h| @counted[h["part_name"]] += 1 }
            @counted = Hash[@counted.map {|k,v| [k,v.to_s] }]	
				
            @counted1 = Hash.new(0)
            @match_products.each { |h| @counted1[h["package2"]] += 1 }
            @counted1 = Hash[@counted1.map {|k,v| [k,v.to_s] }]	
        else
	    #str = get_query_str(params[:q])
	    #获取位号
	    part_code = params[:p]
	    ary2 = part_code.upcase.to_s.scan(/[A-Z]+/)
	    part_code = ary2[0]
            str = get_query_str_new(params[:q].to_s,part_code)
            if str.split(" ")[0] == "nothing"
                str = params[:q].to_s
            end
            Rails.logger.info("4444444444444444444444444444444444444444")
            Rails.logger.info(params[:q])
            Rails.logger.info(str.split(" ")[0].inspect)
            Rails.logger.info("5555555555555555555555555555555555555")
            Rails.logger.info(params[:p])
            Rails.logger.info("666666666666666666666666666666")
            Rails.logger.info(ary2)
            Rails.logger.info("7777777777777777777777777777777777777777777")
            #类别和封装筛选处理，
            #ptype和package2都没有时表示用户刚进入查询页面；package2为空时，用户选择了ptype；ptype为空时，用户选择了package2；两个都有值表示先选择ptype再选择pacakge2
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
			  
            #根据位号获取对应的原件类型
	    part = Part.find_by(part_code: part_code)
            Rails.logger.info("t0000000000000000000000000000000000000000000000000000000000000")
            Rails.logger.info(part_code)
            Rails.logger.info("t0000000000000000000000000000000000000000000000000000000000000")
	    if part
                Rails.logger.info("t11111111111111111111111111111111111111111111111111111111")
                Rails.logger.info(part.inspect)
                Rails.logger.info("t11111111111111111111111111111111111111111111111111111111")
                Rails.logger.info(str.inspect)
                Rails.logger.info(part.part_name.inspect)
                Rails.logger.info(@ptype.inspect)
                Rails.logger.info(@package2.inspect)
                Rails.logger.info("t11111111111111111111111111111111111111111111111111111111")
                #全文检索产品，用价格作为排序条件
                if part.part_name == "CAP" or part.part_name == "RES"
                    if str.split(" ")[0] == "nothing" 
                        str = get_query_str(params[:q].to_s)
                        @ptype = "" 
                    end 
                    if not str.split(" ")[2].blank?
                        if str.split(" ")[2] != "nothing" 
                            #@ptype = part.part_code
	                    @package2 = str.split(" ")[2]
                        end
                    end
                end

                #if part.part_name == "SW"
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
                    #sql_b = " ORDER BY `prefer` DESC" 
                    sql_b = "" 
                end
                tan_tag = ""
                if params[:q].to_s =~ /t491/i or params[:q].to_s =~ /tant/i
                    #sql_a = sql_a  + " AND `part_name` = '钽电容'" 
                    if cookies.permanent[:educator_locale].to_s == "zh"
                        sql_a = sql_a  + " AND `part_name` = '钽电容'" 
                    elsif cookies.permanent[:educator_locale].to_s == "en"
                        sql_a = sql_a  + " AND `part_name_en` = 'Tantalum capacitor'" 
                    end
                    tan_tag = "tan" 
                elsif params[:q].to_s =~ /radial/i   
                    #sql_a = sql_a  + " AND `part_name` = '电解电容'" 
                    if cookies.permanent[:educator_locale].to_s == "zh"
                        sql_a = sql_a  + " AND `part_name` = '电解电容'" 
                    elsif cookies.permanent[:educator_locale].to_s == "en"
                        sql_a = sql_a  + " AND `part_name_en` = 'Ele capacitor'" 
                    end
                    tan_tag = "tan"  
                #elsif params[:q].to_s =~ /led/i   
                    #sql_a = sql_a  + " AND `part_name` = 'LED'" 
                    #tan_tag = "tan"   
                #elsif params[:q].to_s =~ /SMD/i   
                    #sql_a = sql_a  + " AND `value1` LIKE '%贴片%'" 
                    #tan_tag = "tan"                 
                end
                if  @package2 != ""
                    find_bom = " AND `package2` = '"+@package2+"' "
                else
                    find_bom = " "
                end
                Rails.logger.info(part.part_name.inspect)
                Rails.logger.info(@ptype.inspect)
                Rails.logger.info(@package2.inspect)
                Rails.logger.info("t11111111111111111111111111111111111111111111111111111111")
                Rails.logger.info("str--------------------------------------------------str")
                Rails.logger.info(str.inspect)
                Rails.logger.info("str--------------------------------------------------str")
                if str.split(" ")[1] == "nothing" or tan_tag == "tan"
                    #如果没有电压
                    Rails.logger.info("000000000000000000000000----------------------------------tan")
                    #@match_products = Product.find_by_sql(sql_a+" AND `ptype` = '"+str.split(" ")[-1]+"' AND `part_name` LIKE '%"+@ptype+"%' AND `package2` LIKE '%"+@package2+"%' ORDER BY `prefer` DESC").to_ary
                    @match_products = Product.find_by_sql(sql_a+" AND `ptype` = '"+str.split(" ")[-1]+"' AND `" + part_name_locale + "` LIKE '%"+@ptype+"%'" + find_bom).to_ary
                else
                    #如果有电压 电压在value3
                    Rails.logger.info("1")
                    #match_products_w = Product.find_by_sql(sql_a+" AND `value3` = '"+str.split(" ")[1]+"' AND `ptype` = '"+str.split(" ")[-1]+"' AND `part_name` LIKE '%"+@ptype+"%' AND `package2` LIKE '%"+@package2+"%' ORDER BY `prefer` DESC").to_ary
                    match_products_w = Product.find_by_sql(sql_a+" AND `value3` = '"+str.split(" ")[1]+"' AND `ptype` = '"+str.split(" ")[-1]+"' AND `" + part_name_locale + "` LIKE '%"+@ptype+"%'" + find_bom).to_ary
                    if match_products_w.blank?
                        #如果没查到 电压换成50V
                        Rails.logger.info("2")
                        if (part_code[0] =~ /[Cc]/ and str.split(" ")[0]=~ /[^uU]/)
                            #@match_products = Product.find_by_sql(sql_a+" AND `value3` = '50v' AND `ptype` = '"+str.split(" ")[-1]+"' AND `part_name` LIKE '%"+@ptype+"%' AND `package2` LIKE '%"+@package2+"%' ORDER BY `prefer` DESC").to_ary
                            @match_products = Product.find_by_sql(sql_a+" AND `value3` = '50v' AND `ptype` = '"+str.split(" ")[-1]+"' AND `" + part_name_locale + "` LIKE '%"+@ptype+"%'" + find_bom).to_ary
                        else
                            #没查到去掉电压
                            Rails.logger.info("3")
                            #@match_products = Product.find_by_sql(sql_a+" AND `ptype` = '"+str.split(" ")[-1]+"' AND `part_name` LIKE '%"+@ptype+"%' AND `package2` LIKE '%"+@package2+"%' ORDER BY `prefer` DESC").to_ary 
                            @match_products = Product.find_by_sql(sql_a+" AND `ptype` = '"+str.split(" ")[-1]+"' AND `" + part_name_locale + "` LIKE '%"+@ptype+"%'" + find_bom).to_ary 
                        end
                    else
                        Rails.logger.info("4")
                        @match_products = match_products_w 
                    end
                end
		#@match_products = Product.search(str,conditions: {part_name: part.part_name, ptype: @ptype, package2: @package2},star: true, order: 'prefer DESC').to_ary
  	        
  	        #如果匹配不到产品，则只使用关键字串全局匹配，不需要匹配原件类型
  	  	if @match_products.length == 0
                    Rails.logger.info("5")
                    Rails.logger.info("t22222222222222222222222222222222222222222222222222222222222222222")
                    #@match_products = Product.find_by_sql("SELECT * FROM `products` WHERE `description` LIKE '%"+str.split(" ")[0]+"%' AND `part_name` LIKE '%"+@ptype+"%' AND `package2` LIKE '%"+@package2+"%' ORDER BY `prefer` DESC").to_ary
                    if params[:q].to_s =~ /res/i
                        @match_products = Product.find_by_sql("SELECT * FROM `products` WHERE `description` LIKE '%"+str.split(" ")[0]+"%' AND `ptype` = 'RES' AND `" + part_name_locale + "` LIKE '%"+@ptype+"%'" + find_bom).to_ary
                    else
                        @match_products = Product.find_by_sql("SELECT * FROM `products` WHERE `description` LIKE '%"+str.split(" ")[0]+"%' AND `" + part_name_locale + "` LIKE '%"+@ptype+"%'" + find_bom).to_ary              
                    end 
                    #@match_products = Product.find_by_sql("SELECT * FROM `products` WHERE `description` LIKE '%"+str.split(" ")[0]+"%' AND `part_name` LIKE '%"+@ptype+"%' AND `package2` LIKE '%"+@package2+"%' ").to_ary
                    
  	  	    #@match_products = Product.search(str,conditions: {ptype: @ptype, package2: @package2},star: true,order: 'prefer DESC').to_ary	
  	  	    #如果全局匹配不到，则需要检查关键字串中的单位，转换成标准的单位
  	  	    if @match_products.length == 0
                        Rails.logger.info("6")
                        #if not @bom_item.mpn.blank?
                            #@bom_api = search_in_api(@bom_item.mpn)
                        #end
  	  		Rails.logger.info("t333333333333333333333333333333333333333333333333333333333333")
  	                #匹配出单位的字符串
  	  		ary_unit = str.scan(/([a-zA-Z]+)/)
                        Rails.logger.info("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb")
                        Rails.logger.info(str)
                        Rails.logger.info("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb")
                        Rails.logger.info("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1")
                        Rails.logger.info(ary_unit)
                        Rails.logger.info("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1")
  	  		#如果匹配出多个，则提示错误
                        if ary_unit.length > 1
                            Rails.logger.info("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2")
                            Rails.logger.info(ary_unit)
                            Rails.logger.info("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2")
  	  		    #flash[:error] = t('error_a')
  	  		      
  	  		else
  	  		    #从unit表查找对应的目标单位字符串
  	  		    ary_unit = ary_unit.join("")
  	  		    unit = Unit.find_by(unit: ary_unit)
  	  		    unless unit
  	  		        #flash[:error] = t('error_b') 
                                Rails.logger.info(t('error_b'))    	  		        
  	  		    else
  	  		        #用查询得到的标准单位替换关键字串中的单位
  	  		        str.sub!(/[a-zA-Z]+/, unit.targetunit)
  	  		        #@match_products = Product.search(str,conditions: {part_name: part.part_name, ptype: @ptype, package2: @package2},star: true,order: 'prefer DESC').to_ary 
                                @match_products = Product.search(str,conditions: {part_name: part.part_name, ptype: @ptype, package2: @package2},star: true).to_ary 
  	  		        if @match_products.length == 0
  	                            #全局匹配
  			            #@match_products = Product.search(str,conditions: {ptype: @ptype, package2: @package2},star: true,order: 'prefer DESC').to_ary               
                                    @match_products = Product.search(str,conditions: {ptype: @ptype, package2: @package2},star: true).to_ary                    
     		                    if @match_products.length == 0
	  		                #flash[:error] = t('error_c')
                                        Rails.logger.info(t('error_c'))
	  		            end
  	  		        end
  	  		    end
  	  		end
  	            end
  	        end
  	       #输出查询的关键串到网页上显示				
		@query_str = str +" with part_name: "+ str.split(" ")[-1]
            else
                Rails.logger.info("7")
                if params[:q].to_s =~ /led/i
                    led_package2_all = Product.find_by_sql("SELECT products.package2, products.ptype FROM products WHERE products.ptype = 'LED' AND products.package2 <> '' GROUP BY products.package2 ")
                    led_p_all = led_package2_all.select { |item| params[:q].to_s.include?item.package2.to_s }
                    if not led_p_all.blank?
                        Rails.logger.info("led_p_all.first.package2__________0000000000000000000000000000000000000bbbbb_________")
                        Rails.logger.info(led_p_all.first.package2)
                        Rails.logger.info("led_p_all.first.package2_________0000000000000000000000000000000000000bbbbb______________________") 
                        led_package = led_p_all.first.package2
                        find_led_p = " AND `package2` = '"+led_package.to_s+"'"                
                    else
                        find_led_p = ""
                    end 
                    if params[:q].to_s =~ /green/i 
                        @match_products = Product.find_by_sql("SELECT * FROM `products` WHERE `value1` = '绿灯' AND `part_name` = 'LED'"+find_led_p).to_ary
                    elsif params[:q].to_s =~ /red/i 
                        @match_products = Product.find_by_sql("SELECT * FROM `products` WHERE `value1` = '红灯' AND `part_name` = 'LED'"+find_led_p).to_ary
                    elsif params[:q].to_s =~ /blue/i 
                        @match_products = Product.find_by_sql("SELECT * FROM `products` WHERE `value1` = '蓝灯' AND `part_name` = 'LED'"+find_led_p).to_ary
                    elsif params[:q].to_s =~ /yellow/i 
                        @match_products = Product.find_by_sql("SELECT * FROM `products` WHERE `value1` = '黄灯' AND `part_name` = 'LED'"+find_led_p).to_ary
                    elsif params[:q].to_s =~ /white/i 
                        @match_products = Product.find_by_sql("SELECT * FROM `products` WHERE `value1` = '白灯' AND `part_name` = 'LED'"+find_led_p).to_ary
                    elsif params[:q].to_s =~ /orange/i 
                        @match_products = Product.find_by_sql("SELECT * FROM `products` WHERE `value1` = '橙灯' AND `part_name` = 'LED'"+find_led_p).to_ary
                    else
                        @match_products = Product.find_by_sql("SELECT * FROM `products` WHERE `description` LIKE '%"+str.split(" ")[0]+"%' AND `part_name` = 'LED'"+find_led_p).to_ary
                    end
                elsif params[:q].to_s =~ /螺丝端子/i or params[:q].to_s =~ /简牛/i or params[:q].to_s =~ /排针/i or params[:q].to_s =~ /排母/i or params[:q].to_s =~ /晶振/i or params[:q].to_s =~ /电感/i or params[:q].to_s =~ /开关/i
                    @match_products = Product.find_by_sql("SELECT * FROM `products` WHERE `" + part_name_locale + "` LIKE '%"+params[:q].to_s.split(" ")[0]+"%' AND `value2`  like '%"+params[:q].to_s.split(" ")[1]+"%' AND `value3`  LIKE '%"+params[:q].to_s.split(" ")[2]+"%' ").to_ary
                else
                    find_bom = ""
                    if  @package2 != ""
                        find_bom = " AND `package2` = '"+@package2+"'  "
                    else
                        find_bom = " "
                    end
	            #全局匹配产品
                    #@match_products =Product.search(str,conditions: {ptype: @ptype, package2: @package2},star: true,order: 'prefer DESC')#.to_ary
                    #@match_products = Product.find_by_sql("SELECT * FROM `products` WHERE `description` LIKE '%"+str.split(" ")[0]+"%' AND `part_name` LIKE '%"+@ptype+"%' AND `package2` LIKE '%"+@package2+"%' ORDER BY `prefer` DESC").to_ary
                    @match_products = Product.find_by_sql("SELECT * FROM `products` WHERE `description` LIKE '%"+str.split(" ")[0]+"%' AND `" + part_name_locale + "` LIKE '%"+@ptype+"%'" + find_bom).to_ary
                end
  
	        #@match_products =Product.search(str,conditions: {ptype: @ptype, package2: @package2},star: true,order: 'prefer DESC').to_ary
	        if @match_products.length == 0
                    #if not @bom_item.mpn.blank?
                        #@bom_api = search_in_api(@bom_item.mpn)
                    #end
  	            #匹配出单位的字符串
  	  	    #ary_unit = str.scan(/([a-zA-Z]+)/)
  	  	    #如果匹配出多个，则提示错误
                    #if ary_unit.length > 1
  	                #flash[:error] = t('error_a')
  	  	    #else
   		        #从unit表查找对应的目标单位字符串
 	  	        #ary_unit = ary_unit.join("")
  	                #unit = Unit.find_by(unit: ary_unit)
  		       # unless unit
  	  	           # flash[:error] = t('error_b')
  	  	       # else
  	  		    #用查询得到的标准单位替换关键字串中的单位
  	  		    #str.sub!(/[a-zA-Z]+/, unit.targetunit)
  	  		    #@match_products =Product.search(str,conditions: {ptype: @ptype, package2: @package2},star: true,order: 'prefer DESC').to_ary
                            #@match_products =Product.search(str,conditions: {ptype: @ptype, package2: @package2},star: true).to_ary
  	  		    #if @match_products.length == 0
  	  		        #flash[:error] = t('error_c')
  	  		    #end		
  	                #end
  	            #end	
  	        end	  
                @query_str = str +" without part type "
            end
	    #计算相同类别和封装的个数，package1为元器件类别，package2为封装
	    @counted = Hash.new(0)
            @match_products.each { |h| @counted[h[part_name_locale]] += 1 }
            @counted = Hash[@counted.map {|k,v| [k,v.to_s] }]	
				
	    @counted1 = Hash.new(0)
            @match_products.each { |h| @counted1[h["package2"]] += 1 }
            @counted1 = Hash[@counted1.map {|k,v| [k,v.to_s] }]	
        end
        if not params[:bomsuse].blank?
            #@bom_html = "<table class='table table-bordered table-striped table-hover'><thead><tr><td>产品描述</td><td>价格</td><td>操作</td></tr></thead><tbody>"
            if user_signed_in?
                if current_user.email == "web@mokotechnology.com"
                    @bom_html = ""
                    unless @match_products.nil?
                        @match_products[0..19].each do |item|
                            @bom_html = @bom_html + "<tr>"
                            @bom_html = @bom_html + "<td>"
                            @bom_html = @bom_html + item.name.to_s
                            @bom_html = @bom_html + "</td>"
                            @bom_html = @bom_html + "<td>"
                            @bom_html = @bom_html + item.description.to_s
                            @bom_html = @bom_html + "</td>"
                            @bom_html = @bom_html + "<td>"
                            @bom_html = @bom_html + ActionController::Base.helpers.number_with_precision(item.price, precision: 4).to_s
                            @bom_html = @bom_html + "</td>"
                            @bom_html = @bom_html + "<td>"
                            @bom_html = @bom_html + "<a rel='nofollow' data-method='patch' data-remote='true' href='/bom_item/"+ params[:id].to_s + "?product_id=" + item.id.to_s + "&bomsuse=bomsuse'>OK</a>"
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
                            @bom_html = @bom_html + item.description.to_s
                            @bom_html = @bom_html + "</td>"
                            @bom_html = @bom_html + "<td>"
                            @bom_html = @bom_html + ActionController::Base.helpers.number_with_precision(item.price, precision: 4).to_s
                            @bom_html = @bom_html + "</td>"
                            @bom_html = @bom_html + "<td>"
                            @bom_html = @bom_html + "<a rel='nofollow' data-method='patch' data-remote='true' href='/bom_item/"+ params[:id].to_s + "?product_id=" + item.id.to_s + "&bomsuse=bomsuse'>OK</a>"
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
                        @bom_lab = @bom_lab + '<a data-remote="true" href="/bom_item/' + @bom_item.id.to_s + "/edit?p=" + params[:p].to_s + "&amp;part_name=" + key + "&amp;q=" + params[:q].to_s + "&amp;bomsuse=bomsuse" + '">' + key.to_s + "</a>"
                        @bom_lab = @bom_lab + '<span class="badge">' + value.to_s + '</span>'
                    end
                end 
                @bom_lab = @bom_lab + "</td></tr>"

                @bom_lab = @bom_lab + "<tr><td>" + t(:packaging) + "： "
                unless @counted1.nil?
                    @counted1.each do |key, value| 
                        #<%= link_to "#{key}",  edit_bom_item_path(@bom_item, :package2 =>key, :q =>params[:q], :p =>params[:p]) %>
                        #<a href="/bom_item/8315/edit?p=C6-1%2CC7-1%2CC67-1%2CC68-1&amp;package2=0402&amp;q=CAP+CER+10PF+16V+NP0+0402">0402</a>
                        @bom_lab = @bom_lab + '<a data-remote="true" href="/bom_item/' + @bom_item.id.to_s + "/edit?p=" + params[:p].to_s + "&amp;package2=" + key.to_s + "&amp;q=" + params[:q].to_s + "&amp;bomsuse=bomsuse" + '">' + key.to_s + "</a>"
                        @bom_lab = @bom_lab + '<span class="badge">' + value.to_s + '</span>'
                    end
                end
                @bom_lab = @bom_lab + "</td></tr>"
            else
                @bom_lab = @bom_lab + "<tr><td>" + t(:category) + "： "
                unless @counted.nil? 
                    @counted.each do |key, value| 
                        #<%= link_to "#{key}",  edit_bom_item_path(@bom_item, :part_name =>key, :q =>params[:q], :p =>params[:p]) %> 
                        @bom_lab = @bom_lab + '<a data-remote="true" href="/bom_item/' + @bom_item.id.to_s + "/edit?p=" + params[:p].to_s + "&amp;part_name=" + key.to_s + "&amp;q=" + params[:q].to_s + "&amp;bomsuse=bomsuse" + '">' + key + "</a>" 
                        @bom_lab = @bom_lab + '<span class="badge">' + value.to_s + '</span>'
                    end
                end
                @bom_lab = @bom_lab + "</td></tr>"
                @bom_lab = @bom_lab + "<tr><td>" + t(:packaging) + "："
                unless @counted1.nil?
                    @counted1.each do |key, value|
                        #<%= link_to "#{key}",  edit_bom_item_path(@bom_item, :package2 =>key, :part_name =>@ptype, :q =>params[:q], :p =>params[:p]) %>
                         @bom_lab = @bom_lab + '<a data-remote="true" href="/bom_item/' + @bom_item.id.to_s + "/edit?p=" + params[:p].to_s + "&amp;package2=" + key.to_s + "&amp;q=" + params[:q].to_s + "&amp;part_name=" + @ptype + "&amp;bomsuse=bomsuse" + '">' + key.to_s + "</a>"
                        @bom_lab = @bom_lab + '<span class="badge">' + value.to_s + '</span>'
                    end
                end
                @bom_lab = @bom_lab + "</td></tr>"
            end
            @bom_lab = @bom_lab + "</tbody></table>"


            #@bom_html = @bom_html + "</tbody></table>"
            #@bom_html = ActionController::Base.helpers.sanitize(@bom_html)
            #@bom_html = raw(@bom_html)
            #Rails.logger.info("bomsusebomsusebomsusebomsusebomsusebomsusebomsusebomsusebomsusebomsusebomsusebomsusebomsusebomsusebomsusebomsuse")
            #Rails.logger.info(@bom_html)
            #Rails.logger.info("bomsusebomsusebomsusebomsusebomsusebomsusebomsusebomsusebomsusebomsusebomsusebomsusebomsusebomsusebomsusebomsuse")
        
            Rails.logger.info("----------------------------------------bomsuse")
            render "boms/bom_find.js.erb"
        end	
    end

    def update
        if not params[:product_id].blank?
            @bom_item = BomItem.find(params[:id]) #取回bom_items表bomitem记录，在解析bom是存入，可能没有匹配到product
            @bom = Bom.find(@bom_item.bom_id)
            if @bom_item.update_attribute("product_id", params[:product_id])
                if @bom_item.product_id
	            #@bom_item.product = Product.find(@bom_item.product_id)
                    @bom_item.warn = false
                    @bom_item.mark = false
                    @bom_item.manual = true
                    @bom_item.mpn_id = nil
                    #@bom_item.mpn = nil
	            @bom_item.save!
  
   
                    #累加产品被选择的次数
                    prefer = (Product.find(@bom_item.product_id)).prefer + 1
                    Product.find(@bom_item.product_id).update(prefer: prefer) 
                    if params[:bomsuse].blank?
                        flash[:success] = t('success_a')
                        redirect_to bom_path(@bom_item.bom, :anchor => "Comment", :bomitem => @bom_item.id );
                    else
                        @match_str_nn = "#{@bom.bom_items.count('product_id')+@bom.bom_items.count('mpn_id')} / #{@bom.bom_items.count}"
                        @matched_items_nn = Product.find_by_sql("
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
                        @total_price_nn = 0.00               
	                unless @matched_items_nn.empty?
                            @bom_api_all = []
		            @matched_items_nn.each do |item|
                                if not item.price.blank?
                                    @total_price_nn += item.price * item.quantity  
                                end                      
		            end
                        end
                        render "boms/choose_local.js.erb"
                    end
                else
	            flash[:error] = t('error_d')
	  	    redirect_to bom_path(@bom_item.bom, :anchor => "Comment", :bomitem => @bom_item.id );
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

                    redirect_to bom_path(@bom_item.bom, :anchor => "Comment", :bomitem => @bom_item.id );
                    #redirect_to bom_path(@bom_item.bom);
                else
	            #flash[:error] = t('error_d')
	  	    redirect_to bom_path(@bom_item.bom, :anchor => "Comment", :bomitem => @bom_item.id );
	        end
            else
                render 'edit'
            end     
        end
    end

    def search_in_api(mpn)
        mpn_item = MpnItem.find_by_sql("SELECT * FROM `mpn_items` WHERE `mpn` LIKE '%"+mpn+"%'").first
        if mpn_item.blank?
            url = 'http://octopart.com/api/v3/parts/match?'
            url += '&queries=' + URI.encode(JSON.generate([{:mpn => mpn}]))
            url += '&apikey=809ad885'
            url += '&include[]=descriptions'
     
            resp = Net::HTTP.get_response(URI.parse(url))
            server_response = JSON.parse(resp.body)

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
            naive_id= naive_id_all[(prices_all.index prices_all.min)]
            api_result = []
            mpn_new = MpnItem.new
            server_response['results'].each do |result|
                result['items'].each do |part|
                    if part['mpn'].upcase == mpn.upcase
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

    def search(query_str,part_code)
        #str = get_query_str(query_str)
        #return [] if str.blank?
        ary2 = part_code.upcase.to_s.scan(/[A-Z]+/)
	part_code = ary2[0]
        str = get_query_str_new(query_str.to_s,part_code)
        part = Part.find_by(part_code: part_code)
        
	if part
            #result =Product.search(str,conditions: {part_name: part.part_name},star: true,order: 'prefer DESC').to_ary
            #if str.split(" ")[1].blank?
                #result = Product.find_by_sql("SELECT * FROM `products` WHERE `value2` LIKE '%"+str.split(" ")[0]+"%' AND `ptype` = '"+part.part_name+"' ORDER BY `price`, `prefer` DESC").to_ary  
                #Rails.logger.info("A1A1A1A1")             
            #else
                #result_w = Product.find_by_sql("SELECT * FROM `products` WHERE `value2` LIKE '%"+str.split(" ")[0]+"%' AND `value3` = '"+str.split(" ")[1]+"' AND `ptype` = '"+part.part_name+"' ORDER BY `price`, `prefer` DESC").to_ary
                #Rails.logger.info("A2A2A2")  
                #Rails.logger.info(result.inspect)
                #Rails.logger.info("A2A2A2")     
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
             
            #sql_a = "SELECT * FROM `products` WHERE `value2` = '"+str.split(" ")[0]+"'"
            Rails.logger.info("ggggggggggggggggggggggggggggggggggggggggggg11111111111111111")
            Rails.logger.info(str.inspect)
            Rails.logger.info(part.part_name.inspect)
            Rails.logger.info("gggggggggggggggggggggggggggggggggggggggggggg1111111111111111")
            if part.part_name == "CAP" or part.part_name == "RES"
                if str.split(" ")[0] == "nothing" 
                    str = get_query_str(query_str.to_s)     
                end 
            end
            Rails.logger.info("ggggggggggggggggggggggggggggggggggggggggggg22222222222222222222222")
            Rails.logger.info(str.inspect)
            #Rails.logger.info(part.part_name.inspect)
            Rails.logger.info("gggggggggggggggggggggggggggggggggggggggggggg22222222222222222222")
            if str.split(" ")[-1] == "nothing"
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
            #sql_b = " ORDER BY `prefer` DESC" 
            sql_b = ""
            if not str.split(" ")[2].blank?
                find_bom = " AND `package2` = '"+str.split(" ")[2]+"' "
            else
                find_bom = ""
            end
            if str.split(" ")[1].blank? or str.split(" ")[1] == "nothing"
                Rails.logger.info("0")
                result_w = Product.find_by_sql(sql_a+" AND `ptype` = '"+str.split(" ")[-1]+"' "+find_bom+sql_b).to_ary
                if result_w.blank?
                    Rails.logger.info("1")
                    result_w = Product.find_by_sql(sql_a+" AND `ptype` = '"+str.split(" ")[-1]+"'"+sql_b).to_ary
                else
                    Rails.logger.info("2")
                    Rails.logger.info(result_w.inspect)
                    Rails.logger.info("2")
                    result = result_w 
                end
            else
                Rails.logger.info("3")
                result_w = Product.find_by_sql(sql_a+" AND `value3` = '"+str.split(" ")[1]+"' AND `ptype` = '"+str.split(" ")[-1]+"' "+find_bom+sql_b).to_ary
                if result_w.blank?
                    Rails.logger.info("4")
                    result_w = Product.find_by_sql(sql_a+" AND `value3` = '"+str.split(" ")[1]+"' AND `ptype` = '"+str.split(" ")[-1]+"'"+  sql_b).to_ary
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
                                result_w = result_w 
                            end
                        else
                            Rails.logger.info("9")
                            result_w = Product.find_by_sql(sql_a+" AND `ptype` = '"+str.split(" ")[-1]+"' "+find_bom+sql_b).to_ary
                            if result_w.blank?
                                Rails.logger.info("11")
                                result_w = Product.find_by_sql(sql_a+" AND `ptype` = '"+str.split(" ")[-1]+"'"+sql_b).to_ary
                            else
                                Rails.logger.info("111")
                                result = result_w
                            end 
                        end
                    else
                        Rails.logger.info("1111")
                        result = result_w 
                    end
                else 
                    Rails.logger.info("11111")
                    result = result_w     
                end
            end
            if result_w.length == 0
                Rails.logger.info("15") 
                #if not @bom_item.mpn.blank?
                   #@bom_api = search_in_api(@bom_item.mpn)
                #end
                #result = Product.search(str,star: true,order: 'prefer DESC').to_ary
                #result_w = Product.find_by_sql("SELECT * FROM `products` WHERE `description` LIKE '%"+str.split(" ")[0]+"%' ORDER BY `prefer` DESC").to_ary
                result_w = Product.find_by_sql("SELECT * FROM `products` WHERE `description` LIKE '%"+str.split(" ")[0]+"%'").to_ary
            end
	else
            Rails.logger.info("12")
            #result =Product.search(str,star: true,order: 'prefer DESC').to_ary
            #result_w = Product.find_by_sql("SELECT * FROM `products` WHERE `description` LIKE '%"+str.split(" ")[0]+"%' ORDER BY `prefer` DESC").to_ary
            result_w = Product.find_by_sql("SELECT * FROM `products` WHERE `description` LIKE '%"+str.split(" ")[0]+"%' ").to_ary
            
            #Rails.logger.info("A4A4A4")       
	end
        result = result_w 
    end

	# private methods
	private

	def bom_params
	  params.require(:bom_item).permit(:quantity, :product_id)
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
                #value2_all = ary_all.join(" ").to_s.split(" ").grep(/[mMkKuUrRΩ]/)
                #value2 = "nothing"
                #ary_q = []
                #if value2_all != []
                    #value2 = /[+-]?([0-9]*\.?[0-9]+|[0-9]+\.?[0-9]*)([eE][+-]?[0-9]+)?[mMkKuUrR]/.match(value2_all.join(" ").to_s)
                    #if value2.blank?
                        #value2 = "nothing"
                    #end 
                #end
                ##############################
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
                    Rails.logger.info("value2_use-------------------------------------------------------------value2_usevalue2_usevalue2_use")
                    Rails.logger.info(value2_use.inspect)
                    Rails.logger.info("value2_use-------------------------------------------------------------value2_usevalue2_usevalue2_use")
                    if not value2_use =~ /f/i
                        value2_use = value2_use + "F"
                    end
                    if value2_use =~ /pf/i
                        Rails.logger.info("value2_use-------------------------------------------------------value2_usevalue2_usevalue2_use")
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
                Rails.logger.info("part_name--------------------------------------part_name")
                Rails.logger.info(part.part_name)
                Rails.logger.info("part_name--------------------------------------part_name")
                if query_str =~ /[Μμ]/
                    query_str.gsub!(/[Μμ]/, "u")
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
                #ary_all = query_str.to_s.scan(/([0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                ary_all = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                #ary_q.find{|v| v.include?"u"}
                #ary_q.grep(/u|n|p|m/)
                #获取容值
                #value2_all = ary_all.join(" ").split(" ").grep(/[uUnNpPmM]/)
                #value2 = "nothing"
                #ary_q = []
                #if value2_all != []
                    #value2 = value2_all.join(" ").scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[uUnNpPmM]|[0-9]\.?[0-9]*[uUnNpPmM])/)
                #end
                ########################################################
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
                        Rails.logger.info("value2-------------------------------------------------------------value2")
                        Rails.logger.info(value2.inspect)
                        Rails.logger.info("part_name----------------------------------------------------------------value2")
                        if value2.blank?
                            value2_use = "nothing"
                        else
                            value2_use = value2[0]
                            #value2_use = value2_use.gsub!(/0+?$/, "")  
                            #value2_use = value2_use.gsub!(/[.]$/, "") 
                            if value2_use =~ /\./
                                value2_use = value2_use.gsub(/[A-Za-z]/, "").to_s.gsub(/(\.?0+$)/,"").gsub(/(\.+)/,".")+value2_use.scan(/[A-Za-z]+/)[0].to_s
                                Rails.logger.info("value33333-------------------------------------------------------------value333333")
                                Rails.logger.info(value2_use.inspect)
                                Rails.logger.info("part_ffff----------------------------------------------------------------value333333")
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
                Rails.logger.info("value2_use--------------------------------dddd--------------value2_usevalue2_usevalue2_use")
                Rails.logger.info(value2_use.inspect)
                Rails.logger.info("value2_use--------------------------------dddd--------------------value2_usevalue2_usevalue2_use")
                if not value2_use =~ /f/i
                    value2_use = value2_use + "F"
                end
                Rails.logger.info("value2_use--------------------------------wwww--------------value2_usevalue2_usevalue2_use")
                Rails.logger.info(value2_use.inspect)
                Rails.logger.info("value2_use--------------------------------wwwww--------------------value2_usevalue2_usevalue2_use")
                if value2_use =~ /pf/i
                    Rails.logger.info("value2_use-------------------------------------------------------------value2_usevalue2_usevalue2_use")
                    #value2_use_try = value2_use
                    if value2_use.gsub(/\D/, "").to_i > 999
                        Rails.logger.info("value2_use---------999999---------999-----value2_999")
                        Rails.logger.info(value2_use.inspect)
                        value2_use = (value2_use.gsub(/\D/, "").to_i.to_i/1000).to_s + "nF"
                        Rails.logger.info(value2_use.inspect)
                        Rails.logger.info("value2_use---------999999---------999-----value2_999")
                    end
               
                end
                Rails.logger.info("value2_use--------------------------------xxx--------------value2_usevalue2_usevalue2_use")
                Rails.logger.info(value2_use.inspect)
                Rails.logger.info("value2_use--------------------------------xxxxx--------------------value2_usevalue2_usevalue2_use")
                ary_q[0] = value2_use
                ary_q[1] = value3
                package2_all = Product.find_by_sql("SELECT products.package2, products.ptype FROM products WHERE products.ptype = 'CAP' GROUP BY products.package2")
                value4_all = package2_all.select { |item| ary_all.join(" ").include?item.package2 }
                if not value4_all.blank?
                    Rails.logger.info("__________0000000000000000000000000000000000000bbbbb___________________________")
                    #Rails.logger.info(value4_all.first.package2)
                    Rails.logger.info("_________0000000000000000000000000000000000000bbbbb_______________________________") 
                    ary_q[2] = value4_all.first.package2
                    if "ABCDE".include?ary_q[2]
                        if not query_str.include?"tantalum" or query_str.include?"Tantalum" or query_str.include?"TANTALUM"
                            ary_q[2] = "nothing"    
                        end  
                    end
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
                Rails.logger.info(ary_all.inspect)
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
                #ary_all = query_str.to_s.scan(/([0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                
                ary_all = query_str.to_s.scan(/[0-9]\.?[0-9]*[mMkKuUrRΩ][0-9]\.?[0-9]*/)
                if not ary_all.blank?
                    value2 = ary_all.join("").scan(/[mMkKuUrRΩ]/)
                end


                ary_all = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                #处理电阻
                ary_q = []
                #获取封装
                package2_all = Product.find_by_sql("SELECT products.package2, products.ptype FROM products WHERE products.ptype = 'RES' GROUP BY products.package2")
                value4_all = package2_all.select { |item| ary_all.join(" ").include?item.package2 }
                if not value4_all.blank?
                    Rails.logger.info("value4_all.first.package2__________0000000000000000000000000000000000000bbbbb_________")
                    Rails.logger.info(value4_all.first.package2)
                    Rails.logger.info("value4_all.first.package2_________0000000000000000000000000000000000000bbbbb______________________") 
                    ary_q[2] = value4_all.first.package2
                    value4 = value4_all.first.package2
                    query_str = query_str.gsub(ary_q[2],"")
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
                            #value2_use = value2_use.gsub!(/0+?$/, "")  
                            #value2_use = value2_use.gsub!(/[.]$/, "") 
                            if value2_use =~ /\./                                
                                value2_use = value2_use.gsub(/[A-Za-z]/, "").to_s.gsub(/(\.?0+$)/,"").gsub(/(\.+)/,".")+value2_use.scan(/[A-Za-z]+/)[0].to_s
                                Rails.logger.info("1-------------------------------------------------value2_use")
                                Rails.logger.info(value2_use.inspect)
                                Rails.logger.info("2-------------------------------------------------value2_use")
                                if value2_use.gsub(/[A-Za-z]/, "").to_f < 1 and value2_use.scan(/[A-Za-z]+/)[0].to_s =~ /m/i 
                                    value2_use = (value2_use.gsub(/[A-Za-z]/, "").to_f*1000).to_i.to_s + "k"
                                    Rails.logger.info("3-------------------------------------------------value2_use")
                                    Rails.logger.info(value2_use.inspect)
                                    Rails.logger.info("4-------------------------------------------------value2_use")
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
                
                Rails.logger.info("__________0000000000000000000000000000000000000bbbbb___________________________123")
                Rails.logger.info(value2.inspect)
                Rails.logger.info(value3.inspect)
                Rails.logger.info(value4.inspect)
                Rails.logger.info("_________0000000000000000000000000000000000000bbbbb_______________________________123") 
                if  value2 == "nothing" and value3 == "nothing" and ary_q[2] == "nothing"
                    ary_q = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                end
                #ary_q = value2 + " " + value3
                Rails.logger.info("all00000000000000000000000000000000bbbbb1111111111111111")
                Rails.logger.info(ary_all.inspect)
                Rails.logger.info(value2.inspect)
                Rails.logger.info("all10000000000000000000000000000000000bbbbb1111111111111111")
                Rails.logger.info(value2_all.inspect)
                Rails.logger.info(value3_all.inspect)
                Rails.logger.info("all20000000000000000000000000000000bbbbb111111111111111111")
                ary_q[3] = "RES"
            elsif  ( part and part.part_name == "IC" )
                Rails.logger.info("IC---------------------------------------------------------IC")
                #ary_q = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[a-zA-Z]*[0-9]+[a-zA-Z]*|[0-9]+(?!\W)|[%]+)/)
                #ary_q = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
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
                #ary_q = query_str.to_s.scan(/([a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+[a-zA-Z]*-?\d*\.*\d*)/)
                ary_q = query_str.to_s.scan(/([a-zA-Z]*[0-9]*[a-zA-Z]*[0-9]*[a-zA-Z]*[0-9]*[a-zA-Z]*-?\d*\.*\d*[a-zA-Z]*)/)
                Rails.logger.info("ic-1----------------")
                Rails.logger.info(ary_q.inspect)
                Rails.logger.info("ic----1-------------")
                use_ic = ""
                ary_q.join(" ").split(" ").each do |i|
	            if i.include?"-"
		        use_ic = i
		        #puts use_ic
	            end
                end
                Rails.logger.info("use_ic-----------------")
                Rails.logger.info(use_ic.inspect)
                Rails.logger.info("use_ic-----------------")
                if use_ic != ""
	            ary_q = [] 
	            ary_q << use_ic
	            Rails.logger.info("ic-----------------")
                    Rails.logger.info(ary_q.inspect)
                    Rails.logger.info("ic-----------------")
                end	

                ary_q << "IC"
            elsif  ( part and part.part_name == "Q" )
                Rails.logger.info("QQQ---------------------------------------------------------QQQ") 
                ary_q = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                ary_q << "Q"
            elsif  ( part and part.part_name == "D" )
                Rails.logger.info("DDD---------------------------------------------------------DDD")
                ary_q = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                ary_q << "D"
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
                Rails.logger.info("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                #ary_q = query_str.to_s.scan(/([0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/) 
                #ary_q = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/) 
                #ary_q = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[a-zA-Z]*[0-9]+-|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                ary_q = query_str.to_s.scan(/(-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+[a-zA-Z]*[0-9]+|[0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+[a-zA-Z]*|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
                ary_q << "nothing"
            end
            ary_q.join(" ")
            #ary_q = query_str.to_s.scan(/([0-9]\.?[0-9]*[a-zA-Z]+|[a-zA-Z]*[0-9]+|[0-9]+(?!\W)|[%]+)/)
  #ary_q = query_str.scan(/([a-zA-Z]+[0-9]\.?[0-9]*[a-zA-Z]+|[0-9]\.?[0-9]+[a-zA-Z]+|[0-9]+|[0-9]+(?!\W)|[%]+)/)
            #                         ([a-zA-Z]+[0-9]\.?[0-9]*[a-zA-Z]+|[0-9]\.?[0-9]+[a-zA-Z]+|[0-9]+|[%]+)
  	    
        end
end
