class CreateUsersTable < ActiveRecord::Migration[6.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :name
      t.string :email, :unique
      t.string :password
    end

    add_column :users, :deleted_at, :timestamp
  end
end
