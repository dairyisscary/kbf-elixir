defmodule KbfWeb.Transaction.MassImportLive do
  use KbfWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign(socket,
        page_title: "Mass Import",
        transaction_add_opt_out: true,
        user: KbfWeb.Session.get_user_from_socket_session!(session),
        selected_categories: %{},
        all_categories: Kbf.Category.all_by_name(),
        suspect_duplicates: nil,
        mass_import_changeset: changeset_from_data(%{})
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket), do: {:noreply, socket}

  @impl true
  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  @impl true
  def handle_event("update_selected_categories", %{"category-id" => toggle_id}, socket) do
    {:noreply,
     update(socket, :selected_categories, fn old_categories ->
       old_categories
       |> Map.update(toggle_id, true, &!/1)
     end)}
  end

  def handle_event("add_transactions", %{"form_data" => form_data}, socket) do
    form_data
    |> form_data_with_selected_categories(socket)
    |> Kbf.Transaction.CSV.import_from_csv()
    |> case do
      {:ok,
       %{inserted_transactions: inserted_transactions, suspect_duplicates: suspect_duplicates}} ->
        {:noreply,
         socket
         |> clear_flash()
         |> assign(%{
           mass_import_changeset: changeset_from_data(%{}),
           selected_categories: %{},
           suspect_duplicates: unless(Enum.empty?(suspect_duplicates), do: suspect_duplicates)
         })
         |> KbfWeb.LayoutView.put_temporary_flash(
           :info,
           "Imported #{length(inserted_transactions)} transactions successfully.",
           :clear_flash
         )}

      {:error, _error} ->
        {:noreply,
         socket
         |> assign(:suspect_duplicates, nil)
         |> clear_flash()
         |> put_flash(:error, "Could not import transactions.")}
    end
  end

  def handle_event("validate", %{"form_data" => form_data}, socket) do
    {:noreply,
     assign(
       socket,
       :mass_import_changeset,
       form_data
       |> form_data_with_selected_categories(socket)
       |> changeset_from_data()
       |> Map.put(:action, :insert)
     )}
  end

  defp form_data_with_selected_categories(form_data, socket) do
    selected_categories = socket.assigns.selected_categories

    form_data
    |> Map.put(
      "categories",
      socket.assigns.all_categories
      |> Enum.filter(&selected_categories[&1.id])
    )
  end

  defp changeset_from_data(form_data), do: Kbf.Transaction.CSV.empty_changeset(form_data)

  defp list_suspect({%Ecto.Changeset{changes: changes}, duplicate}) do
    content_tag(
      :li,
      [
        "\"",
        content_tag(:span, changes[:description], class: "font-medium"),
        "\" (",
        format_currency(changes[:amount]),
        ") from ",
        format_date(changes[:when]),
        tag(:br),
        "(previously imported on ",
        format_date(duplicate.inserted_at),
        ")"
      ],
      class: "ml-4"
    )
  end
end
