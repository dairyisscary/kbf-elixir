defmodule KbfWeb.Transaction.TableComponent do
  use KbfWeb, :live_component

  def transaction_table_rows(transactions), do: Enum.map(transactions, &transaction_table_row/1)

  defp transaction_table_row(%Kbf.Transaction{} = transaction) do
    [
      phx_click: :edit_transaction,
      phx_value_id: transaction.id,
      class: "cursor-pointer even:bg-gray-50",
      id: "transaction-table-row-#{transaction.id}",
      do: [
        transaction.when |> format_date(),
        transaction.description,
        unless Enum.empty?(transaction.categories) do
          content_tag :div, class: "flex flex-wrap items-center gap-2 max-w-md" do
            transaction.categories
            |> Enum.map(&html_component("category_pill.html", category: &1, class: "mr-2"))
          end
        end,
        content_tag(
          :div,
          html_component("currency_pill.html", value: transaction.amount),
          class: "flex justify-end mr-6"
        )
      ]
    ]
  end
end
