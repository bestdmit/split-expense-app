class SessionsController < ApplicationController
  # GET /login — форма входа
  def new
  end

  # POST /login — проверяем пароль и запоминаем пользователя в сессии
  def create
    user = User.find_by(email: params[:email])

    # &. — если пользователь не найден (nil), authenticate не вызывается
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "Вы вошли"
    else
      flash.now[:alert] = "Неверный email или пароль"
      render :new, status: :unprocessable_content
    end
  end

  # DELETE /logout — полностью очищаем сессию
  def destroy
    reset_session
    redirect_to root_path, notice: "Вы вышли"
  end
end
