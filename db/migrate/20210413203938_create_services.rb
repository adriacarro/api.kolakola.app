class CreateServices < ActiveRecord::Migration[6.1]
  def change
    create_table :services do |t|
      t.references :place, null: false, foreign_key: true
      t.json :name
      t.integer :avg_serving_time, default: 0

      t.timestamps
    end
  end
end
