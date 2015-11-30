class ChangeForProducts < ActiveRecord::Migration
  def change
    add_column :products, :value1, :string
    add_column :products, :value2, :string
    add_column :products, :value3, :string
    add_column :products, :value4, :string
    add_column :products, :value5, :string
    add_column :products, :value6, :string
    add_column :products, :value7, :string
    add_column :products, :value8, :string
  end
end
