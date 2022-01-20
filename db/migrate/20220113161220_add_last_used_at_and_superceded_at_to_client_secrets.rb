class AddLastUsedAtAndSupercededAtToClientSecrets < ActiveRecord::Migration[6.1]
  def change
    add_column :client_secrets, :last_used_at, :timestamp
    add_column :client_secrets, :superceded_at, :timestamp
  end
end
