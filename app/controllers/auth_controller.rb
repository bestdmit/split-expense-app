class AuthController < ApplicationController
  # POST /register
  def register
    # to_s — на случай, если пароль прислали числом, а не строкой
    user = User.new(email: params[:email], password: params[:password].to_s)

    if user.save
      render json: { token: JsonWebToken.encode(user.id) }, status: 201
    else
      render json: { errors: user.errors.full_messages }, status: 422
    end
  end

  # POST /login
  def login
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      render json: { token: JsonWebToken.encode(user.id) }
    else
      render json: { error: "Invalid email or password" }, status: 401
    end
  end

  # POST /refresh
  def refresh
    # Заголовок приходит в виде "Bearer <токен>", берём последнее слово
    token = request.headers["Authorization"].to_s.split(" ").last
    payload = JsonWebToken.decode(token)

    if payload
      render json: { token: JsonWebToken.encode(payload["user_id"]) }
    else
      render json: { error: "Invalid or expired token" }, status: 401
    end
  end
end
