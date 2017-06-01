class WhOutInfo < ActiveRecord::Base
    has_many :wh_Out_items, dependent: :destroy 
end
