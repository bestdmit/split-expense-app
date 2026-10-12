# Демо-данные для показа на защите. Запуск: bin/rails db:seed
# Можно запускать повторно: участники и траты демо-пользователя пересоздаются заново.

user = User.find_or_create_by!(email: "demo@example.com") do |u|
  u.password = "secret123"
end

user.participants.destroy_all

anna = user.participants.create!(name: "Аня")
boris = user.participants.create!(name: "Боря")
vera = user.participants.create!(name: "Вера")

anna.expenses.create!(title: "Такси", amount: 900)
anna.expenses.create!(title: "Продукты", amount: 600)
boris.expenses.create!(title: "Кофе", amount: 300)

puts "Демо-пользователь: demo@example.com / secret123"
