class PiInfo < ApplicationModel
	has_many :pi_items, dependent: :destroy
	has_many :pi_other_items, dependent: :destroy
	has_many :pi_sell_items, dependent: :destroy

	enum finance_state: {
		not_check: 0, #未到审核这一步，当前为空
		check: 1, #审核中
		uncheck: 2, #驳回
		checked: 3 #已审核
	}

end
