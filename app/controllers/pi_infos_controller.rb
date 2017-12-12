class PiInfosController < ApplicationController
	def index
		@pi_lists = PiInfo.where("finance_state <> ''")
		unless params[:search_name].blank?
			case params[:search_type]
				when 'pi'
					@pi_lists = @pi_lists.where('pi_no LIKE ?', "%#{params[:search_name]}%")
				when 'yw'
					@pi_lists = @pi_lists.where('sell LIKE ?', "%#{params[:search_name]}%")
				when 'cos'
					@pi_lists = @pi_lists.where('c_des LIKE ?', "%#{params[:search_name]}%")
			end
		end
		@pi_lists = @pi_lists.order(id: :desc).paginate(:page => params[:page], :per_page => 15)
	end
end