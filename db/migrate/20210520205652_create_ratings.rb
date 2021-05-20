class CreateRatings < ActiveRecord::Migration[6.1]
  def change
    create_table :ratings, id: :uuid do |t|
      t.references :user, null: true, foreign_key: true, type: :uuid
      t.references :rateable, polymorphic: true, null: true, type: :uuid
      t.integer :value

      t.timestamps
    end
  end
end
