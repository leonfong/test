class OauthController < ApplicationController
before_filter :authenticate_user!
    def callback

        url = 'https://openapi.b.qq.com/oauth2/companyToken?'
        if not params[:code].blank?
            url += 'grant_type=authorization_code&'
            url += 'app_id=200710667&'
            url += 'app_secret=9DBKbtctgDAZMjfR&'
            url += 'code='
            url += params[:code]
            url += '&state='
            url += params[:state]
            url += '&redirect_uri=http://www.fastbom.com/oauth/callback'    
        end  
        #Rails.logger.info(mpn.inspect)

        resp = Net::HTTP.get_response(URI(url))
        server_response = JSON(resp.body)
          

        oauth = Oauth.new
        oauth.company_id = resp['data']['company_id']
        oauth.company_token = resp['data']['company_token']
        oauth.expires_in = resp['data']['expires_in']
        oauth.refresh_token = resp['data']['refresh_token']
        oauth.save

        @ret = "{'ret':0}"
        render json: @ret
    end
end
