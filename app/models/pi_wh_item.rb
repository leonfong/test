class PiWhItem < ActiveRecord::Base
	belongs_to :pi_wh_info
	#validates :pi_wh_info_id , presence: true
end
