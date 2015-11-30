class BomItem < ActiveRecord::Base
	belongs_to :bom

	# has_one :product, as: :match_product
	#has_one :product, as: :product_able


	validates :description,:bom_id , presence: true
end
