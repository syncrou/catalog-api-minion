require "catalog/minion"

describe Catalog::Api::Minion::Order do
  describe "#perform" do
    let(:order) do
      described_class.new("localhost", "9092")
    end

    let(:message) { ManageIQ::Messaging::ReceivedMessage.new(nil, "Task.update", payload, nil, nil, nil) }

    let(:payload) { {"task_id" => "123"} }
    let(:payload_params) do
      {:payload =>  message.payload, :message => message.message}
    end
    let(:config) do
      test_config = ::CatalogApiClient.configure
      test_config.host = "catalog-api.catalog-ci.svc:8080"
    end

    before do
      dummy_client = double("CatalogApiClient")
      allow(dummy_client).to receive(:configure).and_return(config)
      stub_request(:post, "http://catalog-api.catalog-ci.svc:8080/internal/v1.0/notify/order_item/123")
    end

    context "when there is no error" do
      it "posts a payload" do
        order.perform(message)
        expect(a_request(:post, "http://catalog-api.catalog-ci.svc:8080/internal/v1.0/notify/order_item/123").with(
          :body    => payload_params,
          :headers => {
            'X-Rh-Identity'=>'eyJlbnRpdGxlbWVudHMiOnsiaHlicmlkX2Nsb3VkIjp7ImlzX2VudGl0bGVkIjp0cnVlfX0sImlkZW50aXR5Ijp7ImFjY291bnRfbnVtYmVyIjoiY2F0YWxvZy1hcGktb3JkZXItbWluaW9uIn19'
          }
        )).to have_been_made.once
      end
    end

    context "when there is an error" do
      before do
        stub_request(:post, "http://catalog-api.catalog-ci.svc:8080/internal/v1.0/notify/order_item/123").and_raise(
          StandardError.new("Oh noes!")
        )
      end

      it "logs the error" do
        expect(Catalog::Api::Minion.logger).to receive(:error).with("Problem performing internal api post: Oh noes!")
        order.perform(message)
      end
    end
  end
end
