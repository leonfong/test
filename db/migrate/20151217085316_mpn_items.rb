class MpnItems < ActiveRecord::Migration
  def change
    create_table :mpn_items do |t|
      t.string :mpn
      t.string :manufacturer
      t.string :authorized_distributor
      t.string :description
      t.string :price
      t.string :last_update
      t.timestamps
    end
  end
end
