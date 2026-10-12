class Participant < ApplicationRecord
  belongs_to :user
  # Траты, за которые заплатил этот участник
  has_many :expenses, dependent: :destroy

  validates :name, presence: true
end
