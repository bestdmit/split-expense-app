class SettlementsController < ApplicationController
  before_action :require_login

  def show
    @participants = current_user.participants.order(:name)
    @balances = current_user.balances
    @transfers = current_user.settlement
    @total = current_user.expenses.sum(:amount)
    @share = @participants.empty? ? 0 : (@total / @participants.size).round(2)
  end
end
