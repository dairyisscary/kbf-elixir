defmodule KbfWeb.Transaction.ListingLive do
  use KbfWeb, :live_view

  @impl true
  def mount(params, session, socket) do
    if connected?(socket), do: Kbf.Transaction.subscribe()

    socket =
      socket
      |> assign(
        page_title: "All Transactions",
        user: KbfWeb.Session.get_user_from_socket_session!(session),
        all_categories: Kbf.Category.all_by_name(),
        filters:
          if params["init_filters"] do
            parse_filters(params["init_filters"])
          else
            %{after: Kbf.Calendar.days_ago(30), categories: %{}}
          end
      )
      |> transactions_from_filters()

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket), do: {:noreply, socket}

  @impl true
  def handle_info({:transaction_updated, updated_transaction}, socket) do
    new_transactions_fn = fn old_transactions ->
      old_transactions
      |> KbfWeb.Transaction.update_single_transaction(updated_transaction)
      |> KbfWeb.Transaction.sort_by_when()
    end

    {:noreply, update(socket, :transactions, new_transactions_fn)}
  end

  def handle_info({:transaction_created, new_transaction}, socket) do
    new_socket =
      if Kbf.Transaction.matches_filters(new_transaction, socket.assigns[:filters]) do
        update(socket, :transactions, fn old ->
          [new_transaction | old]
          |> KbfWeb.Transaction.sort_by_when()
        end)
      else
        socket
      end

    {:noreply, new_socket}
  end

  def handle_info({:transaction_deleted, %Kbf.Transaction{id: id}}, socket) do
    new_socket =
      update(socket, :transactions, fn old_transactions ->
        old_transactions
        |> Enum.filter(&(&1.id != id))
        |> KbfWeb.Transaction.sort_by_when()
      end)

    {:noreply, new_socket}
  end

  def handle_info({KbfWeb.Transaction.EditModalComponent, :close, action}, socket) do
    socket = KbfWeb.LayoutView.live_unassign_edit_modal(socket)

    socket =
      case action do
        :updated ->
          KbfWeb.LayoutView.put_temporary_flash(
            socket,
            :info,
            "Saved transaction successfully.",
            :clear_flash
          )

        :deleted ->
          KbfWeb.LayoutView.put_temporary_flash(
            socket,
            :info,
            "Deleted transaction successfully.",
            :clear_flash
          )

        _ ->
          socket
      end

    {:noreply, socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  @impl true
  def handle_event("filter_transactions", %{"filters" => filters}, socket) do
    {:noreply,
     socket
     |> assign(:filters, parse_filters(filters))
     |> transactions_from_filters()}
  end

  def handle_event("edit_transaction", %{"id" => id}, socket) do
    transaction = Enum.find(socket.assigns.transactions, &(&1.id == id))

    {:noreply,
     KbfWeb.LayoutView.live_assign_edit_modal(socket, %{
       categories: socket.assigns.all_categories,
       transaction: transaction
     })}
  end

  def handle_event("add_transaction", _params, socket) do
    {:noreply,
     KbfWeb.LayoutView.live_assign_add_modal(socket, %{categories: socket.assigns.all_categories})}
  end

  defp parse_filters(%{} = filters) do
    %{
      categories:
        filters
        |> Map.get("categories", %{})
        |> Enum.filter(fn {_id, value} -> value == "true" end)
        |> Enum.into(%{}, fn {id, _value} -> {id, true} end),
      before: Kbf.Calendar.parse_date(filters["before"]),
      after: Kbf.Calendar.parse_date(filters["after"])
    }
  end

  defp transactions_from_filters(socket) do
    transactions =
      socket.assigns[:filters]
      |> Kbf.Transaction.from_filters()
      |> KbfWeb.Transaction.sort_by_when()

    assign(socket, :transactions, transactions)
  end
end
