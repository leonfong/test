class AddHasOneToProduct < ActiveRecord::Migration
  def change
  	add_column :products, :product_able_id, :integer
  	add_column :products, :product_able_type, :string

  	add_index(:products, [:product_able_id,:product_able_type])

  end
end
