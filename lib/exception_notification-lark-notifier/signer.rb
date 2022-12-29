module ExceptionNotificationLarkNotifier
  class Signer
    def self.generate(timestamp, secret)
      string = "#{timestamp}\n#{secret}"
      Base64.strict_encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new("sha256"), string, ""))
    end
  end
end
