class ApplicationController < ActionController::API
  before_action :authenticate_user!

  rescue_from ::AuthenticationError, with: :handle_authentication_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  private

  def authenticate_user!
    header = request.headers['Authorization']
    token = header.split(' ').last if header

    begin
      @decoded = AuthService.decode_token(token)
      @current_user = User.find(@decoded[:user_id])
    rescue AuthenticationError => e
      render json: { error: e.message }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def current_organization
    @current_organization ||= current_user&.organization
  end

  def handle_authentication_error(error)
    render json: { error: error.message }, status: :unauthorized
  end

  def handle_record_not_found(error)
    render json: { error: 'Record not found' }, status: :not_found
  end
end
