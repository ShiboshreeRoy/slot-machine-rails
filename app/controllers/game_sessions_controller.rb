class GameSessionsController < ApplicationController
  before_action :set_session

  def show
    # renders the slot UI
  end

  def spin
    bet = params[:bet].to_i.clamp(1, 100)

    begin
      @session.perform_spin(bet: bet)
      latest_spin = @session.spins.order(created_at: :desc).first

      render json: {
        success: true,
        balance: @session.balance,
        spin: {
          reels: JSON.parse(latest_spin.result.to_s)['reels'],
          win: latest_spin.win
        }
      }
    rescue => e
      render json: { success: false, error: e.message }, status: :unprocessable_entity
    end
  end

  private

  def set_session
    # for production, associate with current_user
    if defined?(current_user) && current_user
      @session = GameSession.find_or_create_by(user: current_user)
    else
      # fallback to first session in development or create a guest session
      @session = GameSession.first || GameSession.create!(balance: 1000)
    end
  end
end