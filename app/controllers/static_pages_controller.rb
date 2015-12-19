#require 'rubygems'
#require 'json'
#require 'net/http'

class StaticPagesController < ApplicationController
  def home
  end

  def help

  end

  def about
      #url = 'http://octopart.com/api/v3/parts/match?'
     # url += '&queries=' + URI.encode(JSON.generate([{:mpn => 'A000067'}]))
      #url += '&apikey=809ad885'
     # url += '&include[]=descriptions'
     
     # resp = Net::HTTP.get_response(URI.parse(url))
      #@server_response = JSON.parse(resp.body)

     
     # prices_all = []
     # naive_id_all = []
      #@server_response['results'].each do |result|
          #result['items'].each do |part|
              
             # for f in part['offers']      
                
                 # if f['prices'].has_key?"USD"
                     
                      #for p in f['prices']['USD']
                        
                         # prices_all << p[-1].to_f
                         # naive_id_all << f['_naive_id']
                      #end
                  #end
              #end
          #end
      #end
      #@naive_id = naive_id_all[(prices_all.index prices_all.min)]
     
  end

end
