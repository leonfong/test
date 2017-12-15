class AddFinanceHideToPiInfo < ActiveRecord::Migration
  def change
    add_column :pi_infos, :finance_hide, :boolean, default: false
  end
end
