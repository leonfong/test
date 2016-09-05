class PItemRemark < ActiveRecord::Base
        mount_uploader :info, ExcelUploader
	belongs_to :p_item
	validates :p_item_id , presence: true
end
