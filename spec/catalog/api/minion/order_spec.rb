require "catalog/minion"

describe Catalog::Api::Minion::Order do
  describe "#perform" do
    let(:order) do
      described_class.new("localhost", "9092")
    end
    let(:message) { ManageIQ::Messaging::ReceivedMessage.new(nil, "request_started", payload, nil, nil, nil) }
    let(:payload) { {"task_id" => "123"} }
    let(:payload_params) do
      {:payload =>  message.payload, :message => message.message}
    end
    # TODO: Use config once we have e2e-deploy
    # let(:config) do
    #   test_config = ::CatalogApiClient.configure
    #   test_config.host = "catalog-api.catalog-ci.svc"
    # end

    before do
      # dummy_client = double("CatalogApiClient")
      # allow(dummy_client).to receive(:configure).and_return(config)
      stub_request(:post, "http://catalog-api.catalog-ci.svc:8080/internal/v1.0/notify/order_item/123")
    end

    it "posts a payload" do
      order.perform(message)
      expect(a_request(:post, "http://catalog-api.catalog-ci.svc:8080/internal/v1.0/notify/order_item/123").with(
        :body    => {"message"=>"request_started", "payload"=>{"task_id"=>"123"}},
        :headers => {
          'X-Rh-Identity'=>'eyJlbnRpdGxlbWVudHMiOnsiaHlicmlkX2Nsb3VkIjp7ImlzX2VudGl0bGVkIjp0cnVlfX0sImlkZW50aXR5Ijp7ImFjY291bnRfbnVtYmVyIjoiY2F0YWxvZy1hcGktb3JkZXItbWluaW9uIn19'
        }
      )).to have_been_made.once
    end
  end
end
