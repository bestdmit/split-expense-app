class Expense < ApplicationRecord
  # Плательщик траты
  belongs_to :participant

  validates :title, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
end
