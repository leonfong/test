class PcbOrderItem < ActiveRecord::Base
    mount_uploader :att, ExcelUploader
end
