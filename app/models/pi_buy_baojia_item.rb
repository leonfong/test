class PiBuyBaojiaItem < ActiveRecord::Base
	belongs_to :pi_buy_baojia_info
	validates :pi_buy_baojia_info_id , presence: true
end
