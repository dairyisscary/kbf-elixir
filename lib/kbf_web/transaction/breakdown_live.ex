defmodule KbfWeb.Transaction.BreakdownLive do
  use KbfWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign(socket,
        page_title: "Breakdown",
        transaction_add_opt_out: true,
        user: KbfWeb.Session.get_user_from_socket_session!(session),
        filters: %{after: Kbf.Calendar.days_ago(30)}
      )
      |> currency_breakdowns_from_filters()

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket), do: {:noreply, socket}

  @impl true
  def handle_event("filter_transactions", %{"filters" => filters}, socket) do
    {:noreply,
     socket
     |> assign(:filters, parse_filters(filters))
     |> currency_breakdowns_from_filters()}
  end

  defp currency_breakdowns_from_filters(socket) do
    currency_breakdowns =
      socket.assigns[:filters]
      |> Kbf.Transaction.from_filters()
      |> Enum.group_by(& &1.currency)
      |> Enum.map(fn {currency, currency_transactions} ->
        tranactions_grouped_by_category_with_counts =
          currency_transactions
          |> Enum.reduce(%{}, &update_transaction_category_counts/2)
          |> Map.values()
          |> Enum.sort_by(& &1[:total])

        grand_total =
          tranactions_grouped_by_category_with_counts
          |> Enum.reduce(0, &(&1[:total] + &2))

        [%{total: max_total} | _] = tranactions_grouped_by_category_with_counts

        accums = {tranactions_grouped_by_category_with_counts, grand_total, abs(max_total)}

        {currency, accums}
      end)

    assign(socket, currency_breakdowns: currency_breakdowns)
  end

  defp get_category_for_transaction(%Kbf.Transaction{categories: categories}) do
    categories
    |> Enum.find(
      Kbf.Category.uncategorized(),
      fn category -> !category.ignored_for_breakdown_reporting end
    )
  end

  defp update_transaction_category_counts(transaction, accum) do
    category = get_category_for_transaction(transaction)

    accum
    |> Map.update(
      category.id,
      %{category: category, count: 1, total: transaction.amount},
      &update_category_counts(&1, transaction)
    )
  end

  defp update_category_counts(current, transaction) do
    current
    |> Map.update!(:count, &(&1 + 1))
    |> Map.update!(:total, &(&1 + transaction.amount))
  end

  defp row(%{count: count} = assigns, currency, max_total, grand_total) do
    [
      class: "even:bg-gray-50",
      do: [
        pill_for_category(assigns, max_total),
        "#{percentage_of_grand(assigns, grand_total)}%",
        count,
        total_badge(assigns, currency)
      ]
    ]
  end

  defp percentage_of_grand(%{total: total}, grand_total) do
    percent =
      (total / grand_total * 100.0)
      |> Float.round(1)

    if grand_total >= 0, do: percent * -1, else: percent
  end

  defp pill_for_category(%{total: total} = assigns, max_total) do
    color = if total > 0, do: "", else: " bg-purple-400"

    ~H"""
    <div class={"flex p-2 rounded#{color}"} style={"width:#{get_width_category(total, max_total)}%"}>
      <%= html_component "category_pill.html", category: @category %>
    </div>
    """
  end

  defp get_width_category(total, max_total) do
    (total / max_total * 100.0)
    |> abs()
    |> Float.round(1)
    |> max(0)
    |> min(100)
  end

  defp total_badge(assigns, currency) do
    ~H"""
    <div class="flex justify-end mr-6">
      <%= html_component("currency_pill.html", amount: @total, currency: currency) %>
    </div>
    """
  end

  defp parse_filters(%{} = filters) do
    %{
      ignored_ids:
        filters
        |> Map.get("ignore_transaction_ids", "")
        |> String.split(",")
        |> Enum.map(&String.trim/1)
        |> Enum.filter(fn id -> String.length(id) > 0 end),
      before: Kbf.Calendar.parse_date(filters["before"]),
      after: Kbf.Calendar.parse_date(filters["after"])
    }
  end
end
