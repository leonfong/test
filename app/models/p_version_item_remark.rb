class PVersionItemRemark < ActiveRecord::Base
        mount_uploader :info, ExcelUploader
	belongs_to :p_version_item
	validates :p_version_item_id , presence: true
end
