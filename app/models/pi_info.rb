class PiInfo < ApplicationModel
	has_many :pi_items, dependent: :destroy
	has_many :pi_other_items, dependent: :destroy
	has_many :pi_sell_items, dependent: :destroy
	belongs_to :user
	belongs_to :pcb_customer
	has_one :pi_item
	has_many :payment_notice_infos
	has_many :finance_voucher_infos, through: :payment_notice_infos

	enum finance_state: {
		not_check: 0, #未到审核这一步，当前为空
		check: 1, #审核中
		uncheck: 2, #驳回
		checked: 3 #已审核
	}

	enum money_type: {
		USD: 0,
		CNY: 1
	}


	# 当前汇率，用于计算下单时的汇率
	def current_rate
		if USD?
			SetupFinanceInfo.current_rate.to_f
		else
			1
		end
	end

	# 订单金额
	def order_p
		pi_item.pcb_price + pi_item.pcba + pi_item.com_cost + pi_item.unit_price
	end

	# 欠费金额

end
