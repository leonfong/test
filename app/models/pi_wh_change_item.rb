class PiWhChangeItem < ActiveRecord::Base
	belongs_to :pi_wh_change_info
	#validates :pi_wh_info_id , presence: true
end
