class ChangeForBoms < ActiveRecord::Migration
  def change
    add_column :boms, :user_id, :integer
  end
end
