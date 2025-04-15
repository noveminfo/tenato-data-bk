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
    end
  end
end
