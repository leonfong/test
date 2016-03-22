require 'rufus-scheduler'
scheduler = Rufus::Scheduler.new

scheduler.every '100h' do  #在10分钟以后执行一次任务
    all_mpn = AllPart.all
    all_mpn.each do |item|
        time =  (Time.new.strftime('%Y-%m-%d %H:%M:%S').to_s.to_time.to_i - item.updated_at.strftime('%Y-%m-%d %H:%M:%S').to_s.to_time.to_i)/86400.00
        part_day = format("%.2f",time)
        Rails.logger.info("11111111111111111111111111111")
        Rails.logger.info(Time.new.strftime('%Y-%m-%d %H:%M:%S').inspect)
        Rails.logger.info(item.updated_at.strftime('%Y-%m-%d %H:%M:%S').inspect)
        Rails.logger.info(part_day.inspect)
        Rails.logger.info("11111111111111111111111111111111")
        if part_day.to_f > 2      
            mpn = item.mpn
            #mpn = "LM2937IMP"
            url = 'http://api.findchips.com/v1/search?apiKey=RDQCwiQN4yhvRYKulcgw&part='
            url += mpn
            Rails.logger.info(mpn.inspect)
            resp = Net::HTTP.get_response(URI.parse(url))
            server_response = JSON.parse(resp.body)
            ##Rails.logger.info("prices_all--------------------------------------------------------------------------")
            #Rails.logger.info(url.inspect) 
            #Rails.logger.info(resp.code.inspect)                #"200"   
            #Rails.logger.info(resp.content_length.inspect)      #8023   
            #Rails.logger.info(resp.message.inspect)             #"OK"       
            #Rails.logger.info(server_response.inspect)   
            ##Rails.logger.info("prices_all--------------------------------------------------------------------------")   
            #Rails.logger.info("prices_all222222222222222222222222222222222222222222222222222222222222222222222222222") 
            #Rails.logger.info(server_response['response'].inspect)
            #Rails.logger.info(resp.body)
            ###Rails.logger.info("prices_all22222222222222222222222222222222222222222222222222222222222222222222") 
            #server_response['response'].each do |it|
                #Rails.logger.info("prices_44444444444444444444444444444444444")
                #Rails.logger.info(it.inspect)
            #end
            info_mpn = InfoPart.new
            info_mpn.mpn = mpn
            info_mpn.info = resp.body
            info_mpn.save
            item.updated_at = Time.new.strftime('%Y-%m-%d %H:%M:%S')
            item.save
        end
    end           
end
#scheduler.join
