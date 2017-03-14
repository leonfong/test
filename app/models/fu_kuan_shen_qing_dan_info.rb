class FuKuanShenQingDanInfo < ActiveRecord::Base
    mount_uploader :info_a, ExcelUploader
    mount_uploader :info_b, ExcelUploader
end
