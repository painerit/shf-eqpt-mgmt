class JsonWebToken
  ALGORITHM = "HS256"
  DEFAULT_TTL = 24.hours

  def self.encode(payload, exp: DEFAULT_TTL.from_now)
    body = payload.dup
    body[:exp] = exp.to_i
    body[:iat] = Time.current.to_i

    JWT.encode(body, secret, ALGORITHM)
  end

  def self.decode(token)
    return if token.blank?

    payload, = JWT.decode(token, secret, true, algorithm: ALGORITHM)
    payload.with_indifferent_access
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end

  def self.expires_at
    DEFAULT_TTL.from_now
  end

  def self.secret
    ENV["JWT_SECRET"].presence || Rails.application.secret_key_base
  end

  private_class_method :secret
end