module Error
  class AuthorizationError < StandardError
    attr_reader :status, :error, :message

    def initialize(_error=nil, _status=nil, _message=nil)
      @error = _error || 401
      @status = _status || :unauthorized
      @message = _message || 'Not authorized'
    end

    def fetch_json
      Helpers::Render.json(error, message, status)
    end
  end
end