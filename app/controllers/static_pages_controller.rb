#require 'rubygems'
#require 'json'
#require 'net/http'
require 'open-uri'
#require 'open_uri_redirections'

class StaticPagesController < ApplicationController
  def home
  end

  def how
      @bom = Bom.new
        #@mpn_show = MpnItem.find_by_sql("SELECT * FROM `mpn_items` LIMIT 0, 30")
      @mpn_show = MpnItem.find_by_sql("SELECT * FROM mpn_items WHERE mpn IS NOT NULL AND id >= ((SELECT MAX(id) FROM mpn_items)-(SELECT MIN(id) FROM mpn_items)) * RAND() + (SELECT MIN(id) FROM mpn_items) LIMIT 100")
      @des_show = Product.find_by_sql("SELECT * FROM products WHERE id >= ((SELECT MAX(id) FROM products)-(SELECT MIN(id) FROM products)) * RAND() + (SELECT MIN(id) FROM products) LIMIT 100")
  end

  def help

  end

  def about
      #urla = 'http://api.supplyframe.com/v1/t?d=ls1ki72&p=LM2937IMPX-10%2FNOPB&s=LM2937IMP&h=0-604xKA0Sys8NcPQeLRHw'
      #open(urla, :allow_redirections => :safe) do |resp|
          #@url = resp.base_uri.to_s
          
      #end
      #Rails.logger.info("uri----------")         
      #Rails.logger.info(@url.inspect) 
      #Rails.logger.info("uri----------") 
      #page = Nokogiri::HTML(open(urla, :allow_redirections => :safe)) 

        
      #Rails.logger.info("uri----------") 
      #Rails.logger.info(page.inspect) 
      #page.css('a').each do |aaa| 
      #    Rails.logger.info(aaa['href'].inspect) 
      #end       
      
      #Rails.logger.info("uri----------") 




      url = 'http://api.findchips.com/v1/search?apiKey=RDQCwiQN4yhvRYKulcgw&part=LM2937IMP'
      
      #url += '&queries=' + URI.encode(JSON.generate([{:mpn => mpn}]))
      #url += '&apikey=809ad885'
      #url += '&include[]=descriptions'
     
      resp = Net::HTTP.get_response(URI.parse(url))
      #resp = Net::HTTP.get_response(URI(url))
      #server_response = JSON.parse(resp.body)
      Rails.logger.info("prices_all--------------------------------------------------------------------------")
      #Rails.logger.info(url.inspect) 
      Rails.logger.info(resp.code.inspect)                #"200"   
      Rails.logger.info(resp.content_length.inspect)      #8023   
      Rails.logger.info(resp.message.inspect)             #"OK"       
      Rails.logger.info(JSON.parse(resp.body).inspect)   
      Rails.logger.info("prices_all--------------------------------------------------------------------------")    
  end

end
