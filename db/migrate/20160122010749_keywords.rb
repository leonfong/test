class Keywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.string :keywords
      t.string :ip
      t.timestamps
    end
  end
end
