module Erp
	class PayTypesController < BaseController
		def create
			u = current_user.pay_types.create(type_params)
			if u
				flash[:success] = "添加支付方式成功！"
			else
				flash[:error] = "添加支付方式失败，请联系管理员"
			end
			redirect_to erp_finance_setting_index_path
		end

		def update
			bank = BankInfo.find params[:id]
			if bank.update(bank_params)
				flash[:success] = "修改银行成功！"
			else
				flash[:error] = "修改银行失败，请联系管理员"
			end
			redirect_to erp_finance_setting_index_path
		end

		def destroy
			bank = BankInfo.find params[:id]
			if bank.delete
				flash[:success] = "删除银行成功！"
			else
				flash[:error] = "删除银行失败，请联系管理员"
			end
			redirect_to erp_finance_setting_index_path
		end

		private
		def type_params
			params.require(:pay_type).permit(:type_name)
		end
	end
end