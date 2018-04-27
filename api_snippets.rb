class API < Sinatra::Base
  def initialize(ledger:)
    @ledger = ledger
    super() # rest of the API initialization from sinatra
  end
end

app = API.new(ledger: Ledger.new)
