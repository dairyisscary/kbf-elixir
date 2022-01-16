defmodule KbfWeb.Transaction.TableComponent do
  use KbfWeb, :live_component

  def transaction_table_rows(transactions) do
    Enum.map(transactions, fn %Kbf.Transaction{} = transaction ->
      transaction_table_row(%{transaction: transaction})
    end)
  end

  defp transaction_table_row(assigns) do
    %{transaction: transaction} = assigns

    [
      phx_click: :edit_transaction,
      phx_value_id: transaction.id,
      class: "cursor-pointer even:bg-gray-50",
      id: "transaction-table-row-#{transaction.id}",
      do: [
        transaction.when |> format_date(),
        transaction.description,
        ~H"""
        <%= unless Enum.empty?(transaction.categories) do %>
          <div class="flex flex-wrap items-center gap-2 max-w-md">
            <%= for category <- transaction.categories do %>
              <%= html_component("category_pill.html", category: category, class: "mr-2") %>
            <% end %>
          </div>
        <% end %>
        """,
        ~H"""
        <div class="flex justify-end mr-6">
          <%= html_component("currency_pill.html", amount: transaction.amount, currency: transaction.currency) %>
        </div>
        """
      ]
    ]
  end
end
