class GameSession < ApplicationRecord
  belongs_to :user, optional: true
  has_many :spins, dependent: :destroy

  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  # attempt a spin, wrapped in DB transaction
  def perform_spin(bet:, engine: SpinEngine)
    raise ArgumentError, 'Bet must be positive' unless bet.to_i > 0

    transaction do
      raise "Insufficient balance" if balance < bet

      # lock row to prevent concurrent spending
      lock!

      # compute result
      spin_result = engine.spin
      payout = engine.calculate_payout(spin_result, bet)

      self.balance -= bet
      self.balance += payout
      save!

      spins.create!(result: spin_result.to_json, bet: bet, win: payout)
    end
  end
end