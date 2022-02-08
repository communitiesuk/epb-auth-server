class RenameSupercededToSuperseded < ActiveRecord::Migration[6.0]
  def change
    rename_column :client_secrets, :superceded_at, :superseded_at
  end
end
