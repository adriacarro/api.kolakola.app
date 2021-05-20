class CreateLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :logs, id: :uuid do |t|
      t.references :loggable, polymorphic: true, null: false, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.integer :action, default: 0
      t.jsonb :log_changes

      t.timestamps
    end
  end
end
