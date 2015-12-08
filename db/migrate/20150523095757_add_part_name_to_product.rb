class AddPartNameToProduct < ActiveRecord::Migration
  def change
    add_column :products, :part_name, :string
  end
end
