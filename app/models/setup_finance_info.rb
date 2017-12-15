class SetupFinanceInfo < ActiveRecord::Base
	belongs_to :user

	# 当前的美金汇率
	def self.current_rate
		order(id: :desc).first&.dollar_rate
	end
end
