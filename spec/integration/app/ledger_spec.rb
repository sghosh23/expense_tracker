require_relative '../../../app/ledger'
require_relative '../../../config/sequel'

module ExpenseTracker
  RSpec.describe Ledger, :aggregate_failures, :db do
    let(:ledger){ Ledger.new }
    let(:expense) do
      {
        'payee' => 'Starbucks',
        'amount' => 5.75,
        'date' => '2018-03-08'
      }
    end

    describe '#record' do
      context 'with a valid expense' do
        it 'successfully saves the expense in the db' do
          result = ledger.record(expense)
          expect(result).to be_success
          expect(DB[:expenses]).to match [a_hash_including(
            id: result.expense_id,
            payee: 'Starbucks',
            date: Date.iso8601('2018-03-08')
          )]
        end
      end

      context 'when expense lacks a payee' do
        it 'rejects the expense as invalid' do
          expense.delete('payee')

          result = ledger.record(expense)
          expect(result).to_not be_success
          expect(result.expense_id).to be_nil
          expect(result.error_message).to include('`payee` is required')
          expect(DB[:expenses].count).to eq(0)
        end
      end
    end
  end
end
