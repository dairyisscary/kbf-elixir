defmodule KbfWeb.Transaction.ListingLive do
  use KbfWeb, :live_view

  @day_cutoff 30

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Kbf.Transaction.subscribe()

    socket =
      assign(socket,
        page_title: "All Transactions",
        transactions:
          Kbf.Transaction.newer_than_n_days_ago(@day_cutoff)
          |> KbfWeb.Transaction.sort_by_when()
      )

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
      if Kbf.Transaction.happened_on_or_before_days_ago(new_transaction, @day_cutoff) do
        update(socket, :transactions, fn old ->
          [new_transaction | old]
          |> KbfWeb.Transaction.sort_by_when()
        end)
      else
        socket
      end

    {:noreply, new_socket}
  end

  def handle_info({KbfWeb.Transaction.EditModalComponent, :close, _id}, socket) do
    {:noreply, KbfWeb.LayoutView.live_unassign_edit_modal(socket)}
  end

  @impl true
  def handle_event("edit_transaction", %{"id" => id}, socket) do
    transaction = Enum.find(socket.assigns.transactions, &(&1.id == id))
    {:noreply, KbfWeb.LayoutView.live_assign_edit_modal(socket, transaction)}
  end

  def handle_event("add_transaction", _params, socket) do
    {:noreply, KbfWeb.LayoutView.live_assign_add_modal(socket)}
  end
end
