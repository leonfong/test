class ProcurementBom < ActiveRecord::Base
	has_many :p_items, dependent: :destroy
	has_one :pi_item

	mount_uploader :excel_file, ExcelUploader
	mount_uploader :att, ExcelUploader
	#validates :name , presence: true
end
