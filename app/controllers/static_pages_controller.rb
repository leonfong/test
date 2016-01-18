#require 'rubygems'
#require 'json'
#require 'net/http'
require 'open-uri'
require 'open_uri_redirections'

class StaticPagesController < ApplicationController
  def home
  end

  def help

  end

  def about
      url = 'http://api.supplyframe.com/v1/t?d=ls1ki72&p=LM2937IMPX-10%2FNOPB&s=LM2937IMP&h=0-604xKA0Sys8NcPQeLRHw'
      #open(url, :allow_redirections => :safe) {|f|
     #     f.each_line {|line| p line}
      #    url = f.base_uri         
      #    Rails.logger.info(f.base_uri.inspect) 
     # }




      #url = 'http://api.findchips.com/v1/search?apiKey=RDQCwiQN4yhvRYKulcgw&part=LM2937IMP'
      
      #url += '&queries=' + URI.encode(JSON.generate([{:mpn => mpn}]))
      #url += '&apikey=809ad885'
      #url += '&include[]=descriptions'
     
      #resp = Net::HTTP.get_response(URI.parse(url))
      #resp = Net::HTTP.get_response(URI(url))
      #server_response = JSON.parse(resp.body)
      #Rails.logger.info("prices_all--------------------------------------------------------------------------")
      #Rails.logger.info(url.inspect) 
      #Rails.logger.info(resp.code.inspect)                #"200"   
      #Rails.logger.info(resp.content_length.inspect)      #8023   
      #Rails.logger.info(resp.message.inspect)             #"OK"   
      #Rails.logger.info(resp.base_uri.to_s.inspect)    
      #Rails.logger.info(resp.body.inspect)   
      #Rails.logger.info("prices_all--------------------------------------------------------------------------")    
  end

end
