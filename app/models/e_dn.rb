class EDn < ActiveRecord::Base
    mount_uploader :info, ExcelUploader
end
