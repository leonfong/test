class AddInfoToPDns < ActiveRecord::Migration
  def change
    add_column :p_dns, :info_id, :string
  end
end
