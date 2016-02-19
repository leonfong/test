class WorkFlowController < ApplicationController
before_filter :authenticate_user!
    def index
        if params[:order]
            order = params[:order].strip
        else
            order = ""
        end
        @work_flow = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE  work_flows.order_no like '%" + order + "%' ORDER BY work_flows.created_at DESC" )
        
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
        Rails.logger.info(@work_flow.inspect)
        Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
    end
   
    def up_work
        work_up = WorkFlow.new
        work_up.order_date = params[:order_date].strip
        work_up.order_no = params[:order_no].strip
        work_up.order_quantity = params[:order_quantity].strip 
        work_up.salesman_end_date = params[:salesman_end_date].strip
        work_up.product_code = params[:product_code].strip 
        work_up.save
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
            work_up.smd_start_date = params[:smd_start_date].strip
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
        if not params[:engineering_end_date].blank?
            work_up.engineering_end_date = params[:engineering_end_date].strip
        end
        if not params[:factory_state].blank?
            work_up.factory_state = params[:factory_state].strip
        end
        if not params[:engineering_state].blank?
            work_up.engineering_state = params[:engineering_state].strip
        end
        if not params[:purchasing_state].blank?
            work_up.purchasing_state = params[:purchasing_state].strip
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
