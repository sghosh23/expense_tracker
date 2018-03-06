class API < Sinatra::Base
  def initialize(ledger:)
    @ledger = ledger
    super() # rest of the initialization from sinatra
  end
end

app = API.new(ledger: Ledger.new)
