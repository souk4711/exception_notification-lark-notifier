RSpec.describe ExceptionNotificationLarkNotifier::Client do
  subject do
    described_class.new(
      webhook_url: ENV["LARK_NOTIFIER_WEBHOOK_URL"],
      webhook_secret: ENV["LARK_NOTIFIER_WEBHOOK_SECRET"]
    )
  end

  describe "HTTP interactions", :vcr do
    describe "#ping" do
      it "msg_type :text" do
        data = subject.ping "Hello World"
        expect(data["StatusCode"]).to eq(0)
        expect(data["StatusMessage"]).to eq("success")

        data = subject.ping text: "Hello World"
        expect(data["StatusCode"]).to eq(0)
        expect(data["StatusMessage"]).to eq("success")
      end

      it "msg_type :post" do
        data = subject.ping post: {
          zh_cn: {
            title: "项目更新通知",
            content: [[
              {tag: "text", text: "项目有更新: "},
              {tag: "a", text: "请查看", href: "http://www.example.com/"}
            ]]
          }
        }
        expect(data["StatusCode"]).to eq(0)
        expect(data["StatusMessage"]).to eq("success")
      end

      it "msg_type :image" do
        data = subject.ping image: "img_ecffc3b9-8f14-400f-a014-05eca1a4310g"
        expect(data["StatusCode"]).to eq(0)
        expect(data["StatusMessage"]).to eq("success")
      end

      it "msg_type :share_chat" do
        data = subject.ping share_chat: "oc_f5b1a7eb27ae2c7b6adc2a74faf339ff"
        expect(data["StatusCode"]).to eq(0)
        expect(data["StatusMessage"]).to eq("success")
      end

      it "msg_type :interactive" do
        card = {
          elements: [{
            tag: "div", text: {content: "**西湖**，位于浙江省杭州市西湖区龙井路1号，杭州市区西部，景区总面积49平方千米，汇水面积为21.22平方千米，湖面面积为6.38平方千米。", tag: "lark_md"}
          }],
          header: {
            title: {tag: "plain_text", content: "今日旅游推荐"}
          }
        }

        data = subject.ping interactive: card
        expect(data["StatusCode"]).to eq(0)
        expect(data["StatusMessage"]).to eq("success")
      end

      describe "exceptions" do
        it "Key Words Not Found" do
          expect {
            subject.ping "Hello World"
          }.to raise_error(ExceptionNotificationLarkNotifier::Exceptions::APIError, /Key Words Not Found/)
        end

        it "Ip Not Allowed" do
          expect {
            subject.ping "Hello World"
          }.to raise_error(ExceptionNotificationLarkNotifier::Exceptions::APIError, /Ip Not Allowed/)
        end

        it "sign match fail or timestamp is not within one hour from current time" do
          expect {
            subject.ping "Hello World"
          }.to raise_error(ExceptionNotificationLarkNotifier::Exceptions::APIError, /sign match fail or timestamp is not within one hour from current time/)
        end

        it "msg_type is required" do
          expect {
            subject.ping unknown: "Oops!"
          }.to raise_error(::ArgumentError, /msg_type is required/)
        end
      end
    end
  end

  describe "HTTP options" do
    it "timeout" do
      allow(TCPSocket).to receive(:open) { sleep 2.5 }
      client = described_class.new(
        webhook_url: ENV["LARK_NOTIFIER_WEBHOOK_URL"],
        webhook_secret: ENV["LARK_NOTIFIER_WEBHOOK_SECRET"],
        http: {
          timeout_class: HTTP::Timeout::Global,
          timeout_options: {global_timeout: 2}
        }
      )
      expect {
        client.ping "Hello World"
      }.to raise_error(ExceptionNotificationLarkNotifier::Exceptions::HttpError, /execution expired/)
    end
  end
end
