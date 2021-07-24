defmodule Kbf.Transaction.Currency do
  use EctoEnum, type: :currency, enums: [:usd, :euro]
end
