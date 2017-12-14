module BomsHelper
	def get_query_str(query_str)
	  ary_nc = query_str.scan(/[0-9]+\.?[0-9]*[a-zA-Z]+/i)
	  ary_n = query_str.scan(/[0-9]+[%]*/)

	  ary_q = ary_nc | ary_n 

	  str = ary_q.join(" ")

	end

	# 当前pi的bom信息
	def self.current_bom_info pi
		if pi.moko_bom_info.nil?
			bom_no = '询价BOM_'+pi.procurement_bom.id.to_s
			bom_url = '/p_viewbom?bom_id='+pi.procurement_bom.id.to_s
			# 兼容之前没有添加cache_count之前的总类数
			if pi.procurement_bom.p_items_count.blank?
				pi.procurement_bom.update p_items_count: pi.procurement_bom.p_items.size
			end
			bom_num = pi.procurement_bom.p_items_count
		else
			bom_no = '原始BOM_'+pi.moko_bom_info.id.to_s
			bom_url = '/moko_view_bom?bom_id='+pi.moko_bom_info.id.to_s
			# 兼容之前没有添加cache_count之前的总类数
			if pi.moko_bom_info.p_items_count.blank?
				pi.moko_bom_info.update moko_bom_items_count: pi.moko_bom_info.moko_bom_items.size
			end
			bom_num = pi.moko_bom_info.moko_bom_items_count
		end
		{no: bom_no, url: bom_url, num: bom_num}
	end
end
