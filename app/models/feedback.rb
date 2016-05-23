class Feedback < ActiveRecord::Base
    after_create :send_message, on: :create
    
    protected
        def send_message
            Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
            Rails.logger.info(self.topic_id.inspect)
            Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
            open_id = User.find_by(email: (Topic.find_by(self.topic_id).user_name)).open_id
            oauth = Oauth.find(1)
            company_id = oauth.company_id
            company_token = oauth.company_token
            url = 'https://openapi.b.qq.com/api/tips/send'
            if not open_id.blank?
                url += '?company_id='+company_id
                url += '&company_token='+company_token
                url += '&app_id=200710667'
                url += '&client_ip=192.168.1.102'
                url += '&oauth_version=2'
                url += '&to_all=0'  
                url += '&receivers='+open_id
                url += '&window_title=MOKO-issue management'
                url += '&tips_title=There is a new reply to you!'
                url += '&tips_content=Click to view' 
                url += '&tips_url=www.fastbom.com/feedback?id='+self.topic_id.to_s 
                resp = Net::HTTP.get_response(URI(url))
                
            end 
            Rails.logger.info("1111111111111111111111111111111111111111111111111")
            Rails.logger.info(server_response = JSON(resp.body)  .inspect)
            Rails.logger.info("111111111111111111111111111111111111111111111111")
            
        end	
end
