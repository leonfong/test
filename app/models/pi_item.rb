class PiItem < ActiveRecord::Base
	belongs_to :pi_info
	validates :pi_id , presence: true

end
