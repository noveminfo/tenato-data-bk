module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_user!, only: [:login]

      def login
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          token = ::AuthService.encode_token(user_id: user.id)
          expiration_time = Time.now + AuthService::TOKEN_LIFETIME

          render json: {
            token: token,
            user: {
              id: user.id,
              email: user.email,
              role: user.role
            },
            expires_at: expiration_time.iso8601
          }
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      def me
        render json: user_response_data(current_user)
      end

      def logout
        token = request.headers['Authorization']&.split(' ')&.last
        if token
          AuthService.invalidate_token(token)
          render json: { message: 'Successfully logged out' }
        else
          render json: { error: 'No token provided' }, status: :bad_request
        end
      end

      private

      def user_response_data(user)
        {
          id: user.id,
          email: user.email,
          role: user.role,
          organization_id: user.organization_id,
          created_at: user.created_at
        }
      end
    end
  end
end
