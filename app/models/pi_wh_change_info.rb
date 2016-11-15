class PiWhChangeInfo < ActiveRecord::Base
    has_many :pi_wh_change_items, dependent: :destroy
end
