class CreateClientScopesTable < ActiveRecord::Migration[6.0]
  def change
    create_table :client_scopes, id: false do |t|
      t.column :client_id, "uuid"
      t.string :scope
    end

    add_foreign_key :client_scopes,
                    :clients,
                    column: :client_id,
                    primary_key: :id
  end
end
