require 'will_paginate/array'
class MpnInfoController < ApplicationController
before_filter :authenticate_user!
    def index
        if params[:mpn]
            @mpn = InfoPart.find_by_sql("SELECT mpn FROM `info_parts` WHERE `mpn` like '%#{params[:mpn].strip}%' GROUP BY mpn")
            @all_info = []
            @mpn.each do |mpn| 


                @one_info = []
                prices_all = []
                @one_info << mpn.mpn
                index = 0
                stock = 0
                @change_stock = 0
                all_info = InfoPart.find_by_sql("SELECT * FROM `info_parts` WHERE `mpn` = '#{mpn.mpn}' ORDER BY info_parts.created_at ASC")
                @start_date = all_info.first.created_at.localtime.strftime('%Y-%m-%d').to_s
                @one_info << @start_date
                @end_date = all_info.last.created_at.localtime.strftime('%Y-%m-%d').to_s
                @one_info << @end_date
                #all_date = all_info.size*2
                time =  (all_info.last.created_at.localtime.strftime('%Y-%m-%d %H:%M:%S').to_s.to_time.to_i - all_info.first.created_at.localtime.strftime('%Y-%m-%d %H:%M:%S').to_s.to_time.to_i)/86400.00
#保留小数点后两位
                all_date = format("%.0f",time)
                if not all_info.blank?
                    all_info.each do |item|
                        @mpn_item = JSON.parse(item.info)
                        
                        naive_id_all = []
                        part_all = []
                        #Rails.logger.info(@mpn_item['response'].inspect)
                        mpn_stock = 0
                        @mpn_item['response'].each do |result|
                           
                            result['parts'].each do |part|
                                #Rails.logger.info("part-----------------------------------------part")
                                #Rails.logger.info(part.inspect)   
                                #Rails.logger.info("part----------------------------------------------part")
                                part['price'].each do |f|     
                                    if f.has_value?"USD"
                                        prices_all << f['price'].to_f
                                        naive_id_all << result['distributor']['id'] 
                                        part_all << part['part']                                    
                                    end
                                end
                                mpn_stock += part['stock'].to_i
                            end                        
                        end
                        #Rails.logger.info("prices_all--------------------------------------------------------------------------")
                        #Rails.logger.info(prices_all.inspect)   
                        #Rails.logger.info("prices_all----------------------------------------------------------")    
                        if index == 0
                            stock = mpn_stock
                        end
                        stock_change = stock - mpn_stock
                        stock = mpn_stock
                        index = index+1
                        
                        if stock_change > 0
                            @change_stock += stock_change
                        end
                    end                                   
                end
                @prices_min = prices_all.min
                @one_info << @change_stock
                @one_info << @prices_min
                @one_info << all_date
                @all_info << @one_info
            end
            @all_info = @all_info.sort{|a,b| b[3]<=>a[3]}.paginate(:page => params[:page], :per_page => 15)




        end
    end

    def down_excel
        #params[:timesheet_order]
        if params[:id]
            file_name = "MPN---"+params[:id].strip.to_s+".xls"
            path = Rails.root.to_s+"/public/uploads/" 
            

            
            Spreadsheet.client_encoding = 'UTF-8'
            ff = Spreadsheet::Workbook.new
            sheet1 = ff.create_worksheet
            sheet1.column(0).width = 5
            sheet1.column(1).width = 20
            sheet1.column(2).width = 20
            sheet1.column(3).width = 10
            sheet1.column(4).width = 10
            sheet1.column(5).width = 10
            sheet1.row(0).concat %w{No. MPN 日期 库存 最低价格 库存变化}
            index = 0
            stock = 0
            all_info = InfoPart.find_by_sql("SELECT * FROM `info_parts` WHERE `mpn` = '#{params[:id].strip}'")
            if not all_info.blank?
                all_info.each do |item|
                    @mpn_item = JSON.parse(item.info)
                    prices_all = []
                    naive_id_all = []
                    part_all = []
                    #Rails.logger.info(@mpn_item['response'].inspect)
                    mpn_stock = 0
                    @mpn_item['response'].each do |result|
                           
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
                            mpn_stock += part['stock'].to_i
                        end                        
                    end
                    Rails.logger.info("prices_all--------------------------------------------------------------------------")
                    Rails.logger.info(prices_all.inspect)   
                    Rails.logger.info("prices_all--------------------------------------------------------------------------")    
                    if index == 0
                        stock = mpn_stock
                    end
                    stock_change =  mpn_stock - stock
                    stock = mpn_stock
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
		    row.push(item.mpn)
		    row.push(item.created_at.localtime.strftime('%Y-%m-%d %H:%M:%S').to_s)
		    row.push(stock)
                    row.push(prices_all.min)
                    row.push(stock_change)
                end                    
            else
                redirect_to mpn_info_path, :flash => {:error => params[:id].strip+"--------没有数据，请联系管理员！"}
                return false
            end
            ff.write (path+file_name)              
            send_file(path+file_name, type: "application/vnd.ms-excel")
        else
            redirect_to mpn_info_path()     
        end
    end
   
    def up_mpn
        if params[:mpn_all]
            all_mpn = params[:mpn_all].strip.split("\r\n");
            all_mpn.each do |mpn|
                checkmpn = AllPart.find_by_sql("SELECT * FROM `all_parts` WHERE `mpn` = '#{mpn.strip}'")
                if checkmpn.blank?
                    mpn_in = AllPart.new
                    mpn_in.mpn = mpn.strip
                    if mpn_in.save
                        flash.now[:success] = "MPN录入成功！"                        
                    else
                        redirect_to mpn_info_path(), :flash => {:error => mpn+"--------MPN录入失败！"}  
                        return false  
                    end
                end
            end
        end
        redirect_to mpn_info_path()           
    end
    
end
