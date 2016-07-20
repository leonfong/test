class PItemRemark < ActiveRecord::Base
	belongs_to :p_item
	validates :p_item_id , presence: true
end
