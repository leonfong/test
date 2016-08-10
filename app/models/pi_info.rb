class PiInfo < ActiveRecord::Base
    has_many :pi_items, dependent: :destroy
end
