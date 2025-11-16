class SessionsController < ApplicationController
  skip_before_action :authenticate_request!, only: [:create]
  before_action :authenticate_request!, only: [:destroy]

  # LOGIN
  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      # ✅ Check for an existing active token
      existing_token = user.user_tokens.active.first

      if existing_token
        return render json: {
          message: "Login successful",
          token: existing_token.token,
          email: user.email,
          user_id: user.id
        }, status: :ok
      end

      # 🔹 No active token found → create a new token
      token = JsonWebToken.encode(user_id: user.id)

      UserToken.create!(
        user: user,
        token: token,
        revoked: false,
        expires_at: 24.hours.from_now
      )

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

  # LOGOUT
  def destroy
    token = get_token_from_header
    return render json: { message: "Already logged out" }, status: :ok unless token

    user_token = UserToken.find_by(token: token)
    user_token.update(revoked: true) if user_token

    render json: { message: "Logged out successfully" }, status: :ok
  end

  private

  # Extract token from Authorization header
  def get_token_from_header
    header = request.headers['Authorization']
    return nil unless header.present?
    header.split(" ").last
  end
end
