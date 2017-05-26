class PiPmcItem < ActiveRecord::Base
    before_update :up_set, on: :update
    
    protected
        def up_set
            self.up_flag = "do"
        end
end
