class PiInfo < ActiveRecord::Base
    has_many :pi_items, dependent: :destroy
    has_many :pi_other_items, dependent: :destroy
end
