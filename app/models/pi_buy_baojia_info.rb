class PiBuyBaojiaInfo < ActiveRecord::Base
    has_many :pi_buy_baojia_items, dependent: :destroy
end
