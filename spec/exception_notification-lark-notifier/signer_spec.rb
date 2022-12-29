RSpec.describe ExceptionNotificationLarkNotifier::Signer do
  describe ".generate" do
    it do
      expect(described_class.generate(1599360473, "123456")).to eq("No5OqsEq9++bkoDaMOJnotPx+v9U4leSKHt5aPJtfcg=")
    end
  end
end
