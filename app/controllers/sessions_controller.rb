class SessionsController < ApplicationController
  skip_before_action :authenticate_request!, only: [:create]
  before_action :authenticate_request!, only: [:destroy]

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      render json: { message: "Login successful", token: token, email: user.email, user_id: user.id }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def destroy
    header = request.headers['Authorization']
    token = header.split(' ').last if header.present?
    BlacklistedToken.create!(token: token) if token.present?
    render json: { message: "Logged out successfully" }, status: :ok
  end
end
