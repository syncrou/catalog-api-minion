require "catalog-api/minion"
RSpec.describe CatalogApi::Minion::Approval do
  context "#perform" do
    let(:approval) do
      described_class.new("localhost", "9092")
    end
    let(:message)         { ManageIQ::Messaging::ReceivedMessage.new(nil, event, payload, nil, nil, nil) }
    let(:external_tenant) { SecureRandom.uuid }
    let(:payload) do
      { "request_id" => 3 }
    end
    let(:payload_params) do
      { :payload =>  message.payload, :message => message.message }
    end
    let(:event) { "request_started" }
    let(:config) do
      test_config = ::CatalogApiClient.configure
      test_config.host = "localhost:3000"
    end

    it "posts a payload" do
      expect(approval).to receive(:post_internal_notify).with(payload, payload_params)
      approval.send(:perform, message)
    end

    it "builds an internal api" do
      internal_url = "http://localhost:3000/internal/v1.0/notify/ApprovalRequest/3"
      dummy_client = double("CatalogApiClient")
      allow(dummy_client).to receive(:configure).and_return(config)
      expect(approval.internal_notify_url(payload['request_id'])).to eq internal_url
    end
  end
end
