class FinanceVoucherInfo < ActiveRecord::Base
	belongs_to :payment_notice_info
end
