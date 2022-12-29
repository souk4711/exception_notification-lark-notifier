module ExceptionNotificationLarkNotifier
  class Client
    def initialize(options)
      @secret = options[:webhook_secret].to_s.strip
      @http = Http.new(
        uri: options.fetch(:webhook_url),
        options: options[:http] || {}
      )
    end

    def ping(payload)
      payload = {text: payload} unless payload.is_a?(Hash)
      post(payload)
    end

    def post(payload)
      message = build_message(payload)

      unless @secret.empty?
        timestamp = Time.now.to_i
        sign = Signer.generate(timestamp, @secret)
        message[:timestamp] = timestamp
        message[:sign] = sign
      end

      @http.post(json: message)
    end

    private

    def build_message(payload)
      case payload
      in { text: content }
        {msg_type: "text", content: {text: content}}
      in { post: content }
        {msg_type: "post", content: {post: content}}
      in { image: content }
        {msg_type: "image", content: {image_key: content}}
      in { share_chat: content }
        {msg_type: "share_chat", content: {share_chat_id: content}}
      in { interactive: content }
        {msg_type: "interactive", card: content}
      else
        raise ::ArgumentError, "msg_type is required"
      end
    end
  end
end
