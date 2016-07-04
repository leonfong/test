class PcbOrder < ActiveRecord::Base
    mount_uploader :att, ExcelUploader
end
