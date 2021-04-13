class CreatePlaces < ActiveRecord::Migration[6.1]
  def change
    create_table :places do |t|
      t.string :name
      t.references :category, null: false, foreign_key: true
      t.references :billing_address, null: false, foreign_key: { to_table: :addresses }
      t.references :address, null: false, foreign_key: true

      t.timestamps
    end
  end
end
