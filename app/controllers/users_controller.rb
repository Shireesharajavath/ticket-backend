class UsersController < ApplicationController
  # POST /signup
  def signup
    user = User.new(user_params)
    if user.save
      render json: { message: "User created successfully", user: user }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /login
  def login
    user = User.find_by(username: params[:username])
    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      render json: { token: token, username: user.username }, status: :ok
    else
      render json: { error: "Invalid username or password" }, status: :unauthorized
    end
  end

  # GET /me
  def me
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    decoded = JsonWebToken.decode(token)
    user = User.find(decoded[:user_id])

    render json: {
      user: {
        id: user.id,
        username: user.username,
        created_at: user.created_at,
        updated_at: user.updated_at
      }
    }, status: :ok
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError
    render json: { error: "Invalid or expired token" }, status: :unauthorized
  end

  private

  def user_params
    params.permit(:username, :password)
  end
end
