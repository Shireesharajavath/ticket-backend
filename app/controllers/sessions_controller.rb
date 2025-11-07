class SessionsController < ApplicationController
  # Skip authentication for login (create) and logout (destroy)
  skip_before_action :authenticate_request!, only: [:create]
  before_action :authenticate_request!, only: [:destroy]
  # POST /login
  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      render json: {
        message: "Login successful",
        token: token,
        email: user.email,
        user_id: user.id
      }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  # DELETE /logout
  def destroy
    # JWT logout is stateless — frontend should just delete the token
    render json: { message: "Logged out successfully" }, status: :ok
  end
end
