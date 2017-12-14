class PiItem < ActiveRecord::Base
	belongs_to :pi_info
	belongs_to :moko_bom_info
	belongs_to :procurement_bom, foreign_key: 'bom_id'
	belongs_to :pi_bom_qty_info
	#validates :pi_id , presence: true

end
