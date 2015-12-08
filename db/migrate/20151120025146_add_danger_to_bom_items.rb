class AddDangerToBomItems < ActiveRecord::Migration
  def change
    add_column :bom_items, :danger, :boolean
  end
end
