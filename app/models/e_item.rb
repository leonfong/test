class EItem < ActiveRecord::Base
	belongs_to :e_bom

	# has_one :product, as: :match_product
	#has_one :product, as: :product_able


	validates :e_bom_id , presence: true
end
