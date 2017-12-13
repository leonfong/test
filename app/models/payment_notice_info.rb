class PaymentNoticeInfo < ActiveRecord::Base
	belongs_to :pi_info
	has_one :finance_voucher_info
end
