require "catalog/minion"

describe Catalog::Api::Minion::Task do
  describe "#perform" do
    let(:task_minion) do
      described_class.new("localhost", "9092")
    end
    let(:headers) { {'a' => 1, 'b' => '2'} }

    let(:message) { ManageIQ::Messaging::ReceivedMessage.new(nil, "Task.update", payload, headers, nil, nil) }

    let(:payload) { {"task_id" => "123"} }
    let(:payload_params) do
      {:payload => message.payload, :message => message.message}
    end
    let(:config) do
      test_config = ::CatalogApiClient.configure
      test_config.host = "localhost:3000"
    end

    before do
      dummy_client = double("CatalogApiClient")
      allow(dummy_client).to receive(:configure).and_return(config)
      stub_request(:post, "http://localhost:3000/internal/v1.0/notify/task/123")
    end

    context "when there is no error" do
      it "posts a payload to the order item endpoint" do
        task_minion.perform(message)
        expect(a_request(:post, "http://localhost:3000/internal/v1.0/notify/task/123").with(
          :body    => payload_params,
          :headers => headers
        )).to have_been_made.once
      end
    end

    context "when there is an error" do
      before do
        stub_request(:post, "http://localhost:3000/internal/v1.0/notify/task/123").and_raise(
          StandardError.new("Oh noes!")
        )
      end

      it "logs the error" do
        expect(Catalog::Api::Minion.logger).to receive(:error).with("Problem performing internal api post: Oh noes!")
        task_minion.perform(message)
      end
    end
  end
end
