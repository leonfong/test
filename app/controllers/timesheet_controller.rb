require 'will_paginate/array'
class TimesheetController < ApplicationController
before_filter :authenticate_user!
    def index
        if params[:order_no]
            @order = WorkFlow.where(order_no: params[:order_no].strip).first
        end
    end

    def up_timesheet
        if params[:order_id]
            work_up = WorkFlow.find(params[:order_id])
            if params[:gangwang]
                work_up.gangwang = work_up.gangwang + params[:gangwang].to_i
            end
            if params[:guolu]
                work_up.guolu = work_up.guolu + params[:guolu].to_i
            end
            if params[:ceshi]
                work_up.ceshi = work_up.ceshi + params[:ceshi].to_i
            end
            total_time_i = 0
            if params[:smt_time]
                work_up.smt_time = work_up.smt_time + params[:smt_time].to_f
                total_time_i = total_time_i.to_f + params[:smt_time].to_f 
            end
            if params[:dip_time]
                work_up.dip_time = work_up.dip_time + params[:dip_time].to_f
                total_time_i = total_time_i.to_f + params[:dip_time].to_f
            end            
            work_up.total_time = work_up.total_time.to_f + total_time_i.to_f            
            if work_up.save
                timeup = Timesheet.new
                timeup.order_no = work_up.order_no
                timeup.order_id = work_up.id
                if params[:gangwang]
                    timeup.gangwang = params[:gangwang]
                end
                if params[:guolu]
                    timeup.guolu = params[:guolu]
                end
                if params[:ceshi]
                    timeup.ceshi = params[:ceshi]
                end
                if params[:smt_time]
                    timeup.smt_time = params[:smt_time]
                end
                if params[:dip_time]
                    timeup.dip_time = params[:dip_time]
                end               
                if timeup.save
                    redirect_to action: "index", :order_no => timeup.order_no , notice: "工时数据更新成功！"                    
                else
                    redirect_to timesheet_path(), :flash => {:error => item+"--------工时更新失败！"}
                    return false
                end           
            end
        end
    end
    
end
