class WorkFlowController < ApplicationController
before_filter :authenticate_user!
    def index
        limit = "LIMIT 35"
        if params[:order]
            order = params[:order].strip
            where_def = "  work_flows.order_no like '%" + order + "%'"
            limit = ""
        else
            order = ""
            where_def = "  work_flows.order_no like '%" + order + "%'"
            limit = ""
        end
        if params[:empty_date] and params[:empty_date] == "show_empty"
            empty_date = "work_flows.smd_start_date IS NOT NULL AND work_flows.smd_end_date IS NULL OR work_flows.dip_start_date IS NOT NULL AND work_flows.dip_end_date IS NULL OR work_flows.supplement_date IS NOT NULL AND work_flows.clear_date IS NULL AND"
            limit = ""
        else
            empty_date = ""
            limit = ""
        end 
        

        #@work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + empty_date + where_def + " ORDER BY work_flows.created_at DESC LIMIT 35" )
 
        if can? :work_c, :all
            if params[:order]            
                @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + empty_date + where_def + " ORDER BY work_flows.created_at DESC LIMIT 35" )
            end
            render "production_feedback.html.erb"
        else
            @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE " + empty_date + where_def + " ORDER BY work_flows.created_at DESC LIMIT 35" )
        end
        #line1 = "2015-11-05	MK51008BZ01B-3	1000	2015-11-29	C.2.CH.B.RO-0008"
        #line2 = line1.split(" ")
        #Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        #Rails.logger.info(line2.inspect)
        #Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
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
        work_up = WorkFlow.find(params[:work_id])
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
        end
        if not params[:test_feedback].blank?
            work_up.test_feedback = params[:test_feedback].strip
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
        if not params[:remark].blank?
            work_up.remark = params[:remark].strip
        end
        if work_up.save
            redirect_to work_flow_path(), notice: "订单数据更新成功！"
        end
    end
end
