class AddFinanceHideToPiInfo < ActiveRecord::Migration
  def change
    add_column :pi_infos, :finance_hide, :boolean, default: false
    add_column :pi_infos, :settled_at, :timestamp
    add_column :pi_infos, :sell_tijiao_at, :timestamp
    add_column :pi_infos, :settlement_hide, :boolean, default: false
  end
end
