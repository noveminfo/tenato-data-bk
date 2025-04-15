class ApplicationController < ActionController::API
  before_action :authenticate_user!
  
  private

  def authenticate_user!
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    
    begin
      decoded = AuthService.decode_token(token)
      @current_user = User.find(decoded['user_id'])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def current_organization
    @current_organization ||= current_user&.organization
  end
end