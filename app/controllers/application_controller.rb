class ApplicationController < ActionController::API
  # always try to set current user from token first
  before_action :set_current_user_from_token

  # enforce authentication by default (controllers/actions can skip)
  before_action :authenticate_request!

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
    render json: { error: "Not Authorized" }, status: :unauthorized unless @current_user
  end
end
