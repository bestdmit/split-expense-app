require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "owner@example.com", password: "secret123")
  end

  # --- Валидации ---

  test "validations: email must be unique" do
    copy = User.new(email: "owner@example.com", password: "secret123")

    assert_not copy.valid?
    assert copy.errors[:email].any?
  end

  test "validations: password must be at least 6 characters" do
    user = User.new(email: "new@example.com", password: "12345")

    assert_not user.valid?
    assert user.errors[:password].any?
  end

  # --- balances ---

  test "balances: paid minus equal share of all expenses" do
    anna = @user.participants.create!(name: "Anna")
    boris = @user.participants.create!(name: "Boris")
    vera = @user.participants.create!(name: "Vera")
    anna.expenses.create!(title: "Taxi", amount: 90)
    boris.expenses.create!(title: "Coffee", amount: 30)

    balances = @user.balances

    # Всего 120, на троих — по 40 с каждого
    assert_equal 50, balances[anna]
    assert_equal(-10, balances[boris])
    assert_equal(-40, balances[vera])
    assert_equal 0, balances.values.sum
  end

  test "balances: empty when there are no participants" do
    assert_equal({}, @user.balances)
  end

  # --- settlement ---

  test "settlement: two people, one paid -> one transfer" do
    anna = @user.participants.create!(name: "Anna")
    boris = @user.participants.create!(name: "Boris")
    anna.expenses.create!(title: "Pizza", amount: 1000)

    transfers = @user.settlement

    assert_equal 1, transfers.size
    assert_equal boris, transfers[0][:from]
    assert_equal anna, transfers[0][:to]
    assert_equal 500, transfers[0][:amount]
  end

  test "settlement: three people, one paid for all -> two transfers" do
    anna = @user.participants.create!(name: "Anna")
    boris = @user.participants.create!(name: "Boris")
    vera = @user.participants.create!(name: "Vera")
    anna.expenses.create!(title: "Hotel", amount: 900)

    transfers = @user.settlement

    assert_equal 2, transfers.size
    assert transfers.all? { |t| t[:to] == anna && t[:amount] == 300 }
    payers = transfers.map { |t| t[:from] }
    assert_includes payers, boris
    assert_includes payers, vera
  end

  test "settlement: no transfers when everyone is even" do
    anna = @user.participants.create!(name: "Anna")
    boris = @user.participants.create!(name: "Boris")
    anna.expenses.create!(title: "Lunch", amount: 200)
    boris.expenses.create!(title: "Dinner", amount: 200)

    assert_equal [], @user.settlement
  end

  test "settlement: biggest debtor pays biggest creditor first" do
    anna = @user.participants.create!(name: "Anna")
    boris = @user.participants.create!(name: "Boris")
    vera = @user.participants.create!(name: "Vera")
    anna.expenses.create!(title: "Taxi", amount: 90)
    boris.expenses.create!(title: "Coffee", amount: 30)

    transfers = @user.settlement

    # Балансы: Anna +50, Boris -10, Vera -40
    assert_equal 2, transfers.size
    assert_equal [ vera, anna, 40 ], transfers[0].values_at(:from, :to, :amount)
    assert_equal [ boris, anna, 10 ], transfers[1].values_at(:from, :to, :amount)
  end
end
