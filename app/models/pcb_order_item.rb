class PcbOrderItem < ActiveRecord::Base
    belongs_to :pcb_orders
    mount_uploader :att, ExcelUploader
end
