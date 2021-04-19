class AddPendingTimeToLine < ActiveRecord::Migration[6.1]
  def change
    add_column :lines, :pending_time, :integer, default: 0
  end
end
