class CreatePayTypes < ActiveRecord::Migration
  def change
    create_table :pay_types do |t|
      t.integer :user_id
      t.string :type_name
      t.integer :supplier_list_count, default: 0
      t.timestamps
    end
    add_column :supplier_lists, :pay_type_id, :integer, :limit => 1
  end
end
