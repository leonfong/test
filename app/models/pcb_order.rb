class PcbOrder < ActiveRecord::Base
    has_many :pcb_order_sell_items, dependent: :destroy
    has_many :pcb_order_items, dependent: :destroy
    mount_uploader :att, ExcelUploader
end
