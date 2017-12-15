class AddPiInfoCountToBankInfos < ActiveRecord::Migration
  def change
    add_column :bank_infos, :pi_info_count, :integer, default: 0
    add_column :bank_infos, :user_id, :integer
  end
end
