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
		end
	end
end