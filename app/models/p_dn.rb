class PDn < ActiveRecord::Base
    mount_uploader :info, ExcelUploader
    #has_one_attache :info

            #self.email = current_user.email
    belongs_to :p_item
    validates :p_item_id , presence: true

end
