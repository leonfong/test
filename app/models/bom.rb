class Bom < ActiveRecord::Base
	
	mount_uploader :excel_file, ExcelUploader
	
	has_many :bom_items, dependent: :destroy
	#validates :name , presence: true

end
