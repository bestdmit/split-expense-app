require "test_helper"

class ExpenseTest < ActiveSupport::TestCase
  setup do
    user = User.create!(email: "owner@example.com", password: "secret123")
    @payer = user.participants.create!(name: "Anna")
  end

  # --- Валидации ---

  test "validations: valid with title, amount and payer" do
    expense = @payer.expenses.new(title: "Pizza", amount: 500)

    assert expense.valid?
  end

  test "validations: title is required" do
    expense = @payer.expenses.new(title: "", amount: 500)

    assert_not expense.valid?
    assert expense.errors[:title].any?
  end

  test "validations: amount is required" do
    expense = @payer.expenses.new(title: "Pizza", amount: nil)

    assert_not expense.valid?
    assert expense.errors[:amount].any?
  end

  test "validations: amount must be greater than zero" do
    assert_not @payer.expenses.new(title: "Pizza", amount: 0).valid?
    assert_not @payer.expenses.new(title: "Pizza", amount: -100).valid?
  end

  # --- Связи ---

  test "associations: expense belongs to the participant who paid" do
    expense = @payer.expenses.create!(title: "Pizza", amount: 500)

    assert_equal @payer, expense.participant
  end

  test "associations: expense without a payer is invalid" do
    expense = Expense.new(title: "Pizza", amount: 500)

    assert_not expense.valid?
    assert expense.errors[:participant].any?
  end
end
