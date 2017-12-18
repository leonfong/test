class SupplierList < ActiveRecord::Base
	belongs_to :pay_type, counter_cache: :supplier_list_count
end
