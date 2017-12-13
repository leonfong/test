module Erp
  class BaseController < ApplicationController
    layout "erp"
    before_action :set_locale

    # rescue_from Pundit::NotAuthorizedError, with: :unauthorized

    private
    def set_locale
      I18n.locale = :zh
    end
  end
end
