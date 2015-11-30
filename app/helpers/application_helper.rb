module ApplicationHelper

	def full_title(page_title)
		base_title = 'BOM Parser'

		if page_title.empty?
			base_title
		else
			"#{base_title} | #{page_title}"
		end
	end
	

	# Flash messages with Ruby on Rails 4 and Bootstrap 3
	def flash_class_for(flash_type)
	  {
	    success: "alert-success",
	    error:   "alert-danger",
	    alert:   "alert-warning",
	    notice:  "alert-info"
	  }[flash_type.to_sym]

	end
	
end