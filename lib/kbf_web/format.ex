defmodule KbfWeb.Format do
  def format_currency_name(:usd), do: "$ USD"

  def format_currency_name(:euro), do: "€ Euro"

  def format_currency(number, :euro) do
    Number.Currency.number_to_currency(number, unit: "€", separator: ",", delimiter: ".")
  end

  def format_currency(number, :usd), do: Number.Currency.number_to_currency(number)

  def format_int(number), do: Number.Delimit.number_to_delimited(number, precision: 0)

  def format_date(nil), do: ""

  def format_date(date), do: Calendar.strftime(date, "%d %b %Y")

  def format_iso_date(nil), do: ""

  def format_iso_date(date), do: Calendar.strftime(date, "%Y-%m-%d")
end
