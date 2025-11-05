class UsersController < ApplicationController
  skip_before_action :set_current_user_from_token, only: [:login, :signup]

  # POST /signup
  def signup
    user = User.new(user_params)
    if user.save
      render json: { message: "User created successfully", user: { id: user.id, username: user.username } }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /login
  def login
    creds = params.require(:user).permit(:username, :password)
    user = User.find_by(username: creds[:username])

    if user&.authenticate(creds[:password])
      token = JsonWebToken.encode({ user_id: user.id })
      render json: { token: token, username: user.username }, status: :ok
    else
      render json: { error: "Invalid username or password" }, status: :unauthorized
    end
  end

  # GET /me
  def me
    # reuse set_current_user_from_token logic; current_user should be present
    if current_user
      render json: {
        user: {
          id: current_user.id,
          username: current_user.username,
          created_at: current_user.created_at,
          updated_at: current_user.updated_at
        }
      }, status: :ok
    else
      render json: { error: "Invalid or expired token" }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end
end
