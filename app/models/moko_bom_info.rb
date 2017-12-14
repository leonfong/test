class MokoBomInfo < ActiveRecord::Base
	mount_uploader :excel_file, ExcelUploader
	mount_uploader :att, ExcelUploader
	has_many :moko_bom_items, dependent: :destroy
	has_one :pi_item
	#validates :name , presence: true
end
