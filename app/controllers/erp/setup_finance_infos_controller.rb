module Erp
	class SetupFinanceInfosController < BaseController
		def create
			u = current_user.setup_finance_infos.create(rate_params)
			if u
				flash[:success] = "设置汇率成功！"
			else
				flash[:error] = "设置失败，请联系管理员"
			end
			redirect_to erp_finance_setting_index_path
		end

		private
		def rate_params
			params.require(:setup_finance_info).permit(:dollar_rate)
		end
	end
end