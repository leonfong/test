class EBom < ActiveRecord::Base
	
	mount_uploader :excel_file, ExcelUploader
	
	has_many :e_items, dependent: :destroy
	#validates :name , presence: true

end
