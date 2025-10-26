class CreateSpins < ActiveRecord::Migration[7.2]
  def change
    create_table :spins do |t|
      t.references :game_session, null: false, foreign_key: true
      t.json :result
      t.integer :bet
      t.integer :win

      t.timestamps
    end
  end
end
