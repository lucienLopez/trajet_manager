class CreateTrajet < ActiveRecord::Migration[5.2]
  def change
    create_table :trajets do |t|
      t.string :code
      t.integer :state

      t.timestamps

      t.index :code
    end
  end
end
