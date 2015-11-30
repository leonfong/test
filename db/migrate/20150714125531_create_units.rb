class CreateUnits < ActiveRecord::Migration
  def change
    create_table :units do |t|
      t.string :unit
      t.string :targetunit

      t.timestamps null: false
    end
  end
end
