class AddStatusToService < ActiveRecord::Migration[6.1]
  def change
    add_column :services, :status, :integer, default: 1
    add_index :services, :status
  end
end
