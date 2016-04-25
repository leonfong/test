class PItem < ActiveRecord::Base
	belongs_to :procurement_bom

	# has_one :product, as: :match_product
	#has_one :product, as: :product_able


	validates :bom_id , presence: true
end
