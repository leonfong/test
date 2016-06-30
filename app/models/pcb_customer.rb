class PcbCustomer < ActiveRecord::Base
    mount_uploader :attachment, ExcelUploader
	
end
