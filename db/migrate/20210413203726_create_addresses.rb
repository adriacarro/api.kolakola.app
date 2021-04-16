class CreateAddresses < ActiveRecord::Migration[6.1]
  def change
    create_table :addresses, id: :uuid do |t|
      t.string :name
      t.string :code
      t.string :street_1
      t.string :street_2
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :country_code

      t.timestamps
    end
  end
end
