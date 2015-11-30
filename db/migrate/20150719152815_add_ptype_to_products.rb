class AddPtypeToProducts < ActiveRecord::Migration
  def change
    add_column :products, :ptype, :string, :default => "default"
  end
end
