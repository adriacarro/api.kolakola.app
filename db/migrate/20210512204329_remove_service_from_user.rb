class RemoveServiceFromUser < ActiveRecord::Migration[6.1]
  def change
    remove_reference :users, :service, null: true, foreign_key: true
  end
end
