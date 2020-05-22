class AddClientSecretsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :client_secrets, id: :uuid do |t|
      t.column :client_id, "uuid"
      t.string :secret
    end

    up_only do
      execute <<-SQL
        INSERT INTO client_secrets (client_id, secret)
        SELECT id AS client_id, crypt(secret, gen_salt('bf')) AS secret
        FROM clients
      SQL
    end

    remove_column :clients, :secret, :string
  end
end
