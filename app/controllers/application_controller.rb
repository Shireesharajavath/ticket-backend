class ApplicationController < ActionController::API
  before_action :authenticate_request!

  private

  def authenticate_request!
    token = get_token_from_header
    return render json: { error: "Token missing" }, status: :unauthorized unless token

    decoded = JsonWebToken.decode(token)
    return render json: { error: "Invalid token" }, status: :unauthorized unless decoded
   
    # Check if token is revoked
    user_token = UserToken.find_by(token: token)
    if user_token&.revoked
      return render json: { error: "Token revoked. Login again." }, status: :unauthorized
    end

    @current_user = User.find_by(id: decoded[:user_id])
    render json: { error: "User not found" }, status: :unauthorized unless @current_user
  end

  def get_token_from_header
    header = request.headers["Authorization"]
    return nil unless header.present?
    header.split(" ").last
  end
end
