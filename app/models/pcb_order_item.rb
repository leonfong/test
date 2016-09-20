class PcbOrderItem < ActiveRecord::Base
    belongs_to :pcb_order
    mount_uploader :att, ExcelUploader
end
