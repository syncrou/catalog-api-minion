require "catalog/minion"
RSpec.describe Catalog::Api::Minion::Base do
  let(:subject) { described_class.new("localhost", "8080") }
  let(:messaging_client) do
    ManageIQ::Messaging::Client.open(
      :protocol   => :Kafka,
      :host       => "localhost",
      :port       => "8080",
      :group_ref  => "catalog-minion-test",
      :client_ref => "catalog-minion-test"
    )
  end

  context "#run" do
    before do
      allow(ManageIQ::Messaging::Client).to receive(:open).and_return(messaging_client)
    end

    context "when an error occurs while subscribing to a topic" do
      before do
        allow(subject).to receive(:subscribe_opts).and_return("doesn't matter")
        allow(messaging_client).to receive(:subscribe_topic).and_raise(StandardError.new("Oh noes!"))
      end

      it "rescues the exception and closes the client" do
        expect(Catalog::Api::Minion.logger).to receive(:error).with("Problem performing internal api post: Oh noes!")
        expect(messaging_client).to receive(:close)
        subject.run
      end
    end
  end
end
