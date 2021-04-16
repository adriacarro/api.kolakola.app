class CreateCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :categories, id: :uuid do |t|
      t.json :name

      t.timestamps
    end
  end
end
