defmodule KbfWeb.Transaction do
  use KbfWeb.HTML

  import KbfWeb.ComponentHelpers

  @future_date ~D[2100-01-01]

  def transaction_sum_income(transcations, currency) do
    sum_format_with_filter(transcations, &(&1.amount > 0), currency)
  end

  def transaction_sum_spend(transcations, currency) do
    sum_format_with_filter(transcations, &(&1.amount < 0), currency)
  end

  def dash_pill(content, opts, do: block) do
    dash_pill(content, Keyword.merge(opts, do: block))
  end

  def dash_pill(content, icon_name: icon_name, do: block) do
    ~E"""
    <div class="p-4 transition-shadow border rounded-lg shadow-sm hover:shadow-lg">
      <div class="flex space-x-2 items-start justify-between">
        <div class="flex flex-col space-y-2">
          <h4 class="text-gray-500"><%= content %></h4>
          <span class="text-lg font-semibold"><%= block %></span>
        </div>
        <div class="p-8 bg-gray-200 rounded-md">
          <%= html_component "icon.html", name: icon_name %>
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

    content_tag(:div, do: sum)
  end
end
