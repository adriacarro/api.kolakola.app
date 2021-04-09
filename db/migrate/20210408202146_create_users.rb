class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.integer :role
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :locked_at
      t.integer :failed_attempts
      t.integer :sign_in_count
      t.datetime :sign_in_at
      t.datetime :invited_at
      t.string :invite_token
      t.boolean :invite_accepted

      t.timestamps
    end
  end
end
