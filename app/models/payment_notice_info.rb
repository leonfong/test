class PaymentNoticeInfo < ActiveRecord::Base
	belongs_to :pi_info
	has_one :finance_voucher_info

	scope :send_payment_notices, -> { where.not(send_at: nil) }
end
