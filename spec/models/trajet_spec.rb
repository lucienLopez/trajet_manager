require 'rails_helper'

RSpec.describe Trajet, type: :model do
  describe '#init_state' do
    context 'when trajet is new' do
      context 'when trajet has no state' do
        it 'sets state to :created' do
          expect(Trajet.create.state).to eq('created')
        end
      end

      context 'when trajet already has a state' do
        it 'resets state to :created' do
          expect(Trajet.create(state: :cancelled).state).to eq('created')
        end
      end
    end

    context 'when trajet has already been created' do
      it 'does not call init_state' do
        trajet = Trajet.create

        expect(trajet).not_to receive(:init_state)
        trajet.update(state: :cancelled)
      end
    end
  end

  describe '#generate_code' do
    context 'when trajet has no code' do
      it 'generates a new code' do
        code = Trajet.create.code
        expect(code.length).to eq(4)
      end
    end

    context 'when trajet has a code' do
      it 'does not change code' do
        code = 'TEST'
        expect(Trajet.create(code: code).code).to eq(code)
      end
    end
  end

  describe '#process_state_change' do
    context 'when trajet is new' do
      it 'calls Billing.bill and puts no log' do
        expect(Billing).to receive(:bill)
        expect(STDOUT).not_to receive(:puts)
        expect_any_instance_of(Bunny::Exchange).not_to receive(:puts)

        Trajet.create
      end
    end

    context 'when trajet is getting started' do
      it 'calls Billing.pay and sends change messages' do
        trajet = Trajet.create
        expected_log = "Trajet #{trajet.id}: state changed from created to started"

        expect(Billing).to receive(:pay)
        expect(STDOUT).to receive(:puts).with(expected_log)
        expect_any_instance_of(Bunny::Exchange).to(
          receive(:publish).with(expected_log, {routing_key: Trajet::RABBITMQ_QUEUE})
        )

        trajet.update(state: :started)
      end
    end

    context 'when trajet is getting cancelled' do
      it 'calls Billing.reimburse and sends change messages' do
        trajet = Trajet.create
        expected_log = "Trajet #{trajet.id}: state changed from created to cancelled"

        expect(Billing).to receive(:reimburse)
        expect(STDOUT).to receive(:puts).with(expected_log)
        expect_any_instance_of(Bunny::Exchange).to(
          receive(:publish).with(expected_log, {routing_key: Trajet::RABBITMQ_QUEUE})
        )

        trajet.update(state: :cancelled)
      end
    end
  end
end
