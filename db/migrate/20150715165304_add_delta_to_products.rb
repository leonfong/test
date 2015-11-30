class AddDeltaToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :delta, :boolean, :default => true, :null => false
  end
end
