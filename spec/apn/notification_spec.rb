require 'spec_helper'
describe APN::Notification do

  let(:notification) do
    APN::Notification.new('token', payload)
  end

  describe '#initialize' do
    context 'with created_at' do
      let(:payload) { { alert: 'payload', created_at: DateTime.now } }

      it "removes created_at from the options" do
        expect(notification.options).not_to include(:created_at)
      end
    end
  end

  describe '#created_at' do
    context "when payload is a string" do
      let(:payload) do
        "hi"
      end

      it "leaves created_at as nil" do
        expect(notification.created_at).to be_nil
      end
    end

    context "when payload is a hash" do
      let(:date_time) { DateTime.now.change(usec: 0) }

      shared_examples_for "a DateTime created_at" do
        it "converts to a DateTime" do
          expect(notification.created_at).to be_a(DateTime)
        end

        it "is the correct time" do
          expect(notification.created_at.to_s).to eq(date_time.to_s)
        end
      end

      context "when the hash contains an integer created_at" do
        let(:payload) { { alert: 'payload', created_at: date_time.to_i } }

        it_behaves_like "a DateTime created_at"
      end

      context "when the hash contains a datetime" do
        let(:payload) { { alert: 'payload', created_at: date_time } }

        it_behaves_like "a DateTime created_at"
      end

      context "when the hash contains a string" do
        let(:payload) { { alert: 'payload', created_at: date_time.to_s } }

        it_behaves_like "a DateTime created_at"
      end
    end
  end

  describe ".packaged_message" do

    let(:message) do
      notification.packaged_message
    end

    context "when payload is a string" do

      let(:payload) do
        "hi"
      end

      it "adds 'aps' key" do
        expect(ActiveSupport::JSON::decode(message)).to have_key('aps')
      end

      it "encode the payload" do
        expect(message)
          .to eq(ActiveSupport::JSON::encode(aps: {alert: payload}))
      end
    end

    context "when payload is a hash" do

      let(:payload) do
        {alert: 'paylod'}
      end

      it "adds 'aps' key" do
        expect(ActiveSupport::JSON::decode(message)).to have_key('aps')
      end

      it "encode the payload" do
        expect(message)
          .to eq(ActiveSupport::JSON::encode(aps: payload))
      end
    end

    context "when payload is Localizable" do
      pending
    end
  end

  describe ".packaged_token" do
    pending
  end

  describe ".truncate_alert!" do
    APN.truncate_alert = true

    context "when alert is a string" do
      let(:payload) do
        { alert: ("a" * 300) }
      end

      it "should truncate the alert" do
        notification.packaged_notification.size.to_i.should == 256
      end
    end

    context "when payload is a hash" do
      let(:payload) do
        { alert: { 'loc-args' => ["a" * 300] }}
      end

      it "should truncate the alert" do
        notification.packaged_notification.size.to_i.should == 256
      end
    end
  end
end
