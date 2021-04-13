class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.integer :role, default: 0
      t.string :cookie
      t.string :first_name
      t.string :last_name
      t.string :email
      t.integer :notification_type, default: 0
      t.string :phone
      t.boolean :active, default: true
      t.references :place, null: true, foreign_key: true
      t.references :service, null: true, foreign_key: true
      t.string :password_digest
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :locked_at
      t.integer :failed_attempts, default: 0
      t.integer :sign_in_count, default: 0
      t.datetime :sign_in_at
      t.datetime :invited_at
      t.string :invite_token
      t.boolean :invite_accepted, default: false

      t.timestamps
      
      t.index [:email], unique: true
      t.index [:reset_password_token], unique: true
    end
  end
end