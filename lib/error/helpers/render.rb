module Error::Helpers
  class Render
    def self.json(_error, _status, _message, _errors)
      h = {
        status: _status,
        error: _error,
        message: _message
      }
      h.merge!(errors: _errors) if _errors.any?
      h.as_json
    end
  end
end