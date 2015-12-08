class AddPackage2ToProducts < ActiveRecord::Migration
  def change
    add_column :products, :package2, :string, :default => "default"
  end
end
