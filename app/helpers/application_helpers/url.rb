module ApplicationHelpers
  module Url
    def current_url_active(current_controller,current_action=['index'], action_class = 'active')
      action={action:'index'}.merge({action:params[:action]})
      current_controller==params[:controller] && current_action.include?(action[:action]) ? action_class : ''
    end
    def current_active(opts={}, show_opts={})
      show_opts = {show: 'active', default: ''}.merge(show_opts)
      current_active?(opts) ? show_opts[:show] : show_opts[:default]
    end

    def current_active?(opts={})
      out = false
      if opts.is_a? Array
        opts.each do |o|
          unless out
            if current_active? o
              out = true
            end
          end
        end
      else
        opts = {controller: nil, action: nil}.merge(opts)
        opts.all? do |key, value|
          if value.nil? || params[key.to_sym].to_s == value.to_s
            out = true
          end
        end
      end
      out
    end

    def user_avatar(url='', options={})
      url = '' if url.nil?
      image_tag url, {'error-src': image_url('tx.png')}.merge(options)
    end
  end
end
