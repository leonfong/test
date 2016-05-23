class OauthController < ApplicationController
before_filter :authenticate_user!
    def callback

        url = 'https://openapi.b.qq.com/oauth2/companyToken?'
        if not params[:code].blank?
            url += 'grant_type=authorization_code&'
            url += 'app_id=200710667&'
            url += 'app_secret=9DBKbtctgDAZMjfR'
            url += '&code='
            url += params[:code]
            url += '&state='
            url += params[:state]
            url += '&redirect_uri=http://www.fastbom.com/oauth/callback'    
        end  
        
        resp = Net::HTTP.get_response(URI(url))
        server_response = JSON(resp.body)
        Rails.logger.info("-----------------------------------------------11")  
        Rails.logger.info(server_response['ret'].inspect)
        Rails.logger.info(server_response['msg'].inspect)
        Rails.logger.info(server_response['data'].inspect)
        Rails.logger.info("-----------------------------------------------22")

        if not server_response['data'].blank?
            oauth = Oauth.new
            oauth.company_id = server_response['data']['company_id']
            oauth.company_token = server_response['data']['company_token']
            oauth.expires_in = server_response['data']['expires_in'].to_i
            oauth.refresh_token = server_response['data']['refresh_token']
            oauth.save
        end
        @ret = '{"ret":0}'
        render json: @ret
        return false
    end
end
