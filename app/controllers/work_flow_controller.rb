require 'will_paginate/array'
class WorkFlowController < ApplicationController
before_filter :authenticate_user!
    def index
        @open = "collapse" 
        @pic = "glyphicon glyphicon-plus"
        limit = "LIMIT 20"
        add_where = " AND work_flows.order_state = 0"
        @order_check_1 = false
        @order_check_2 = false
        @order_check_3 = true
        if params[:order_s] 
            if params[:order_s][:order_s].to_i == 1 
                add_where = "" 
                @order_check_1 = true
                @order_check_2 = false
                @order_check_3 = false
            elsif params[:order_s][:order_s].to_i == 2 
                add_where = " AND work_flows.order_state = 1"
                @order_check_2 = true
                @order_check_1 = false
                @order_check_3 = false
            elsif params[:order_s][:order_s].to_i == 3 
                add_where = " AND work_flows.order_state = 0"
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
                empty_date = "work_flows.smd_start_date IS NOT NULL AND work_flows.smd_end_date IS NULL OR work_flows.dip_start_date IS NOT NULL AND work_flows.dip_end_date IS NULL OR work_flows.supplement_date IS NOT NULL AND work_flows.clear_date IS NULL AND"
                limit = ""
            elsif params[:empty_date] == "ready"
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
        

        #@work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + empty_date + where_def + " ORDER BY work_flows.created_at DESC LIMIT 35" )
 
        if can? :work_c, :all
            if params[:order]    
                add_where = ""        
                @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE "  + where_def + add_where + "  ORDER BY work_flows.updated_at DESC " ).paginate(:page => params[:page], :per_page => 20)
            else
                add_where = ""
                @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE "  + where_def + add_where + " AND feedback_state = 1 ORDER BY work_flows.updated_at DESC " ).paginate(:page => params[:page], :per_page => 20)
            end
            render "production_feedback.list.html.erb"
        elsif can? :work_d, :all
            if params[:order]  
                add_where = ""          
                @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE "  + where_def + add_where + " ORDER BY work_flows.updated_at DESC "  ).paginate(:page => params[:page], :per_page => 20)
            else
                add_where = ""
                @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE "  + where_def + add_where + " AND feedback_state = 1 ORDER BY work_flows.updated_at DESC "  ).paginate(:page => params[:page], :per_page => 20)
            end
            render "test_feedback.list.html.erb"
        elsif can? :work_b, :all
            add_where = ""
            empty_date = "work_flows.smd_start_date IS NOT NULL AND work_flows.smd_end_date IS NULL OR work_flows.dip_start_date IS NOT NULL AND work_flows.dip_end_date IS NULL OR work_flows.supplement_date IS NOT NULL AND work_flows.clear_date IS NULL AND"
            limit = ""            
            @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE "  + where_def + add_where + " ORDER BY work_flows.updated_at DESC " ).paginate(:page => params[:page], :per_page => 20)
            render "delivery_date.html.erb"
        elsif can? :work_e, :all
            if params[:order]
                #if not params[:order] == ""
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + empty_date + where_def + add_where + " ORDER BY work_flows.updated_at DESC " ).paginate(:page => params[:page], :per_page => 20)
                #end
            else
                if empty_date == ""
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE "  + empty_date + where_def + add_where + " AND feedback_state > 1  ORDER BY work_flows.updated_at DESC "  ).paginate(:page => params[:page], :per_page => 20)
                else
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE "  + empty_date + where_def + add_where + " ORDER BY work_flows.updated_at DESC " ).paginate(:page => params[:page], :per_page => 20)
                end 
                if params[:page]
                    @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + empty_date + where_def + add_where + " ORDER BY work_flows.updated_at DESC " ).paginate(:page => params[:page], :per_page => 20)
                end
            end
            render "sell.html.erb"
        else
            #if params[:order]
                #@work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + empty_date + where_def + add_where + " ORDER BY work_flows.updated_at DESC " + limit )
                @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + empty_date + where_def + add_where ).paginate(:page => params[:page], :per_page => 20)
           # end
        end
        
    end
   
    def show
        @work_flow = WorkFlow.find(params[:id])
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        Rails.logger.info(@work_flow.inspect)
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        if can? :work_c, :all
            render "production_feedback.html.erb"
        elsif can? :work_d, :all
            render "test_feedback.html.erb"
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
                        checkorder.warehouse_quantity = item_order[1] 
                        checkorder.save
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
                        work_up.save
                        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
                        Rails.logger.info(item_order.inspect)
                        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
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
            if not params[:test_feedback].blank?
                work_up.test_feedback = params[:test_feedback].strip
                work_up.feedback_state = "2"
            end
            if not params[:sell_feedback].blank?
                work_up.feedback_state = "1"
            end
            if not params[:supplement_date].blank?
                work_up.supplement_date = params[:supplement_date].strip
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
            if params[:feedback_up] 
                feedback_up = Feedback.new
                feedback_up.order_no = work_up.order_no
                feedback_up.product_code = work_up.product_code
                if not params[:production_feedback].blank?
                    feedback_up.feedback = params[:production_feedback]
                    feedback_up.feedback_type = "production"
                elsif not params[:test_feedback].blank?
                    feedback_up.feedback = params[:test_feedback]
                    feedback_up.feedback_type = "test"
                elsif not params[:sell_feedback].blank?
                    feedback_up.feedback = params[:sell_feedback]
                    feedback_up.feedback_type = "sell"
                end
                feedback_up.user_name = current_user.email
                feedback_up.save
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
                if not params[:test_feedback].blank?
                    work_history.test_feedback = params[:test_feedback].strip
                end
                if not params[:supplement_date].blank?
                    work_history.supplement_date = params[:supplement_date].strip
                end
                if not params[:clear_date].blank?
                    work_history.clear_date = params[:clear_date].strip
                end
                if not params[:salesman_state].blank?
                    work_history.salesman_state = params[:salesman_state].strip
                end
                if not params[:remark].blank?
                    work_history.remark = params[:remark].strip
                end
                work_history.user_name = current_user.email
                work_history.save
            end                     
            limit = "LIMIT 20"
            where_def = "  work_flows.id = '" + params[:work_id] + "'"
            @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE "  + where_def + " ORDER BY work_flows.updated_at DESC ").paginate(:page => params[:page], :per_page => 20)
            @order_no = work_up.order_no
            @open = "collapse in"
            @pic = "glyphicon glyphicon-minus"
            
            flash.now[:success] = "订单数据更新成功！"
            if can? :work_c, :all
                @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE "  + where_def + " ORDER BY work_flows.updated_at DESC " + limit ).first
                render "production_feedback.html.erb"
            elsif can? :work_d, :all
                @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE "  + where_def + " ORDER BY work_flows.updated_at DESC " + limit ).first
                render "test_feedback.html.erb"
            elsif can? :work_b, :all
                render "delivery_date.html.erb"
            elsif can? :work_e, :all
                render "sell.html.erb"
            else
                redirect_to work_flow_path(), notice: "订单数据更新成功！"
            end
        end
    end
end
