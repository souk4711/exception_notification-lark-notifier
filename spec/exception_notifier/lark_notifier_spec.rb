RSpec.describe ExceptionNotifier::LarkNotifier do
  def fake_exception
    5 / 0
  rescue => ex
    ex
  end

  subject do
    described_class.new(
      webhook_url: ENV["LARK_NOTIFIER_WEBHOOK_URL"],
      webhook_secret: ENV["LARK_NOTIFIER_WEBHOOK_SECRET"]
    )
  end

  describe "#call", :vcr do
    it "occured in background" do
      expect {
        subject.call(fake_exception, env: nil, data: {current_user: {id: 1, name: "John Doe"}})
      }.not_to raise_error
    end

    it "occured in controller" do
      expect {
        env = {
          "REQUEST_METHOD" => "GET",
          "REQUEST_URI" => "https://example.com/path/to/page?name=ferret&color=purple",
          "exception_notifier.exception_data" => {current_user: {id: 1, name: "John Doe"}}
        }
        subject.call(fake_exception, env: env)
      }.not_to raise_error
    end
  end
end
