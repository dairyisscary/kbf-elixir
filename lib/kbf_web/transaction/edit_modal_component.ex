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
        {:noreply, send_close(socket, true)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not save transaction.")
         |> assign(:changeset, changeset)}
    end
  end

  def handle_event("cancel", _payload, socket) do
    {:noreply, send_close(socket, false)}
  end

  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    updated_changeset =
      socket.assigns.transaction
      |> Kbf.Transaction.changeset(params_with_selected_categories(transaction_params, socket))
      |> Map.put(:action, if(socket.assigns.transaction.id, do: :update, else: :insert))

    {:noreply, assign(socket, :changeset, updated_changeset)}
  end

  def handle_event("update_selected_categories", %{"toggle-id" => toggle_id}, socket) do
    {:noreply,
     update(socket, :selected_categories, fn old_categories ->
       old_categories
       |> Map.update(toggle_id, true, &!/1)
     end)}
  end

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
