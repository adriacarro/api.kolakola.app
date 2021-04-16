class CreateLines < ActiveRecord::Migration[6.1]
  def change
    create_table :lines, id: :uuid do |t|
      t.references :service, null: true, foreign_key: true, type: :uuid
      t.references :customer, null: true, foreign_key: { to_table: :users }, type: :uuid
      t.references :worker, null: true, foreign_key: { to_table: :users }, type: :uuid
      t.string :code
      t.integer :status, default: 0
      t.integer :position
      t.integer :queueing_time, default: 0
      t.integer :serving_time, default: 0

      t.timestamps
    end
  end
end
