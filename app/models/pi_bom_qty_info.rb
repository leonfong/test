class PiBomQtyInfo < ActiveRecord::Base
    has_many :pi_bom_qty_info_items, dependent: :destroy
end
