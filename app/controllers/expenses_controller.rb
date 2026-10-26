class ExpensesController < ApplicationController
  before_action :require_login
  before_action :set_expense, only: :destroy

  def index
    @expenses = current_user.expenses.includes(:participant).order(created_at: :desc)
    @expense = current_user.expenses.new
    @participants = current_user.participants.order(:name)
  end

  def create
    participant = current_user.participants.find(expense_params[:participant_id])
    @expense = participant.expenses.new(expense_params.except(:participant_id))
    if @expense.save
      redirect_to expenses_path, notice: "Трата добавлена"
    else
      @expenses = current_user.expenses.includes(:participant).order(created_at: :desc)
      @participants = current_user.participants.order(:name)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @expense.destroy
    redirect_to expenses_path, notice: "Трата удалена"
  end

  private

  def expense_params
    params.require(:expense).permit(:title, :amount, :participant_id)
  end

  def set_expense
    @expense = current_user.expenses.find(params[:id])
  end
end
