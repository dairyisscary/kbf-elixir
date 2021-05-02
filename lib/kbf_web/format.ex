defmodule KbfWeb.Format do
  def format_int(number) do
    number
    |> Number.Delimit.number_to_delimited(precision: 0)
  end

  def format_currency(number) do
    Number.Currency.number_to_currency(number)
  end

  def format_date(nil), do: ""

  def format_date(date) do
    Calendar.strftime(date, "%d %b %Y")
  end
end
