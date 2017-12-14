module Erp
	class PiInfosController < BaseController
		def index
			params[:page] ||= 1
			@search_type = params[:search_type] || 'pi'
			@search_name = params[:search_name]
			@pi_lists = PiInfo.where("finance_state <> ''")
			unless params[:search_name].blank?
				search_name = params[:search_name].downcase
				case params[:search_type]
					when 'pi'
						@pi_lists = @pi_lists.where('lower(pi_no) LIKE ?', "%#{search_name}%")
					when 'yw'
						@pi_lists = @pi_lists.joins(:user).where('lower(users.full_name) LIKE ?', "%#{search_name}%")
					when 'cos'
						@pi_lists = @pi_lists.joins(:pcb_customer).where('lower(pcb_customers.c_no) LIKE ?', "%#{search_name}%")
				end
			end
			@pi_lists = @pi_lists.order(id: :desc).paginate(:page => params[:page], :per_page => 15)
		end

		# 财务审核页面
		def show
			@pi = PiInfo.find params[:id]
			# 获取当前bom信息,
			# 返回{no: bom_no, url: bom_url, num: bom_num}
			@bom = BomsHelper.current_bom_info @pi
		end

		# 财务审核操作
		def finance_check
			pi = PiInfo.find params[:id]
			update_info = {finance_state: 'checked'}
			if pi.bom_state == 'checked'
				update_info.merge! state: 'checked'
			end
			if !pi.update update_info
				flash[:error] = '审核失败，请联系管理员'
				logger.info pi.errors.full_message.inspect
			end
			redirect_to erp_pi_info_path pi
		end
	end
end