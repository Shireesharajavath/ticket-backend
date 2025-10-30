class ApplicationController < ActionController::API
  before_action :set_current_user_from_token

  private

  def set_current_user_from_token
    header = request.headers['Authorization']
    token = header.split(' ').last if header.present?
    decoded = JsonWebToken.decode(token) if token
    @current_user = User.find_by(id: decoded[:user_id]) if decoded
  rescue
    @current_user = nil
  end

  def authenticate_request!
    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end
end
