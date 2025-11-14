class ApplicationController < ActionController::API
  before_action :set_current_user_from_token
  before_action :authenticate_request!

  private

  def set_current_user_from_token
    header = request.headers['Authorization']
    token = header.split(' ').last if header.present?
    return @current_user = nil if token.blank?

    # treat blacklisted tokens as invalid
    if BlacklistedToken.exists?(token: token)
      @current_user = nil
      return
    end

    decoded = JsonWebToken.decode(token)
    @current_user = User.find_by(id: decoded[:user_id]) if decoded
  rescue
    @current_user = nil
  end

  def authenticate_request!
    render json: { error: "Not Authorized or token invalid/expired" }, status: :unauthorized unless @current_user
  end
end
