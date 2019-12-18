class CreateClientsTable < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'uuid-ossp'
    enable_extension 'pgcrypto'

    create_table :clients, id: :uuid do |t|
      t.string :name
      t.string :secret
    end
  end
end
