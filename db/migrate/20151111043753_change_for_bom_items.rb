class ChangeForBomItems < ActiveRecord::Migration
  def change
    add_column :bom_items, :user_id, :integer
  end
end
