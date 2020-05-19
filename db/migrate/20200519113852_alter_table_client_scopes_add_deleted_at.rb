class AlterTableClientScopesAddDeletedAt < ActiveRecord::Migration[6.0]
  def change
    add_column :client_scopes, :deleted_at, :timestamp
  end
end
