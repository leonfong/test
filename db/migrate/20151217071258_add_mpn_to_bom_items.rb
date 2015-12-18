class AddMpnToBomItems < ActiveRecord::Migration
def change
    add_column :bom_items, :mpn, :string
end
end
