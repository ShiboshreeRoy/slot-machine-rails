class Spin < ApplicationRecord
  belongs_to :game_session
  #serialize :result, JSON
end