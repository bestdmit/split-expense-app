module JsonWebToken
  # В токене id пользователя и срок годности (exp) — через 24 часа.
  # Подписываем секретным ключом приложения, поэтому подделать токен нельзя.
  def self.encode(user_id)
    payload = { user_id: user_id, exp: 24.hours.from_now.to_i }
    JWT.encode(payload, Rails.application.secret_key_base, "HS256")
  end

  # JWT.decode проверяет подпись и срок и возвращает [данные, заголовок].
  # Если токен испорчен или истёк, он бросает ошибку — тогда возвращаем nil.
  def self.decode(token)
    JWT.decode(token, Rails.application.secret_key_base, true, algorithm: "HS256").first
  rescue JWT::TokenError
    nil
  end
end
