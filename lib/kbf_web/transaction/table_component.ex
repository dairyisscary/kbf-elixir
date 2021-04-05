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
        transaction.when |> format_date()
      ]
    ]
  end
end
