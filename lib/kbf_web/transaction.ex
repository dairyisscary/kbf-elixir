defmodule KbfWeb.Transaction do
  use KbfWeb.HTML

  import KbfWeb.ComponentHelpers

  @future_date ~D[2100-01-01]

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

  def update_single_transaction(old_transactions, updated_transaction) do
    updated_id = updated_transaction.id

    old_transactions
    |> Enum.map(fn transaction ->
      if transaction.id === updated_id, do: updated_transaction, else: transaction
    end)
  end

  def sort_by_when(transactions) do
    transactions
    |> Enum.sort_by(&(&1.when || @future_date), {:desc, Date})
  end

  defp sum_with_filter(transactions, filter_fn) do
    transactions
    |> Enum.map(& &1.amount)
    |> Enum.filter(filter_fn)
    |> Enum.sum()
  end
end
