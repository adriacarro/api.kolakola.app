class AddIconToService < ActiveRecord::Migration[6.1]
  def change
    add_column :services, :icon, :string
  end
end
