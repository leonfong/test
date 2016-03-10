require 'will_paginate/array'
class TimesheetController < ApplicationController
before_filter :authenticate_user!
    def index
        if params[:order_no]
            @order = WorkFlow.where(order_no: params[:order_no].strip).first
        end
    end

    def down_excel
        #params[:timesheet_order]
        if params[:timesheet_order]
            file_name = "Timesheet"+"#{Time.now.strftime("%Y-%m-%d_%H:%M:%S")}"+".xls"
            path = Rails.root.to_s+"/public/uploads/" 
            all_order = params[:timesheet_order].strip.split("\r\n");
            index = 0
            Spreadsheet.client_encoding = 'UTF-8'
            ff = Spreadsheet::Workbook.new
            sheet1 = ff.create_worksheet
            sheet1.row(0).concat %w{No. 单号 订单数量 钢网 过炉 测试 SMT工时 DIP工时 工时合计}
            all_order.each do |item|
                checkorder = WorkFlow.find_by_sql("SELECT * FROM `work_flows` WHERE  work_flows.order_no = '" + item + "'").first
                if not checkorder.blank?
                    index = index+1
                    title_format = Spreadsheet::Format.new({
                    :weight           => :bold,
                    :pattern_bg_color => :red,
                    :size             => 10,
                    :color => :red
                    })
		    row = sheet1.row(index)
                    #if item.warn
                        #row.set_format(2,title_format)
                    #end
		    row.push(index)
		    row.push(checkorder.order_no)
		    row.push(checkorder.order_quantity)
		    row.push(checkorder.gangwang)
                    row.push(checkorder.guolu) 
                    row.push(checkorder.ceshi) 
                    row.push(checkorder.smt_time) 
                    row.push(checkorder.dip_time) 
                    row.push(checkorder.total_time)   
                else
                    redirect_to work_flow_path, :flash => {:error => item+"--------结单失败，请检查订单号！"}
                    return false
                end
            end
            ff.write (path+file_name)              
            send_file(path+file_name, type: "application/vnd.ms-excel")
        end
    end
   
    def up_timesheet
        if params[:order_id]
            work_up = WorkFlow.find(params[:order_id])
            if not params[:gangwang].blank?
                work_up.gangwang = work_up.gangwang + params[:gangwang].to_i
            end
            if not params[:guolu].blank?
                work_up.guolu = work_up.guolu + params[:guolu].to_i
            end
            if not params[:ceshi].blank?
                work_up.ceshi = work_up.ceshi + params[:ceshi].to_i
            end
            total_time_i = 0
            if not params[:smt_time].blank?
                work_up.smt_time = work_up.smt_time + params[:smt_time].to_f
                total_time_i = total_time_i.to_f + params[:smt_time].to_f 
            end
            if not params[:dip_time].blank?
                work_up.dip_time = work_up.dip_time + params[:dip_time].to_f
                total_time_i = total_time_i.to_f + params[:dip_time].to_f
            end            
            work_up.total_time = work_up.total_time.to_f + total_time_i.to_f            
            if work_up.save
                timeup = Timesheet.new
                timeup.order_no = work_up.order_no
                timeup.order_id = work_up.id
                if not params[:gangwang].blank?
                    timeup.gangwang = params[:gangwang]
                end
                if not params[:guolu].blank?
                    timeup.guolu = params[:guolu]
                end
                if not params[:ceshi].blank?
                    timeup.ceshi = params[:ceshi]
                end
                if not params[:smt_time].blank?
                    timeup.smt_time = params[:smt_time]
                end
                if not params[:dip_time].blank?
                    timeup.dip_time = params[:dip_time]
                end               
                if timeup.save
                    redirect_to timesheet_path(:order_no => timeup.order_no), :flash => {:success => timeup.order_no+"--------工时录入成功！"}                  
                else
                    redirect_to timesheet_path(), :flash => {:error => item+"--------工时更新失败！"}
                    return false
                end           
            end
        end
    end
    
end
