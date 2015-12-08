class AddPreferToProducts < ActiveRecord::Migration
  def change
    add_column :products, :prefer, :integer, :default => 0
  end
end
