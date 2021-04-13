class CreateLines < ActiveRecord::Migration[6.1]
  def change
    create_table :lines do |t|
      t.references :service, null: true, foreign_key: true
      t.references :customer, null: true, foreign_key: { to_table: :users }
      t.references :worker, null: true, foreign_key: { to_table: :users }
      t.string :code
      t.integer :status, default: 0
      t.integer :position
      t.integer :queueing_time, default: 0
      t.integer :serving_time, default: 0

      t.timestamps
    end
  end
end
