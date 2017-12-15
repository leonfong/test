class PayType < ActiveRecord::Base
	has_many :supplier_lists
end
