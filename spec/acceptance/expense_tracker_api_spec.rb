require 'rack/test'
require 'json'
require_relative '../../app/api'

module ExpenseTracker
  RSpec.describe 'Expense Tracker Api', :db do
    include Rack::Test::Methods

    def app
      ExpenseTracker::API.new
    end

    def post_expense(expense)
      post '/expenses', JSON.generate(expense)
      expect(last_response.status).to eq(200)
      parsed = JSON.parse(last_response.body)
      expect(parsed).to include('expense_id' => a_kind_of(Integer))
      expense.merge('id' => parsed['expense_id'])
    end

    it 'records the submitted expense' do
      coffee = post_expense(
        'payee' => 'Starbucks',
        'amount' => 5.75,
        'date'   => '2018-03-01'
        )

      groceries = post_expense(
        'payee' => 'Whole foods',
        'amount' => 15.75,
        'date'   => '2018-03-01'
        )

      zoo = post_expense(
        'payee' => 'Zoo',
        'amount' => 20.75,
        'date'   => '2018-02-01'
        )

        get '/expenses/2018-03-01'
        expect(last_response.status).to eq(200)
        parsed = JSON.parse(last_response.body)
        expect(parsed).to contain_exactly(coffee, groceries)
     end
  end
end
