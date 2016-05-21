class OauthController < ApplicationController
before_filter :authenticate_user!
    def callback
    end
end
