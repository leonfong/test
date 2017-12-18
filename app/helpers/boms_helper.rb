module BomsHelper
	def get_query_str(query_str)
	  ary_nc = query_str.scan(/[0-9]+\.?[0-9]*[a-zA-Z]+/i)
	  ary_n = query_str.scan(/[0-9]+[%]*/)

	  ary_q = ary_nc | ary_n 

	  str = ary_q.join(" ")

	end
end
