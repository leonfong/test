class PcbCustomer < ActiveRecord::Base
    mount_uploader :att, ExcelUploader
	
end
