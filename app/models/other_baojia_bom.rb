class OtherBaojiaBom < ActiveRecord::Base
    mount_uploader :excel_file, ExcelUploader
    mount_uploader :att, ExcelUploader
end
