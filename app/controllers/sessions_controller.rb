class SessionsController < ApplicationController
  def create
    user = User.find_by(username: params[:user][:email]) || User.find_by(email: params[:user][:email])

    if user && user.authenticate(params[:user][:password])
      token = JWT.encode({ user_id: user.id }, Rails.application.secret_key_base)
      render json: {
        message: "Login successful",
        user: user,
        token: token
      }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end
end
