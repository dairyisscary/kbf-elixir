defmodule KbfWeb.TransactionView do
  use KbfWeb, :view

  def sum_spend(transactions) do
    sum_with_filter(transactions, &(&1 < 0))
  end

  def sum_income(transactions) do
    sum_with_filter(transactions, &(&1 > 0))
  end

  def dash_pill(content, value: value, icon_name: icon_name) do
    ~E"""
    <div class="p-4 transition-shadow border rounded-lg shadow-sm hover:shadow-lg">
      <div class="flex space-x-2 items-start justify-between">
        <div class="flex flex-col space-y-2">
          <h4 class="text-gray-500"><%= content %></h4>
          <span class="text-lg font-semibold"><%= value %></span>
        </div>
        <div class="p-6 bg-gray-200 rounded-md">
          <%= component "icon.html", name: icon_name %>
        </div>
      </div>
    </div>
    """
  end

  def transaction_table_rows(transactions) do
    transactions
    |> Enum.map(fn transaction ->
      [
        transaction.description,
        component("currency_pill.html", value: transaction.amount),
        transaction.when |> format_date()
      ]
    end)
  end

  defp sum_with_filter(transactions, filter_fn) do
    transactions
    |> Enum.map(& &1.amount)
    |> Enum.filter(filter_fn)
    |> Enum.sum()
  end
end
