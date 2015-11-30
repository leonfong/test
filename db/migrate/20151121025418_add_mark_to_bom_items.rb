class AddMarkToBomItems < ActiveRecord::Migration
  def change
    add_column :bom_items, :mark, :boolean
  end
end
