module Erp
	class BankInfosController < BaseController
		def create
			u = current_user.bank_infos.create(bank_params)
			if u
				flash[:success] = "添加银行成功！"
			else
				flash[:error] = "添加银行失败，请联系管理员"
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
		def bank_params
			params.require(:bank_info).permit(:user_name, :bank_name, :bank_account)
		end
	end
end