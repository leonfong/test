class PcbOrderSellItem < ActiveRecord::Base
    mount_uploader :att, ExcelUploader
end
