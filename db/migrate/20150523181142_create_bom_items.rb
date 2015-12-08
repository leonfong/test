class CreateBomItems < ActiveRecord::Migration
  def change
    create_table :bom_items do |t|
      t.integer :quantity
      t.string :description
      t.string :part_code
      t.integer :bom_id
      t.integer :product_id

      t.timestamps null: false
    end
  end
end
