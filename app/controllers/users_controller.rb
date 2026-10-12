class UsersController < ApplicationController
  # GET /signup — показывает пустую форму регистрации
  def new
    @user = User.new
  end

  # POST /signup — создаёт пользователя и сразу входит под ним
  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Аккаунт создан"
    else
      # Показываем форму ещё раз, уже с ошибками из @user.errors
      render :new, status: :unprocessable_content
    end
  end

  private

  # Берём из формы только email и пароль, остальные поля игнорируем
  def user_params
    params.require(:user).permit(:email, :password)
  end
end
