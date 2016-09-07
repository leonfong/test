class PiWhInfo < ActiveRecord::Base
    has_many :pi_wh_items, dependent: :destroy
end
