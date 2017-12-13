module ApplicationHelpers
  module Assets
    # assets
    def use_css name, options={}
      content_for :css do
        stylesheet_link_tag name, options
      end
    end

    def use_js name, options={}
      content_for :javascript do
        javascript_include_tag name, options
      end
    end
  end
end
