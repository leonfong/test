require 'will_paginate/array'
class WorkFlowController < ApplicationController
before_filter :authenticate_user!

    def find_order
        if params[:c_code] != ""
            #@c_info = PcbCustomer.find_by(c_no: params[:c_code])
            @c_info_t = PcbOrder.find_by_sql("SELECT * FROM `pcb_orders` WHERE ()  AND `pcb_orders`.`state` = 'quotechk'")
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
                    @c_table += '<td><a rel="nofollow" data-method="get" data-remote="true" href="/find_c_ch?id='+ cu.id.to_s + '"><div>' + cu.c_no + '</div></a></td>'
                    @c_table += '<td><a rel="nofollow" data-method="get" data-remote="true" href="/find_c_ch?id='+ cu.id.to_s + '"><div>' + cu.customer.to_s + '</div></a></td>'
                    @c_table += '<td><a rel="nofollow" data-method="get" data-remote="true" href="/find_c_ch?id='+ cu.id.to_s + '"><div>' + cu.customer_com.to_s + '</div></a></td>'
                    @c_table += '<td><a rel="nofollow" data-method="get" data-remote="true" href="/find_c_ch?id='+ cu.id.to_s + '"><div>' + User.find_by(email: cu.sell).full_name.to_s + '</div></a></td>'
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

    def new_pcb_pi
        @pcblist = PcbOrder.where(state: "quotechk").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
            
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
                    @c_table += '<td><a rel="nofollow" data-method="get" data-remote="true" href="/find_c_ch?id='+ cu.id.to_s + '"><div>' + cu.c_no + '</div></a></td>'
                    @c_table += '<td><a rel="nofollow" data-method="get" data-remote="true" href="/find_c_ch?id='+ cu.id.to_s + '"><div>' + cu.customer.to_s + '</div></a></td>'
                    @c_table += '<td><a rel="nofollow" data-method="get" data-remote="true" href="/find_c_ch?id='+ cu.id.to_s + '"><div>' + cu.customer_com.to_s + '</div></a></td>'
                    @c_table += '<td><a rel="nofollow" data-method="get" data-remote="true" href="/find_c_ch?id='+ cu.id.to_s + '"><div>' + User.find_by(email: cu.sell).full_name.to_s + '</div></a></td>'
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
        
    end

    def del_pcb_order
        pcb_order = PcbOrder.find(params[:order_id])
        if can? :work_pcb_business, :all
            pcb_order.destroy
        end
        redirect_to :back
    end

    def update_pcb_price
        pcb = PcbOrder.find_by(order_no: params[:order_no])
        if not params[:price].blank?
            pcb.price = params[:price]
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
        if params[:new]
            @pcblist = PcbOrder.where(state: "new").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
            render "new_pcb_order_list.html.erb" and return
        elsif params[:quote]
            @pcblist = PcbOrder.where(state: "quote").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
            render "pcb_order_list.html.erb" and return
        elsif params[:place_an_order]
            @pcblist = PcbOrder.where(state: "order").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
            render "pcb_order_list_order.html.erb" and return
        elsif params[:quotechk]
            @pcblist = PcbOrder.where(state: "quotechk").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
            render "pcb_order_list_quotechk.html.erb" and return
        else
            @pcblist = PcbOrder.where("state IS NULL").order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
        end
    end

    def add_pcb_order
        if PcbOrder.find_by_sql('SELECT order_no FROM pcb_orders WHERE to_days(pcb_orders.created_at) = to_days(NOW())').blank?
            order_n =1
        else
             
            order_n = PcbOrder.find_by_sql('SELECT order_no FROM pcb_orders WHERE to_days(pcb_orders.created_at) = to_days(NOW())').last.order_no.split("W")[-1].to_i + 1
        end
        order_no = "MK" + Time.new.strftime("%y%m%d").to_s + User.find_by(email: params[:sell]).s_name_self + "W" + order_n.to_s + "W"
        @pcb = PcbOrder.new()
        #@pcb.user_id = current_user.id
        @pcb.pcb_customer_id = params[:customer]
        @pcb.order_no = order_no
        @pcb.sell = params[:sell] 
        @pcb.order_sell = current_user.email
        @pcb.qty = params[:qty]
        @pcb.att = params[:att]
        @pcb.follow_remark = params[:follow_remark]
        @pcb.state = "new"
        @pcb.save
        redirect_to pcb_order_list_path(new: true)
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
        @pcb.save
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

    def sell_view_baojia
        @boms = ProcurementBom.find(params[:bom_id])
        @baojia = PItem.where(procurement_bom_id: params[:bom_id])
    end

    def edit_orderinfo
        order_info = ProcurementBom.where(p_name_mom: params[:itemp_id]).update_all "order_country = '#{params[:order_country]}', star = '#{params[:hint]}', sell_remark = '#{Time.new().localtime.strftime('%y-%m-%d')} #{params[:sell_remark]}', sell_manager_remark = '#{params[:sell_manager_remark]}'"
        

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
                url += '&tips_url=www.fastbom.com/p_bomlist?key_order='+params[:itemp_id].to_s 
                resp = Net::HTTP.get_response(URI(url))
            end 
        end

        redirect_to :back 
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
            @quate = ProcurementBom.find_by_sql("SELECT * FROM `procurement_boms` WHERE #{where_p + where_date + where_5star}  GROUP BY procurement_boms.p_name_mom").paginate(:page => params[:page], :per_page => 10)
        else
            if params[:start_date] != "" and  params[:start_date] != nil
                where_date += " procurement_boms.created_at > '#{params[:start_date]}'"
            end
            if params[:end_date] != "" and  params[:start_date] != nil
                where_date += " AND procurement_boms.created_at < '#{params[:end_date]}'"
            end
            if where_date != ""
                @quate = ProcurementBom.find_by_sql("SELECT * FROM `procurement_boms` WHERE #{where_date + where_5star}  GROUP BY procurement_boms.p_name_mom").paginate(:page => params[:page], :per_page => 10)
            else
                if params[:complete]
                    @quate = ProcurementBom.find_by_sql("SELECT * FROM `procurement_boms` WHERE procurement_boms.star = 5   GROUP BY procurement_boms.p_name_mom").paginate(:page => params[:page], :per_page => 10)
                else
                    @quate = ProcurementBom.find_by_sql("SELECT * FROM `procurement_boms`   GROUP BY procurement_boms.p_name_mom").paginate(:page => params[:page], :per_page => 10)
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
                            #url += '&tips_url=www.fastbom.com/feedback?id='+self.topic_id.to_s 
                                url += '&tips_url=www.fastbom.com/work_flow?utf8=%E2%9C%93%26order_s%5Border_s%5D=1%26order=' + checkorder.order_no + '%26commit=%E6%90%9C%E7%B4%A2'
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
                            url += '&tips_url=www.fastbom.com/feedback?id='+topic_up.id.to_s 
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
                            url += '&tips_url=www.fastbom.com/feedback?id='+topic_up.id.to_s 
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
                            url += '&tips_url=www.fastbom.com/feedback?id='+topic_up.id.to_s 
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
                            url += '&tips_url=www.fastbom.com/feedback?id='+topic_up.id.to_s 
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
                            url += '&tips_url=www.fastbom.com/feedback?id='+topic_up.id.to_s 
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
                            url += '&tips_url=www.fastbom.com/feedback?id='+topic_up.id.to_s 
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
                            url += '&tips_url=www.fastbom.com/feedback?id='+topic_up.id.to_s 
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
                            url += '&tips_url=www.fastbom.com/feedback?id='+topic_up.id.to_s 
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
