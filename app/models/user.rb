class User < ApplicationRecord
  # Хранит пароль как bcrypt-хеш в password_digest и добавляет метод authenticate
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }
end
