class CreateBoms < ActiveRecord::Migration
  def change
    create_table :boms do |t|
      t.string :name
      t.string :desc
      t.string :excel_file

      t.timestamps null: false
    end
  end
end
