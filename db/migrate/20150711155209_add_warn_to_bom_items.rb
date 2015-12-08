class AddWarnToBomItems < ActiveRecord::Migration
  def change
    add_column :bom_items, :warn, :boolean
  end
end
