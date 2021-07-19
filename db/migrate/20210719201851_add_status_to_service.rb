class AddStatusToService < ActiveRecord::Migration[6.1]
  def change
    add_column :services, :status, :integer, default: 0
    add_index :services, :status
  end
end
