defmodule KbfWeb.Transaction do
  use Phoenix.Component

  import KbfWeb.ComponentHelpers

  @future_date ~D[2100-01-01]

  def transaction_sum_income(transcations, currency) do
    sum_format_with_filter(transcations, &(&1.amount > 0), currency)
  end

  def transaction_sum_spend(transcations, currency) do
    sum_format_with_filter(transcations, &(&1.amount < 0), currency)
  end

  def dash_pill(assigns) do
    ~H"""
    <div class="p-4 transition-shadow border rounded-lg shadow-sm hover:shadow-lg">
      <div class="flex space-x-2 items-start justify-between">
        <div class="flex flex-col space-y-2">
          <h4 class="text-gray-500"><%= @title %></h4>
          <span class="text-lg font-semibold"><%= render_block(@inner_block) %></span>
        </div>
        <div class="p-8 bg-gray-200 rounded-md">
          <%= html_component "icon.html", name: @icon %>
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

  defp sum_format_with_filter(transactions, filter_fn, currency) do
    sum =
      transactions
      |> Enum.filter(&(&1.currency == currency && filter_fn.(&1)))
      |> Enum.map(& &1.amount)
      |> Enum.sum()
      |> KbfWeb.Format.format_currency(currency)

    Phoenix.HTML.Tag.content_tag(:div, do: sum)
  end
end
