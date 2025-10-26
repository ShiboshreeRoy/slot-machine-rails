class SpinEngine
  # define symbols and weights
  SYMBOLS = %w[seven cherry lemon bar bell].freeze
  WEIGHTS = {
    'seven' => 1,
    'cherry' => 4,
    'lemon' => 6,
    'bar' => 3,
    'bell' => 2
  }

  # produce an array of 3 symbols (the reels)
  def self.spin
    reels = 3.times.map { weighted_choice }
    { reels: reels }
  end

  def self.weighted_choice
    total = WEIGHTS.values.sum
    point = rand(total)
    cumulative = 0
    WEIGHTS.each do |sym, weight|
      cumulative += weight
      return sym if point < cumulative
    end
  end

  # payout rules
  def self.calculate_payout(result, bet)
    reels = result[:reels]
    if reels.uniq.size == 1
      # jackpot for three of a kind
      case reels.first
      when 'seven' then bet * 50
      when 'bar' then bet * 20
      when 'bell' then bet * 10
      when 'cherry' then bet * 5
      else bet * 3
      end
    elsif reels.uniq.size == 2
      # two of a kind -> small payout
      bet * 2
    else
      0
    end
  end
end