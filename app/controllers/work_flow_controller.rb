require 'will_paginate/array'
class WorkFlowController < ApplicationController
before_filter :authenticate_user!
    def index
        #phone = '<img width="200" title="" align="" alt="" src="/uploads/image/201603/1d479d38ffe2.jpg" /> ccc>'
        #if ( phone =~ /width="(.\d*")/ )  
            #phone = phone.gsub!(/width="(.\d*")/, "")
        #end
        #dddddd = phone.scan(/width="(.\d*")/) 
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        Rails.logger.info(Rails.public_path)
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        @open = "collapse" 
        @pic = "glyphicon glyphicon-plus"
        limit = "LIMIT 20"
        add_where = " AND work_flows.order_state != 1"
        @order_check_1 = false
        @order_check_2 = false
        @order_check_3 = true
        if params[:order_s] 
            if params[:order_s][:order_s].to_i == 1 
                add_where = " " 
                @order_check_1 = true
                @order_check_2 = false
                @order_check_3 = false
            elsif params[:order_s][:order_s].to_i == 2 
                add_where = " AND work_flows.order_state = 1"
                @order_check_2 = true
                @order_check_1 = false
                @order_check_3 = false
            elsif params[:order_s][:order_s].to_i == 3 
                add_where = " AND work_flows.order_state != 1"
                @order_check_3 = true
                @order_check_2 = false
                @order_check_1 = false
            end
        end
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
                limit = ""
            end
        else
            order = ""
            where_def = "  work_flows.order_no like '%" + order + "%'"
            #limit = ""
        end
        if params[:empty_date] 
            add_where = ""
            if params[:empty_date] == "show_empty"
                empty_date = "(work_flows.smd_start_date IS NOT NULL AND work_flows.smd_end_date IS NULL OR work_flows.dip_start_date IS NOT NULL AND work_flows.dip_end_date IS NULL OR work_flows.supplement_date IS NOT NULL AND work_flows.clear_date IS NULL) AND work_flows.order_state != 1 AND "
                limit = ""
            elsif params[:empty_date] == "ready"
                @show_title = "料齐的订单"
                empty_date = "work_flows.order_state = 2 AND"
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
            @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE topics.feedback_receive = 'production' ORDER BY topics.updated_at DESC " ).paginate(:page => params[:page], :per_page => 10)
            if params[:order] 
                @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + where_def ).paginate(:page => params[:page], :per_page => 10)
            end
            render "production.html.erb"
        elsif can? :work_d, :all
            @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE topics.feedback_receive = 'engineering' ORDER BY topics.updated_at DESC " ).paginate(:page => params[:page], :per_page => 10)
            if params[:order] 
                @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + where_def ).paginate(:page => params[:page], :per_page => 10)
            end
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
            empty_date = "(work_flows.smd_start_date IS NOT NULL AND work_flows.smd_end_date IS NULL OR work_flows.dip_start_date IS NOT NULL AND work_flows.dip_end_date IS NULL OR work_flows.supplement_date IS NOT NULL AND work_flows.clear_date IS NULL) AND work_flows.order_state != 1 AND"  
            add_orderby = ""
            if params[:sort_date]
                empty_date = ""
                if params[:sort_date] == "smd"
                    add_where = "AND smd_end_date IS NOT NULL "
                    add_orderby = " ORDER BY work_flows.smd_end_date "
                elsif params[:sort_date] == "dip"
                    add_where = "AND dip_end_date IS NOT NULL"
                    add_orderby = " ORDER BY work_flows.dip_end_date "
                elsif params[:sort_date] == "clear"
                    add_where = "AND clear_date IS NOT NULL"
                    add_orderby = " ORDER BY work_flows.clear_date " 
                end
            end
            if params[:order_s] 
                empty_date = ""  
            end
            limit = ""            
            @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE "  + empty_date + where_def + add_where + add_orderby ).paginate(:page => params[:page], :per_page => 10)            
            render "delivery_date.html.erb"
        elsif can? :work_e, :all
            @topic = Topic.find_by_sql("SELECT * FROM `topics` WHERE topics.feedback_receive = 'sell' ORDER BY topics.updated_at DESC " ).paginate(:page => params[:page], :per_page => 10)
            if params[:order]
                #if not params[:order] == ""
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + empty_date + where_def + add_where + " ORDER BY work_flows.updated_at DESC " ).paginate(:page => params[:page], :per_page => 10)
                #end
            else
                if empty_date != ""                    
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE "  + empty_date + where_def + add_where + " ORDER BY work_flows.updated_at DESC " ).paginate(:page => params[:page], :per_page => 10)
                end               
            end
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
            #add_orderby = " ORDER BY work_flows.updated_at DESC " 
            add_orderby = " " 
            if params[:sort_date]
                empty_date = ""
                if params[:sort_date] == "smd"
                    add_where = "AND smd_end_date IS NOT NULL "
                    add_orderby = " ORDER BY work_flows.smd_end_date "
                elsif params[:sort_date] == "dip"
                    add_where = "AND dip_end_date IS NOT NULL"
                    add_orderby = " ORDER BY work_flows.dip_end_date "
                elsif params[:sort_date] == "clear"
                    add_where = "AND clear_date IS NOT NULL"
                    add_orderby = " ORDER BY work_flows.clear_date " 
                end
            end
            @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + empty_date + where_def + add_where + add_orderby).paginate(:page => params[:page], :per_page => 10)
           
            #render "index.html.erb"
            #redirect_to action: :index, data: { no_turbolink: true }
        end
        
    end

   
    def show
        #@work_flow = WorkFlow.find(params[:id])
        @topic = Topic.find(params[:id]) 
        @feedback_all = Feedback.where(topic_id: params[:id]).order("created_at DESC")
        if can? :work_c, :all
            render "production_feedback.html.erb"
        elsif can? :work_d, :all
            render "engineering_feedback.html.erb"
        elsif can? :work_e, :all
            render "sell_feedback.html.erb"
        elsif can? :work_f, :all
            render "merchandiser_feedback.html.erb"
        elsif can? :work_g, :all
            render "procurement_feedback.html.erb"
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
                    end
                else
                    redirect_to work_flow_path, :flash => {:error => item+"--------入库数量更新失败，请检查上传数据格式！"}
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
            elsif params[:order_y]
                all_order = params[:order_y].strip.split("\r\n");
            elsif params[:order_r]
                all_order = params[:order_r].strip.split("\r\n");
            end
            
            all_order.each do |item|
                checkorder = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE  work_flows.order_no = '" + item + "'").first
                if not checkorder.blank?
                    if params[:order_state]
                        checkorder.order_state = 1
                    elsif params[:order_y]
                        checkorder.order_state = 2
                    elsif params[:order_r]
                        checkorder.order_state = 3 
                    end
                    checkorder.save
                    #Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                    #Rails.logger.info(checkorder.inspect)
                    #Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                else
                    redirect_to work_flow_path, :flash => {:error => item+"--------结单失败，请检查订单号！"}
                    return false
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
                if not params[:smd].blank?
                    work_up.smd = params[:smd].strip
                end
                if not params[:dip].blank?
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
                if not params[:supplement_date].blank?
                    work_up.supplement_date = params[:supplement_date].strip
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
                        topic_up.feedback_receive = params[:receive_feedback][:receive_feedback]    #收贴的部门
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
                        topic_up.feedback_receive = params[:receive_feedback][:receive_feedback]    #收贴的部门
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
                        topic_up.feedback_receive = params[:receive_feedback][:receive_feedback]    #收贴的部门
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
                        topic_up.feedback_receive = params[:receive_feedback][:receive_feedback]    #收贴的部门
                        #topic_up.feedback_receive_user = "sell"                #收贴的人
                        #topic_up.feedback_level = 1                            #暂时没用
                        #topic_up.feedback_id = 1
                    end
                    topic_up.user_name = current_user.email                     #发帖的人
                    topic_up.save
                elsif params[:feedback_up] 
                    topic_up = Topic.find(params[:feedback_up])
                    Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                    Rails.logger.info(params[:feedback_up].inspect)
                    Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                    if can? :work_e, :all                                       #业务回帖                        
                        topic_up.feedback_receive = "merchandiser" 
                    else                                                        #其他部门回帖                        
                        if params[:send_up]
                            topic_up = Topic.find(params[:feedback_up])
                            if params[:send_up][:send_up].to_s == "mark"
                                topic_up.mark = params[:send_up][:send_up]
                            else
                                topic_up.feedback_receive = params[:send_up][:send_up]
                                topic_up.mark = ""
                            end
                        end                                                         
                        if params[:feedback_receive] 
                            if params[:feedback_receive] == "sell"                       
                                topic_up.feedback_receive_user = topic_up.user_name   #收贴的人
                            end
                            topic_up.feedback_receive = params[:send_up][:send_up]     #收贴的部门
                        end
                        if params[:feedback_receive_user]
                            topic_up.feedback_receive_user = params[:feedback_receive_user]   #收贴的人
                        end
                    end
                    if not params[:topic_state].blank?
                        topic_up.topic_state = params[:topic_state]             #是否关闭问题
                        if params[:topic_state] == "close"
                            topic_up.feedback_receive = ""
                        end
                    end
                    topic_up.save
                    if not params[:production_feedback].blank? and params[:send_up][:send_up].to_s != "mark" 
                        feedback_up = Feedback.new  
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
                    elsif not params[:engineering_feedback].blank? and params[:send_up][:send_up].to_s != "mark" 
                        feedback_up = Feedback.new  
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
                    elsif not params[:merchandiser_feedback].blank? and params[:send_up][:send_up].to_s != "mark"                      
                        feedback_up = Feedback.new  
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
                        #feedback_up.feedback_receive = params[:feedback_type]    #收贴的部门
                        #feedback_up.feedback_receive_user = params[:user_name]   #收贴的人
                        #feedback_up.feedback_level = 1                          #暂时没用
                        #feedback_up.feedback_id = 1                             #暂时没用
                        feedback_up.user_name = current_user.email                     #发帖的人
                        feedback_up.save
                    elsif not params[:procurement_feedback].blank? and params[:send_up][:send_up].to_s != "mark"                        
                        feedback_up = Feedback.new  
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
                    if not params[:smd_state].blank?
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
end
