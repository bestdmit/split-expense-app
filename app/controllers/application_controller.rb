class ApplicationController < ActionController::Base
  # Делает current_user доступным не только в контроллерах, но и во вьюхах
  helper_method :current_user

  private

  # Пользователь, чей id лежит в сессии. Если не вошёл — nil.
  # ||= запоминает результат, чтобы не ходить в базу при каждом вызове.
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # Подключается через before_action на страницах, куда нельзя без входа
  def require_login
    redirect_to login_path, alert: "Сначала войдите" unless current_user
  end
end
