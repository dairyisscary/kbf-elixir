defmodule KbfWeb.Transaction.TableComponent do
  use KbfWeb, :live_component

  def transaction_table_rows(transactions), do: Enum.map(transactions, &transaction_table_row/1)

  defp transaction_table_row(%Kbf.Transaction{} = transaction) do
    [
      phx_click: :edit_transaction,
      phx_value_id: transaction.id,
      class: "cursor-pointer",
      id: "transaction-table-row-#{transaction.id}",
      do: [
        transaction.description,
        component("currency_pill.html", value: transaction.amount),
        transaction.when |> format_date(),
        unless Enum.empty?(transaction.categories) do
          content_tag :div, class: "flex flex-wrap items-center gap-2 max-w-md" do
            transaction.categories
            |> Enum.map(&component("category_pill.html", category: &1, class: "mr-2"))
          end
        end
      ]
    ]
  end
end
