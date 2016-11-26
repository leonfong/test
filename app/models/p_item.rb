class PItem < ActiveRecord::Base
    belongs_to :procurement_bom

	# has_one :product, as: :match_product
	#has_one :product, as: :product_able


    validates :procurement_bom_id , presence: true
    has_many :p_item_remarks, dependent: :destroy
    has_many :p_dns, dependent: :destroy
    after_save :send_message, on: :update
    
    protected
        def send_message
            Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
            Rails.logger.info(self.procurement_bom_id.inspect)
            Rails.logger.info("qwqwqwqwqwqwqwqwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
            
            if not self.sell_feed_back_tag.blank?
                if self.sell_feed_back_tag == "sell" and self.buy == ""
                    find_sell = PcbOrderItem.where(bom_id: self.procurement_bom_id)            
                    if not find_sell.blank?
                        find_sell.each do |item|
                            open_id = User.find_by(email: (PcbOrder.find(item.pcb_order_id).order_sell)).open_id
                            oauth = Oauth.find(1)
                            company_id = oauth.company_id
                            company_token = oauth.company_token
                            url = 'https://openapi.b.qq.com/api/tips/send'
                            if not open_id.blank? 
                                url += '?company_id='+company_id
                                url += '&company_token='+company_token
                                url += '&app_id=200710667'
                                url += '&client_ip=120.25.151.208'
                                url += '&oauth_version=2'
                                url += '&to_all=0'  
                                url += '&receivers='+open_id
                                url += '&window_title=Fastbom-PCB AND PCBA'
                                url += '&tips_title='+URI.encode(User.find_by(email: (PcbOrder.find(item.pcb_order_id).order_sell)).full_name+'宝宝')
                                url += '&tips_content='+URI.encode('你有需要关注的物料，点击查看。')
                                url += '&tips_url=erp.fastbom.com/sell_feeback_list'
                                resp = Net::HTTP.get_response(URI(url))
                            end 
                        end
                    end
                end
            end
        end
end
