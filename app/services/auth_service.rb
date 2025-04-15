class AuthService
  TOKEN_LIFETIME = 24.hours  # トークンの有効期限を24時間に設定
  # TOKEN_LIFETIME = 30.seconds  # トークンの有効期限を30秒に設定
  BLACKLIST_PREFIX = "blacklisted_token:"

  def self.encode_token(payload)
    # 有効期限を追加
    payload[:exp] = Time.now.to_i + TOKEN_LIFETIME.to_i
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end

  def self.decode_token(token)
    return nil unless token

    # ブラックリストのチェック
    raise ::AuthenticationError, 'Token has been invalidated' if blacklisted?(token)

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

  def self.invalidate_token(token)
    return unless token
    
    # トークンをデコードして有効期限を取得
    decoded = JWT.decode(
      token,
      Rails.application.credentials.secret_key_base,
      true,
      { algorithm: 'HS256', verify_expiration: true }
    ).first

    exp_time = Time.at(decoded['exp']) - Time.now
    
    # トークンをブラックリストに追加
    $redis.setex(
      "#{BLACKLIST_PREFIX}#{token}",
      exp_time.to_i,
      'true'
    )
  rescue JWT::DecodeError
    # トークンが無効な場合は何もしない
    nil
  end

  def self.blacklisted?(token)
    $redis.exists?("#{BLACKLIST_PREFIX}#{token}")
  end
end
