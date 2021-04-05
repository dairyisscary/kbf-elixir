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
    day_of_month = Number.Human.number_to_ordinal(date.day)
    Calendar.strftime(date, "%b, #{day_of_month} %Y")
  end
end
