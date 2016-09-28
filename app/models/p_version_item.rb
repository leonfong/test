class PVersionItem < ActiveRecord::Base
	belongs_to :procurement_version_bom

	# has_one :product, as: :match_product
	#has_one :product, as: :product_able


	validates :procurement_version_bom_id , presence: true
        has_many :p_version_item_remarks, dependent: :destroy
        has_many :p_version_dns, dependent: :destroy
end
