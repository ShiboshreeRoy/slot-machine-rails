class MakeUserOptionalInGameSessions < ActiveRecord::Migration[7.0]
  def change
    change_column_null :game_sessions, :user_id, true
  end
end
