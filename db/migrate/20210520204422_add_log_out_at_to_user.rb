class AddLogOutAtToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :log_out_at, :datetime
  end
end
