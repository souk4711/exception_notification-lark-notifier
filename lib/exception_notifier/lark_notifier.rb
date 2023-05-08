module ExceptionNotifier
  class LarkNotifier
    include ExceptionNotifier::BacktraceCleaner

    class << self
      def rails_app_name
        return unless defined?(::Rails) && ::Rails.respond_to?(:application)
        if ::Gem::Version.new(::Rails.version) >= ::Gem::Version.new("6.0")
          ::Rails.application.class.module_parent_name
        else
          ::Rails.application.class.parent_name
        end
      end

      def rails_env_name
        return unless defined?(::Rails) && ::Rails.respond_to?(:env)
        ::Rails.env
      end
    end

    def initialize(options)
      @default_app_name = self.class.rails_app_name
      @default_env_name = self.class.rails_env_name
      @default_options  = options

      @notifier = ExceptionNotificationLarkNotifier::Client.new(
        options.slice(:webhook_url, :webhook_secret, :http)
      )
    end

    def call(exception, call_options = {})
      options  = call_options.merge(@default_options)
      app_name = options.delete(:app_name) || @default_app_name
      env_name = options.delete(:env_name) || @default_env_name

      title = "Exception Occurred"
      title += " in #{app_name}" if app_name
      title += " (env: #{env_name})" if env_name

      backtrace     = exception.backtrace ? clean_backtrace(exception) : []
      summary, data = information_from_options(exception.class, options)

      @notifier.post text: {
        title:     title,
        summary:   summary,
        data:      data = data.map { |k, v| "#{k}: #{v}" }.join("\n"),
        message:   exception.message,
        backtrace: backtrace.first(10).join("\n")
      }
    end

    private

    def information_from_options(exception_class, options)
      errors_count   = options[:accumulated_errors_count].to_i
      measure_word   = if errors_count > 1
                         errors_count
                       else
                         (/^[aeiou]/i.match?(exception_class.to_s) ? "An" : "A")
                       end
      exception_name = "#{measure_word} #{exception_class}"

      env  = options[:env]
      if env.nil?
        data = options[:data] || {}
        text = "#{exception_name} occured in background"
      else
        data       = (env["exception_notifier.exception_data"] || {}).merge(options[:data] || {})
        kontroller = env["action_controller.instance"]
        request    = "#{env["REQUEST_METHOD"]} #{env["REQUEST_URI"]}"
        text       = "#{exception_name} occurred"
        text       += "while #{request}" if request.present?
        text       += " was processed by #{kontroller.controller_name}##{kontroller.action_name}" if kontroller
      end

      [text, data]
    end
  end
end
