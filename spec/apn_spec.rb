require 'spec_helper'

describe APN do
  describe '.notify_sync' do
    let (:base_opts) { {alert: 'alert', badge: 1 } }
    let (:client) { double(APN::Client) }

    before :each do
      APN.stub(:with_connection).and_yield(client)
    end

    context 'when max_age is set' do
      before(:each) { APN.max_age = 20.minutes }
      after(:each) { APN.max_age = nil }

      context 'when the notification is too old' do
        it 'does not send the message' do
          client.should_not_receive(:push)

          APN.notify_sync('token', base_opts.merge!({ created_at: 30.minutes.ago }) )
        end
      end

      context 'when the notification is not too old' do
        it 'sends the message' do
          client.should_receive(:push).with(an_instance_of(APN::Notification))

          APN.notify_sync('token', base_opts.merge!({ created_at: 19.minutes.ago }) )
        end
      end

      context 'when the notification has no created date' do
        it 'sends the message' do
          client.should_receive(:push).with(an_instance_of(APN::Notification))

          APN.notify_sync('token', base_opts)
        end
      end
    end

    context 'when max_age is not set' do
      before(:each) { APN.max_age = nil }

      it 'sends the message' do
        client.should_receive(:push).with(an_instance_of(APN::Notification))

        APN.notify_sync('token', base_opts.merge!({ created_at: 30.minutes.ago }) )
      end
    end
  end
end
