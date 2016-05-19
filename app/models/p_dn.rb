class PDn < ActiveRecord::Base
    mount_uploader :info, ExcelUploader
end
