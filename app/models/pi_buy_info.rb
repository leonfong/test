class PiBuyInfo < ActiveRecord::Base
    has_many :pi_buy_items, dependent: :destroy
end
