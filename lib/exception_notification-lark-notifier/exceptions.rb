module ExceptionNotificationLarkNotifier
  class Exceptions
    # Generic error
    Error = Class.new(StandardError)

    # Generic HTTP error
    HttpError = Class.new(Error)

    # Generic API error, non 0 response code
    APIError = Class.new(Error)
  end
end
