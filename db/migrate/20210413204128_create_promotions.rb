class CreatePromotions < ActiveRecord::Migration[6.1]
  def change
    create_table :promotions do |t|
      t.references :place, null: false, foreign_key: true
      t.json :title
      t.json :message
      t.integer :position

      t.timestamps
    end
  end
end
