class AuthService
  TOKEN_LIFETIME = 24.hours  # トークンの有効期限を24時間に設定
  # TOKEN_LIFETIME = 30.seconds  # トークンの有効期限を30秒に設定

  def self.encode_token(payload)
    # 有効期限を追加
    payload[:exp] = Time.now.to_i + TOKEN_LIFETIME.to_i
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end

  def self.decode_token(token)
    return nil unless token

    decoded = JWT.decode(
      token,
      Rails.application.credentials.secret_key_base,
      true,
      { algorithm: 'HS256', verify_expiration: true }  # 有効期限の検証を有効化
    ).first

    # シンボルキーのハッシュに変換して返す
    decoded.transform_keys(&:to_sym)
  rescue JWT::ExpiredSignature
    raise AuthenticationError, 'Token has expired'
  rescue JWT::DecodeError
    raise AuthenticationError, 'Invalid token'
  end
end
