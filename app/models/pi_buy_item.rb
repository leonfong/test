class PiBuyItem < ActiveRecord::Base
	belongs_to :pi_buy_info
	validates :pi_buy_info_id , presence: true
end
