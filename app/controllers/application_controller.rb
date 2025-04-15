class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_user!

  private

  def authenticate_user!
    unless current_user
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def current_user
    @current_user ||= begin
      authenticate_with_http_token do |token, _options|
        payload = AuthenticationService.decode_token(token)
        User.find_by(id: payload['user_id']) if payload
      end
    end
  end

  def current_organization
    @current_organization ||= current_user&.organization
  end
end
