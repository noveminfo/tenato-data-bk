class AuthService
  def self.encode_token(payload)
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end

  def self.decode_token(token)
    JWT.decode(token, Rails.application.credentials.secret_key_base).first
  rescue JWT::DecodeError
    nil
  end
end
