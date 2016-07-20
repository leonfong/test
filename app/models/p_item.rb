class PItem < ActiveRecord::Base
	belongs_to :procurement_bom

	# has_one :product, as: :match_product
	#has_one :product, as: :product_able


	validates :procurement_bom_id , presence: true
        has_many :p_item_remarks, dependent: :destroy
end
