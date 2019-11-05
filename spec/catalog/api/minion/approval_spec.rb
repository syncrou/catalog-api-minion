require "catalog/minion"
RSpec.describe Catalog::Api::Minion::Approval do
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

    before do
      dummy_client = double("CatalogApiClient")
      allow(dummy_client).to receive(:configure).and_return(config)
      stub_request(:post, "http://localhost:3000/internal/v1.0/notify/approval_request/3")
    end

    context "when there is no error" do
      it "posts a payload" do
        approval.perform(message)
        expect(a_request(:post, "http://localhost:3000/internal/v1.0/notify/approval_request/3").with(
          :body    => {"message"=>"request_started", "payload"=> payload},
          :headers => {
            'X-Rh-Identity'=>'eyJlbnRpdGxlbWVudHMiOnsiaHlicmlkX2Nsb3VkIjp7ImlzX2VudGl0bGVkIjp0cnVlfX0sImlkZW50aXR5Ijp7ImFjY291bnRfbnVtYmVyIjoiY2F0YWxvZy1hcGktYXBwcm92YWwtbWluaW9uIn19'
          }
        )).to have_been_made.once
      end
    end

    context "when there is an error" do
      before do
        stub_request(:post, "http://localhost:3000/internal/v1.0/notify/approval_request/3").and_raise(
          StandardError.new("Oh noes!")
        )
      end

      it "logs the error" do
        expect(Catalog::Api::Minion.logger).to receive(:error).with("Problem performing internal api post: Oh noes!")
        approval.perform(message)
      end
    end
  end
end
