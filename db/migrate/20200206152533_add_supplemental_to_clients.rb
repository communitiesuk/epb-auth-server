class AddSupplementalToClients < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :supplemental, :jsonb, null: false, default: '{}'
  end
end
