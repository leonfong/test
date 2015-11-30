class AddPackage1ToProducts < ActiveRecord::Migration
  def change
    add_column :products, :package1, :string, :default => "default"
  end
end
