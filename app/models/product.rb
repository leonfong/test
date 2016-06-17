class Product < ActiveRecord::Base
	#belongs_to :product_item, polymorphic: true
        #has_many :bom_items, as: :product
end
