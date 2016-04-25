require 'roo'
require 'spreadsheet'
require 'will_paginate/array'
class ProcurementController < ApplicationController
    def create_bom
        Rails.logger.info("-------------------------")
        Rails.logger.info(request.original_fullpath.inspect)   
        Rails.logger.info("----------------------------------") 
        
        @bom = ProcurementBom.new
        #@mpn_show = MpnItem.find_by_sql("SELECT * FROM `mpn_items` LIMIT 0, 30")
        @mpn_show = MpnItem.find_by_sql("SELECT * FROM mpn_items WHERE mpn IS NOT NULL AND id >= ((SELECT MAX(id) FROM mpn_items)-(SELECT MIN(id) FROM mpn_items)) * RAND() + (SELECT MIN(id) FROM mpn_items) LIMIT 100")
        @des_show = Product.find_by_sql("SELECT * FROM products WHERE id >= ((SELECT MAX(id) FROM products)-(SELECT MIN(id) FROM products)) * RAND() + (SELECT MIN(id) FROM products) LIMIT 100")
    end

    def upbom        
        if params[:bom_id] and params[:bak_bom].blank?
            old_bom = PItem.where(bom_id: params[:bom_id]) 
            old_bom.each do |old_item|
                old_item.destroy
            end
            @bom = ProcurementBom.find(params[:bom_id]) 
            @bom.p_name = params[:p_name]
            @bom.qty = params[:qty]
            @bom.d_day = params[:day]  
            @bom.save    
            Rails.logger.info("------------------------------------------------------------1")
            Rails.logger.info(params[:bom_id].inspect)
            Rails.logger.info(params[:noselect].inspect)
            Rails.logger.info("------------------------------------------------------------1")
            #Rails.logger.info("------------------------------------------------------------2")
            #Rails.logger.info(params[:select_quantity].inspect)
            #Rails.logger.info("------------------------------------------------------------2")
            #Rails.logger.info("------------------------------------------------------------3")
            #Rails.logger.info(params[:select_refDes].inspect)
            #Rails.logger.info("------------------------------------------------------------3")
            #Rails.logger.info("------------------------------------------------------------4")
            #Rails.logger.info(params[:select_description].inspect)
            #Rails.logger.info("------------------------------------------------------------4")
            @file = params[:bom_file]
            if params[:bom_file].split('.')[-1] == 'xls'
	        @xls_file = Roo::Excel.new(params[:bom_path])
            else
                @xls_file = Roo::Excelx.new(params[:bom_path])
            end
            @sheet = @xls_file.sheet(0)
            all_item = []
            @sheet.row(1).each do |item|
                if not item.blank?
                    all_item << '"'+item+'":'+'"'+item+'"'
                end
            end
            all_item = "{"+all_item.join(",")+"}"
            Rails.logger.info("------------------------------------------------------------qq1")
            Rails.logger.info(all_item.inspect)
            Rails.logger.info("------------------------------------------------------------qq2")
            #@parse_result = @sheet.parse(:Qty => "Qty",clean:true)
	    @parse_result = @sheet.parse(JSON.parse(all_item))  
	    #remove first row 
	    @parse_result.shift
            #render "select_column.html.erb" 
            #return false  
            all_use = @sheet.row(1)[params[:partCol].to_i].split("")+@sheet.row(1)[params[:quantityCol].to_i].split("")+@sheet.row(1)[params[:refdesCol].to_i].split("")
            #params[:select_part].each do |use|
	     @parse_result.select! {|item| !item["#{@sheet.row(1)[params[:partCol].to_i]}"].blank? } #选择非空行
            #end
            Rails.logger.info("------------------------------------------------------------qq1")
            Rails.logger.info(all_item.inspect)
            Rails.logger.info("------------------------------------------------------------qq2")
            Rails.logger.info(@parse_result.inspect)
            Rails.logger.info(@sheet.row(1)[params[:partCol].to_i].inspect)
            Rails.logger.info("------------------------------------------------------------qq3")
            #行号
            row_num = 0
           # all_m_bom = []
            #one_m_bom = []
            other_all = @sheet.row(1)-@sheet.row(1)[params[:partCol].to_i].split("")-@sheet.row(1)[params[:quantityCol].to_i].split("")-@sheet.row(1)[params[:refdesCol].to_i].split("")
	    @parse_result.each do |item| #处理每一行的数据 
                mpna = ""
                if item["#{@sheet.row(1)[params[:partCol].to_i]}"].blank?
                    mpna += ""
                else
                    mpna += item["#{@sheet.row(1)[params[:partCol].to_i]}"].to_s + " " 
                end
                qtya = ""
                if item["#{@sheet.row(1)[params[:quantityCol].to_i]}"].blank?
                    qtya += ""
                else
                    qtya += item["#{@sheet.row(1)[params[:quantityCol].to_i]}"].to_s + " "             
                end
                refa = ""
                if item["#{@sheet.row(1)[params[:refdesCol].to_i]}"].blank?
                    refa += ""
                else
                    refa += item["#{@sheet.row(1)[params[:refdesCol].to_i]}"].to_s + " "
                end
                #desa = ""
                #params[:select_description].each do |des|                    
                    #if item["#{des}"].blank?
                        #desa += ""
                    #else
                        #desa += item["#{des}"].to_s + " "
                    #end
                #end
                othera = ""
                other_all.each do |other|                    
                    if item["#{other}"].blank?
                        othera += ""
                    else
                        othera += item["#{other}"].to_s + " "
                    end
                end
	        
		Rails.logger.info("------------------------------------------------------------des")
                Rails.logger.info(mpna.inspect)
                Rails.logger.info(qtya.inspect)
                Rails.logger.info(refa.inspect)
                #Rails.logger.info(desa.inspect)
                Rails.logger.info(othera.inspect)
                Rails.logger.info("------------------------------------------------------------des")
                find_mpn = ProcurementBom.where(bom_id: params[:bom_id],mpn: mpna)
                if find_mpn.blank?
                    bom_item = @bom.bom_items.build() #创建bom_items对象
                    bom_item.part_code = refa
		    #bom_item.description = desa
                    bom_item.quantity = qtya.to_i
                    bom_item.mpn = mpna
                    bom_item.other = othera
                    bom_item.user_id = current_user.id
                    bom_item.save
                end
            end
            
            #render "select_column.html.erb" 
            #redirect_to search_part_path(:bom_id => params[:bom_id])
            #return false
            @bom_item = ProcurementBom.where(bom_id: params[:bom_id])
            render "search_part.html.erb"
            return false
        end
                
        if not params[:bak_bom].blank? 
            @bom = ProcurementBom.find(params[:bom_id])
            #if @bom.excel_file_identifier.split('.')[-1] == 'xls'
	        #@xls_file = Roo::Excel.new(@bom.excel_file.current_path)
            #else
                #@xls_file = Roo::Excelx.new(@bom.excel_file.current_path)
            #end
            #@sheet = @xls_file.sheet(0)
            #render "select_column.html.erb"
            redirect_to select_column_path(bom: @bom)
            return false
        end

        @bom = ProcurementBom.new(bom_params)#使用页面传进来的文件名字作为参数创建一个bom对象
        @bom.user_id = current_user.id
        @file = @bom.excel_file_identifier
        @bom.no = "MB" + Time.new.strftime('%Y').to_s[-1] + Time.new.strftime('%m%d').to_s + "B" + Bom.find_by_sql('SELECT Count(boms.id)+1 AS all_no FROM boms WHERE to_days(boms.created_at) = to_days(NOW())').first.all_no.to_s + "B"
        #如果上传成功
	if @bom.save
            #if @bom.excel_file_identifier.split('.')[-1] == 'xls'
	        #@xls_file = Roo::Excel.new(@bom.excel_file.current_path)
            #else
                #@xls_file = Roo::Excelx.new(@bom.excel_file.current_path)
            #end
            #@sheet = @xls_file.sheet(0)
            #render "select_column.html.erb"
            redirect_to p_select_column_path(bom: @bom)  
            return false
        end 
    end

    def select_column
        @sheet = params[:sheet]
        @bom = ProcurementBom.find(params[:bom])
        if @bom.excel_file_identifier.split('.')[-1] == 'xls'
	    @xls_file = Roo::Excel.new(@bom.excel_file.current_path)
        else
            @xls_file = Roo::Excelx.new(@bom.excel_file.current_path)
        end
        @sheet = @xls_file.sheet(0)
    end















    private














        def bom_params
  	    params.require(:bom).permit(:name, :excel_file)
  	end







end
