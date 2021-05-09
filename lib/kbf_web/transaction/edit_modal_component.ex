defmodule KbfWeb.Transaction.EditModalComponent do
  use KbfWeb, :live_component

  @impl true
  def update(%{transaction: transaction, categories: categories}, socket) do
    changeset = Kbf.Transaction.changeset(transaction, %{})

    selected_categories =
      Enum.into(transaction.categories, %{}, fn category ->
        {category.id, true}
      end)

    {:ok,
     assign(socket, %{
       transaction: transaction,
       changeset: changeset,
       all_categories: categories,
       delete_modal_open: false,
       selected_categories: selected_categories
     })}
  end

  @impl true
  def handle_event("save", %{"transaction" => transaction_params}, socket) do
    transaction = socket.assigns.transaction

    operation =
      if transaction.id do
        Kbf.Transaction.update(
          transaction,
          params_with_selected_categories(transaction_params, socket)
        )
      else
        Kbf.Transaction.create(params_with_selected_categories(transaction_params, socket))
      end

    case operation do
      {:ok, _updated_transaction} ->
        {:noreply, send_close(socket, :updated)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> clear_flash()
         |> put_flash(:error, "Could not save transaction.")
         |> assign(:changeset, changeset)}
    end
  end

  def handle_event("cancel", _payload, socket) do
    {:noreply, send_close(socket, nil)}
  end

  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    updated_changeset =
      socket.assigns.transaction
      |> Kbf.Transaction.changeset(params_with_selected_categories(transaction_params, socket))
      |> Map.put(:action, if(socket.assigns.transaction.id, do: :update, else: :insert))

    {:noreply, assign(socket, :changeset, updated_changeset)}
  end

  def handle_event("update_selected_categories", %{"category-id" => toggle_id}, socket) do
    {:noreply,
     update(socket, :selected_categories, fn old_categories ->
       old_categories
       |> Map.update(toggle_id, true, &!/1)
     end)}
  end

  def handle_event("confirm_delete_transaction", payload, socket) do
    with {:ok, _deleted} <- Kbf.Transaction.delete(socket.assigns.transaction),
         {:noreply, socket} <- handle_event("close_delete_modal", payload, socket) do
      {:noreply, send_close(socket, :deleted)}
    else
      _ ->
        {:noreply,
         socket
         |> clear_flash()
         |> put_flash(:error, "Could not delete transaction.")}
    end
  end

  def handle_event("open_delete_modal", _payload, socket),
    do: {:noreply, assign(socket, :delete_modal_open, true)}

  def handle_event("close_delete_modal", _payload, socket),
    do: {:noreply, assign(socket, :delete_modal_open, false)}

  defp send_close(socket, is_updated) do
    send(self(), {KbfWeb.Transaction.EditModalComponent, :close, is_updated})

    socket
  end

  defp params_with_selected_categories(transaction_params, socket) do
    selected_categories = socket.assigns.selected_categories

    Map.put(
      transaction_params,
      "categories",
      socket.assigns.all_categories
      |> Enum.filter(&selected_categories[&1.id])
    )
  end
end
