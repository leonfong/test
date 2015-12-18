require 'rubygems'
require 'json'
require 'net/http'

class StaticPagesController < ApplicationController
  def home
  end

  def help

  end

  def about
      url = 'http://octopart.com/api/v3/parts/match?'
      url += '&queries=' + URI.encode(JSON.generate([{:mpn => 'A000067'}]))
      url += '&apikey=809ad885'
      url += '&include[]=descriptions'
     
      resp = Net::HTTP.get_response(URI.parse(url))
      @server_response = JSON.parse(resp.body)

      # print request time (in milliseconds)
      #puts @server_response['msec']
      ##Rails.logger.info("part['mpn']part['mpn']00000000000000000000000000000000000000000000000000")
      ##Rails.logger.info(@server_response['msec'])
      #Rails.logger.info(part.inspect)
      ##Rails.logger.info("part['mpn']part['mpn']00000000000000000000000000000000000000000000000000000000")
      # print mpn's
      prices_all = []
      naive_id_all = []
      @server_response['results'].each do |result|
          result['items'].each do |part|
              ##puts part['mpn']
              #Rails.logger.info("part['mpn']part['mpn']00000000000000000000000000000000000000000000000000")
              #Rails.logger.info(part['mpn'])
              Rails.logger.info(part.inspect)
              #Rails.logger.info("part['mpn']part['mpn']00000000000000000000000000000000000000000000000000000000")
              for f in part['offers']      
                  #Rails.logger.info("prices-------------------------------------------1")
                  #Rails.logger.info(f['prices'].inspect)
                  #Rails.logger.info("prices-------------------------------------------------1")
                  if f['prices'].has_key?"USD"
                      #Rails.logger.info("prices-------------------------------------------3")
                      #Rails.logger.info(f['prices'].inspect)
                      #Rails.logger.info("prices-------------------------------------------------3")
                      for p in f['prices']['USD']
                          #Rails.logger.info("prices-------------------------------------------4")
                          #Rails.logger.info(p[-1].inspect)
                          #Rails.logger.info("prices-------------------------------------------------4")
                          prices_all << p[-1].to_f
                          naive_id_all << f['_naive_id']
                      end
                  end
              end
          end
      end
      @naive_id = naive_id_all[(prices_all.index prices_all.min)]
      Rails.logger.info("prices-------------------------------------------5")
      Rails.logger.info(prices_all.inspect)
      Rails.logger.info(naive_id_all.inspect)
      Rails.logger.info(prices_all.min.inspect)
      Rails.logger.info((prices_all.index prices_all.min).inspect)
      Rails.logger.info(naive_id_all[(prices_all.index prices_all.min)].inspect)
      Rails.logger.info("prices-------------------------------------------------5")
  end

end
