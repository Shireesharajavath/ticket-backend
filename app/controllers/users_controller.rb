class UsersController < ApplicationController
  before_action :authenticate_request!, only: [:show, :update, :me]
  before_action :set_user, only: [:show, :update]
  before_action :authorize_user!, only: [:show, :update]

  # POST /signup
  def create
    user = User.new(user_params)

    if user.save
      render json: {
        message: "User created successfully",
        user: user
      }, status: :created
    else
      render json: {
        errors: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # GET /users/:id
  def show
    render json: @user
  end

  # PATCH/PUT /users/:id
  def update
    if @user.update(user_params)
      render json: {
        message: "User updated successfully",
        user: @user
      }
    else
      render json: {
        errors: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # ➕ NEW ENDPOINT: GET /current_user
  def me
    render json: {
      id: current_user.id,
      email: current_user.email
    }
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  # Check authorization only for show/update
  def authorize_user!
    return if @user == @current_user

    render json: { error: "Not authorized" }, status: :forbidden
  end

  def current_user
    @current_user
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
