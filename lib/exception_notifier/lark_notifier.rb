module ExceptionNotifier
  class LarkNotifier
    include ExceptionNotifier::BacktraceCleaner

    def initialize(options)
      @default_appname = "#{rails_app_name} (env: #{rails_env_name})" if rails_app_name && rails_env_name
      @notifier = ExceptionNotificationLarkNotifier::Client.new(
        options.slice(:webhook_url, :webhook_secret, :http)
      )
    end

    def call(exception, options = {})
      title = @default_appname ? "Exception Occurred in #{@default_appname}" : "Exception Occurred"
      clean_message = exception.message.tr("`", "'")
      backtrace = exception.backtrace ? clean_backtrace(exception) : ""
      info, data = information_from_options(exception.class, options)
      fields = fields(clean_message, backtrace, data)

      @notifier.post interactive: {
        header: {
          title: {tag: "plain_text", content: title}
        },
        elements: [{
          tag: "div",
          text: {tag: "lark_md", content: info},
          fields: fields
        }]
      }
    end

    private

    def fields(clean_message, backtrace, data)
      fields = []

      unless clean_message.empty?
        fields << {is_short: false, text: {tag: "lark_md", content: "**Message:**"}}
        fields << {is_short: false, text: {tag: "plain_text", content: clean_message}}
        fields << {is_short: false, text: {tag: "lark_md", content: "\n"}}
      end

      unless backtrace.empty?
        fields << {is_short: false, text: {tag: "lark_md", content: "**Backtrace:**"}}
        fields << {is_short: false, text: {tag: "plain_text", content: backtrace.first(10).join("\n")}}
        fields << {is_short: false, text: {tag: "lark_md", content: "\n"}}
      end

      unless data.empty?
        data = data.map { |k, v| "#{k}: #{v}" }.join("\n")
        fields << {is_short: false, text: {tag: "lark_md", content: "**Data:**"}}
        fields << {is_short: false, text: {tag: "plain_text", content: data}}
        fields << {is_short: false, text: {tag: "lark_md", content: "\n"}}
      end

      fields
    end

    def information_from_options(exception_class, options)
      errors_count = options[:accumulated_errors_count].to_i
      measure_word = if errors_count > 1
        errors_count
      else
        (/^[aeiou]/i.match?(exception_class.to_s) ? "An" : "A")
      end
      exception_name = "*#{measure_word}* **#{exception_class}**"

      env = options[:env]
      if env.nil?
        data = options[:data] || {}
        text = "#{exception_name} *occured in background*"
      else
        data = (env["exception_notifier.exception_data"] || {}).merge(options[:data] || {})
        kontroller = env["action_controller.instance"]
        request = "#{env["REQUEST_METHOD"]} <#{env["REQUEST_URI"]}>"
        text = "#{exception_name} *occurred while* **#{request}**"
        text += " *was processed by* **#{kontroller.controller_name}##{kontroller.action_name}**" if kontroller
      end
      text += "\n --------------\n"

      [text, data]
    end

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
end
