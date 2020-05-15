class AlterClientScopesAddId < ActiveRecord::Migration[6.0]
  def change
    add_column :client_scopes,
               :id,
               :uuid,
               primary_key: true, default: -> { 'gen_random_uuid()' }
  end
end
