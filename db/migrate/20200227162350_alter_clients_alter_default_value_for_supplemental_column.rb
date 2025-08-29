class AlterClientsAlterDefaultValueForSupplementalColumn < ActiveRecord::Migration[6.0]
  def change
    change_column_default :clients, :supplemental, from: "{}", to: {}
  end
end
