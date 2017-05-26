class WhGetInfo < ActiveRecord::Base
    has_many :wh_get_items, dependent: :destroy 
end
