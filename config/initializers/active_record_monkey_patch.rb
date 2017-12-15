class ActiveRecord::Base
	#添加操作日志与备注，默认为添加操作日志，如果要添加备注record_type='remark'
	# logger_info内容格式user-time-con,user-time-con
	def erp_add_new_record_to_obj new_option={user: '', con: ''}, record_type = 'logger_info'
		obj = record_type == 'logger_info'? logger_info : remark
		old_info = obj.blank? ? [] : obj.split(',')
		new_info = new_option[:user].full_name+'/'+Time.now.strftime('%Y-%m-%d %H:%M:%S')+'/'+new_option[:con]
		old_info << new_info
		new_info = old_info.join ','
		update record_type => new_info
	end

	def erp_get_obj_record_arr record_type = 'logger_info'
		obj = record_type == 'logger_info'? logger_info : remark
		info_arr = obj.blank? ? [] : obj.split(',')
		info_arr.map! do |r|
			r_arr = r.split('/')
			{user: r_arr[0], time: r_arr[1], con: r_arr[2]}
		end
		info_arr
	end
end