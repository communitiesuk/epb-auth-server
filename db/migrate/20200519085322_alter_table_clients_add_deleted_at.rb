class AlterTableClientsAddDeletedAt < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :deleted_at, :timestamp
  end
end
