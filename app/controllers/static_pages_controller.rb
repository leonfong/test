require 'net/http'
class StaticPagesController < ApplicationController
  def home
  end

  def help
  end

  def about
      uri = URI('http://www.findchips.com/search/a000067')
      res = Net::HTTP.get_response(uri)

# Headers
      #res['Set-Cookie']            # => String
      #res.get_fields('set-cookie') # => Array
      #res.to_hash['set-cookie']    # => Array
      #puts "Headers: #{res.to_hash.inspect}"

# Status
      #puts res.code       # => '200'
      #puts res.message    # => 'OK'
      #puts res.class.name # => 'HTTPOK'

# Body
      #puts res.body if res.response_body_permitted?
      @body = res.body
      #uri = URI('http://www.findchips.com/search/C320C103K1R5TA')
      #@body = Net::HTTP.get(uri) # => String
      #@body = res.body 
      Rails.logger.info("00000000000000000000000000000000000000000000000000")
      Rails.logger.info(@body)
      Rails.logger.info("00000000000000000000000000000000000000000000000000000000")
  end

end
