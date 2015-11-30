class FixColumnName < ActiveRecord::Migration
  def change
  	rename_column :products, :desc, :description
  	rename_column :boms, :desc, :description
  end
end
