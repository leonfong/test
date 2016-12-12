class PiBomQtyInfoItem < ActiveRecord::Base
    belongs_to :pi_bom_qty_info
    validates :pi_bom_qty_info_id , presence: true
end
