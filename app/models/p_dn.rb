class PDn < ActiveRecord::Base
    mount_uploader :info, ExcelUploader
    #has_one_attache :info

            #self.email = current_user.email

end
