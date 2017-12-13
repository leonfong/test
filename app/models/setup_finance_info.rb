class SetupFinanceInfo < ActiveRecord::Base
	belongs_to :user

	def self.current_rate
		order(id: :desc).last
	end
end
