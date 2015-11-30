class CreateParts < ActiveRecord::Migration
  def change
    create_table :parts do |t|
      t.string :part_code
      t.string :part_name

      t.timestamps null: false
    end
  end
end
