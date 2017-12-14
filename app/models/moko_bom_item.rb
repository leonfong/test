class MokoBomItem < ActiveRecord::Base
    belongs_to :moko_bom_info, counter_cache: true
    validates :moko_bom_info_id , presence: true
end
