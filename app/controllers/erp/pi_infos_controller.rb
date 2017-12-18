module Erp
	class PiInfosController < BaseController
		def index
			params[:page] ||= 1
			@search_type = params[:search_type] || 'pi'
			@search_name = params[:search_name]
			@pi_lists = PiInfo.where("finance_state <> ''").where(finance_hide: false)
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
			@pi_lists = @pi_lists.order(id: :desc).paginate(:page => params[:page], :per_page => 10)
		end

		# pi金额跟踪列表
		def amount_tracking_list
			params[:page] ||= 1
			@search_type = params[:search_type] || 'pi'
			@search_name = params[:search_name]
			@pi_lists = PiInfo.where("finance_state <> ''").where(settlement_hide: false)
			unless params[:search_time].blank?
				search_time = params[:search_time].to_time
				@pi_lists = @pi_lists.where(settled_at: search_time..(search_time+1.day) )
			end
			unless params[:search_name].blank?
				search_name = params[:search_name].downcase
				case params[:search_type]
					when 'pi'
						@pi_lists = @pi_lists.where('lower(pi_no) LIKE ?', "%#{search_name}%")
					when 'yw'
						@pi_lists = @pi_lists.joins(:user).where('lower(users.full_name) LIKE ?', "%#{search_name}%")
				end
			end
			@pi_lists = @pi_lists.order(id: :desc).paginate(:page => params[:page], :per_page => 10)
			@ids = @pi_lists.ids
		end

		# 财务审核页面
		def show
			@pi = PiInfo.find params[:id]
		end

		# 财务审核操作
		def finance_check
			pi = PiInfo.find params[:id]
			pi.transaction do
				update_info = {finance_state: 'checked'}
				if pi.bom_state == 'checked'
					update_info.merge! state: 'checked'
				end
				u = pi.update update_info
				if u
					flash[:success] = '审核成功'
					pi.erp_add_new_record_to_obj({user: current_user, con: '通过PI审核'})
				else
					flash[:error] = '审核失败，请联系管理员'
					logger.info pi.errors.full_message.inspect
				end
			end
			redirect_to erp_pi_info_path pi
		end

		# 财务驳回操作
		def finance_uncheck
			pi = PiInfo.find params[:id]
			pi.transaction do
				if pi.update finance_state: nil, state: 'uncheck'
					flash[:success] = '已驳回'
					pi.erp_add_new_record_to_obj({user: current_user, con: '驳回PI审核'})
					redirect_to erp_pi_infos_path
				else
					flash[:error] = '驳回失败，请联系管理员'
					redirect_to erp_pi_info_path pi
				end
			end
		end

		# 财务关闭PI,在PI列表中
		def finance_set_hide
			pi = PiInfo.find params[:id]
			pi.transaction do
				if pi.update finance_hide: true
					flash[:success] = '已关闭'
					pi.erp_add_new_record_to_obj({user: current_user, con: '在PI列表关闭隐藏此PI'})
				else
					flash[:error] = '关闭失败，请联系管理员'
				end
			end
			redirect_to erp_pi_infos_path
		end

		# 在PI金额跟踪表中，关闭PI
		def set_settlement_hide
			if params[:ids].blank?
				flash[:error] = '请选择要关闭的PI!'
			else
				ids = params[:ids].split(',')
				action_error = false
				PiInfo.transaction do
					pi = PiInfo.find ids
					pi.each do |p|
						if p.update settlement_hide: true
							p.erp_add_new_record_to_obj({user: current_user, con: '在PI金额跟踪表关闭隐藏此PI'})
						else
							action_error = true
						end
					end
					if action_error
						flash[:error] = '关闭失败，请联系管理员'
					else
						flash[:success] = '已关闭'
					end
				end
			end
			redirect_to amount_tracking_list_erp_pi_infos_path
		end

		# 财务设置为已结算
		def set_settled
			pi = PiInfo.find params[:id]
			pi.transaction do
				if pi.update finance_state: 'already_settled', settled_at: Time.now
					flash[:success] = '设置结算成功'
					pi.erp_add_new_record_to_obj({user: current_user, con: '设置为已结算'})
				else
					flash[:error] = '设置结算失败，请联系管理员'
				end
			end
			redirect_to amount_tracking_list_erp_pi_infos_path
		end
	end
end