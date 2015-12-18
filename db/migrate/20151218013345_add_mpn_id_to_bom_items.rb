class AddMpnIdToBomItems < ActiveRecord::Migration
  def change
    add_column :bom_items, :mpn_id, :integer
  end
end
