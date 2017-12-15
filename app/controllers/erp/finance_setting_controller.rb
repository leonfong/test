module Erp
	class FinanceSettingController < BaseController
		def index
			@usa_rate = SetupFinanceInfo.current_rate
			@banks = BankInfo.all.order(id: :desc).to_json
			@pay_types = PayType.all.order(id: :desc).to_json
		end
	end
end