require "test_helper"

class ParticipantTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "owner@example.com", password: "secret123")
  end

  # --- Валидации ---

  test "validations: name is required" do
    participant = @user.participants.new(name: "")

    assert_not participant.valid?
    assert participant.errors[:name].any?
  end

  # --- Связи ---

  test "associations: user has many participants and their expenses" do
    anna = @user.participants.create!(name: "Anna")
    boris = @user.participants.create!(name: "Boris")
    pizza = anna.expenses.create!(title: "Pizza", amount: 500)
    taxi = boris.expenses.create!(title: "Taxi", amount: 300)

    assert_equal [ anna, boris ], @user.participants.order(:id).to_a
    assert_equal [ pizza ], anna.expenses.to_a
    # has_many :expenses, through: :participants — траты всех участников пользователя
    assert_equal [ pizza, taxi ], @user.expenses.order(:id).to_a
  end

  test "associations: deleting a participant deletes their expenses" do
    anna = @user.participants.create!(name: "Anna")
    anna.expenses.create!(title: "Pizza", amount: 500)

    assert_difference "Expense.count", -1 do
      anna.destroy
    end
  end
end
