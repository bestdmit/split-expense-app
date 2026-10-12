class User < ApplicationRecord
  # Хранит пароль как bcrypt-хеш в password_digest и добавляет метод authenticate
  has_secure_password

  has_many :participants, dependent: :destroy
  has_many :expenses, through: :participants

  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }

  # Баланс каждого участника: сколько заплатил минус его доля во всех тратах.
  # Плюс — ему должны, минус — он должен.
  # Возвращает хэш { участник => баланс }.
  def balances
    people = participants.to_a
    return {} if people.empty?

    # Каждая трата делится поровну на всех, поэтому доля каждого = общая сумма / число участников
    share = expenses.sum(:amount) / people.size

    people.to_h do |participant|
      paid = participant.expenses.sum(:amount)
      [ participant, (paid - share).round(2) ]
    end
  end

  # Кто кому сколько должен перевести, чтобы все оказались в нуле.
  # Жадный алгоритм: крупнейший должник платит крупнейшему кредитору меньшую из двух сумм, повторяем.
  # Возвращает массив хэшей { from: участник, to: участник, amount: сумма }.
  def settlement
    debtors = []
    creditors = []
    balances.each do |participant, balance|
      debtors << { participant: participant, amount: -balance } if balance.negative?
      creditors << { participant: participant, amount: balance } if balance.positive?
    end

    transfers = []
    while debtors.any? && creditors.any?
      debtor = debtors.max_by { |d| d[:amount] }
      creditor = creditors.max_by { |c| c[:amount] }
      amount = [ debtor[:amount], creditor[:amount] ].min

      transfers << { from: debtor[:participant], to: creditor[:participant], amount: amount }

      debtor[:amount] -= amount
      creditor[:amount] -= amount
      # Кто дошёл до нуля — выбывает. За каждый шаг выбывает хотя бы один, поэтому цикл конечен.
      debtors.delete(debtor) if debtor[:amount].zero?
      creditors.delete(creditor) if creditor[:amount].zero?
    end

    transfers
  end
end
