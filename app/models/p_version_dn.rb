class PVersionDn < ActiveRecord::Base
    mount_uploader :info, ExcelUploader
    #has_one_attache :info
    belongs_to :p_version_item
    validates :p_version_item_id , presence: true
end
