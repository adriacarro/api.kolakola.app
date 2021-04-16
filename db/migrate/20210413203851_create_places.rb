class CreatePlaces < ActiveRecord::Migration[6.1]
  def change
    create_table :places, id: :uuid do |t|
      t.string :name
      t.references :category, null: false, foreign_key: true, type: :uuid
      t.references :billing_address, null: false, foreign_key: { to_table: :addresses }, type: :uuid
      t.references :address, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
