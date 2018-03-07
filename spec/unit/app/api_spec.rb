require_relative '../../../app/api'
require 'rack/test'

module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message)

  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end
    # A phony class to imitate the ledger class instance
    let(:ledger){ instance_double('ExpenseTracker::Ledger') }

    describe 'POST/expense' do
      let(:expense) { { 'some' => 'data' } }

      context 'when the expense is successfully recoded' do

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(true, 817, nil))
        end

        it 'returns the expense id' do
          post '/expenses', JSON.generate(expense)
          parsed = JSON.parse(last_response.body)
          expect(parsed).to include('expense_id' => 817)
        end

        it 'responds with a 200 (ok)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq 200
        end
      end

      context 'when the expense fails validation' do

        before do
          allow(ledger).to receive(:record)
          .with(expense)
          .and_return(RecordResult.new(false, 417, 'Expense incomplete'))
        end

        it 'returns an error message' do
          post '/expenses', JSON.generate(expense)
          parsed = JSON.parse(last_response.body)
          expect(parsed).to include('error' => 'Expense incomplete')
        end

        it 'responds with a 422 (Unprocessable entity)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(422)
        end
      end
    end

    describe 'GET/expenses/:date' do

      context 'when expense exist on the given date' do

        before do
          allow(ledger).to receive(:expenses_on)
            .with('2018-03-05')
            .and_return(['expense_1', 'expense_2'])
        end

        it 'returns the expense record as JSON' do
          get '/expenses/2018-03-05'
          parsed = JSON.parse(last_response.body)
          expect(parsed).to eq(['expense_1', 'expense_2'])
        end

        it 'responds with a 200  (OK)' do
          get '/expenses/2018-03-05'
          expect(last_response.status).to eq(200)
        end
      end
      context 'when there are no expense on given date' do
        before do
          allow(ledger).to receive(:expenses_on)
            .with('2018-03-06')
            .and_return([])
        end
        it 'returns an empty array' do
          get '/expenses/2018-03-06'
          parsed = JSON.parse(last_response.body)
          expect(parsed).to be_empty
        end
        it 'responds with a 200 (OK)' do
          get '/expenses/2018-03-06'
          expect(last_response.status).to eq(200)
        end
      end

    end
  end
end
