defmodule KbfWeb.Transaction.EditModalComponent do
  use KbfWeb, :live_component

  @impl true
  def update(%{transaction: transaction}, socket) do
    changeset = Kbf.Transaction.changeset(transaction, %{})

    {:ok, assign(socket, %{transaction: transaction, changeset: changeset})}
  end

  @impl true
  def handle_event("save", %{"transaction" => transaction_params}, socket) do
    transaction = socket.assigns.transaction

    operation =
      if transaction.id do
        Kbf.Transaction.update(transaction, transaction_params)
      else
        Kbf.Transaction.create(transaction_params)
      end

    case operation do
      {:ok, updated_transaction} ->
        {:noreply, send_close(socket, updated_transaction)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> put_flash(:error, "Could not save transaction.") |> assign(:changeset, changeset)}
    end
  end

  def handle_event("cancel", _payload, socket) do
    {:noreply, send_close(socket, socket.assigns.transaction)}
  end

  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    updated_changeset =
      Kbf.Transaction.changeset(socket.assigns.transaction, transaction_params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: updated_changeset)}
  end

  defp send_close(socket, transaction) do
    send(self(), {KbfWeb.Transaction.EditModalComponent, :close, transaction.id})

    socket
  end
end
