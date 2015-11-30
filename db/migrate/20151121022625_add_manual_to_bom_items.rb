class AddManualToBomItems < ActiveRecord::Migration
  def change
    add_column :bom_items, :manual, :boolean
  end
end
