class ProcurementVersionBom < ActiveRecord::Base
    mount_uploader :excel_file, ExcelUploader
    mount_uploader :att, ExcelUploader
    has_many :p_version_items, dependent: :destroy
	#validates :name , presence: true
end
