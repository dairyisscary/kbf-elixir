defmodule KbfWeb.Category.ListingLive do
  use KbfWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Kbf.Category.subscribe()

    socket =
      assign(socket,
        page_title: "Categories",
        user: KbfWeb.Session.get_user_from_socket_session!(session),
        transaction_add_opt_out: true,
        edit_modal_changeset: nil,
        delete_confirm_open: false,
        categories: Kbf.Category.all_with_counts() |> KbfWeb.Category.sort_by_name()
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket), do: {:noreply, socket}

  @impl true
  def handle_info({:category_created, new_category}, socket) do
    {:noreply, update_categories(socket, new_category)}
  end

  def handle_info({:category_updated, updated_category}, socket) do
    {:noreply, update_categories(socket, updated_category)}
  end

  def handle_info({:category_deleted, removed_category}, socket) do
    {:noreply, remove_category(socket, removed_category)}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  @impl true
  def handle_event("save_category", %{"category" => category_params}, socket) do
    editing_category = get_editing_category_from_socket(socket)

    operation =
      if editing_category do
        Kbf.Category.update(editing_category, category_params)
      else
        Kbf.Category.create(category_params)
      end

    case operation do
      {:ok, fresh_category} ->
        socket
        |> clear_flash()
        |> update_categories(fresh_category)
        |> KbfWeb.LayoutView.put_temporary_flash(
          :info,
          "Saved category successfully.",
          :clear_flash
        )
        |> with_category_changeset(nil)

      {:error, %Ecto.Changeset{} = changeset} ->
        socket
        |> clear_flash()
        |> put_flash(:error, "Could not save category.")
        |> with_category_changeset(changeset)
    end
  end

  def handle_event("open_modal", %{"id" => id}, socket) do
    category = socket.assigns.categories |> Enum.find(&(&1.id == id))

    socket
    |> clear_flash()
    |> with_category_changeset(Kbf.Category.changeset(category, %{}))
  end

  def handle_event("open_modal", _params, socket) do
    socket
    |> clear_flash()
    |> with_category_changeset(Kbf.Category.changeset(%Kbf.Category{}, %{}))
  end

  def handle_event("cancel_modal", _params, socket) do
    socket
    |> clear_flash()
    |> with_category_changeset(nil)
  end

  def handle_event("delete_category", _params, socket) do
    category = get_editing_category_from_socket(socket)

    case Kbf.Category.delete(category) do
      {:ok, _} ->
        socket
        |> clear_flash()
        |> assign(:delete_confirm_open, false)
        |> remove_category(category)
        |> KbfWeb.LayoutView.put_temporary_flash(
          :info,
          "Deleted category successfully.",
          :clear_flash
        )
        |> with_category_changeset(nil)

      {:error, _reason} ->
        {:noreply,
         socket
         |> clear_flash()
         |> put_flash(:error, "Could not delete.")}
    end
  end

  def handle_event("open_delete_modal", _params, socket) do
    {:noreply, assign(socket, :delete_confirm_open, true)}
  end

  def handle_event("cancel_delete_modal", _params, socket) do
    {:noreply, assign(socket, :delete_confirm_open, false)}
  end

  def handle_event("select_code", %{"color-code" => color_code}, socket) do
    changes =
      socket.assigns.edit_modal_changeset.changes
      |> Map.put(:color_code, color_code)

    editing_category = get_editing_category_from_socket(socket)

    changeset =
      Kbf.Category.changeset(editing_category || %Kbf.Category{}, changes)
      |> Map.put(:action, if(editing_category, do: :update, else: :insert))

    with_category_changeset(socket, changeset)
  end

  def handle_event("validate", %{"category" => category_params}, socket) do
    editing_category = get_editing_category_from_socket(socket)

    changeset =
      Kbf.Category.changeset(editing_category || %Kbf.Category{}, category_params)
      |> Map.put(:action, if(editing_category, do: :update, else: :insert))

    with_category_changeset(socket, changeset)
  end

  defp with_category_changeset(socket, changeset) do
    {:noreply, assign(socket, :edit_modal_changeset, changeset)}
  end

  defp get_editing_category_from_socket(socket),
    do: get_editing_category(socket.assigns[:edit_modal_changeset])

  defp get_editing_category(%Ecto.Changeset{data: data}) do
    if data.id, do: data, else: nil
  end

  defp get_editing_category(_), do: nil

  defp remove_category(socket, %Kbf.Category{id: id}) do
    update(socket, :categories, fn old_categories ->
      old_categories
      |> Enum.filter(&(&1.id != id))
      |> KbfWeb.Category.sort_by_name()
    end)
  end

  defp update_categories(socket, %Kbf.Category{id: id} = category) do
    update(socket, :categories, fn old_categories ->
      if Enum.any?(old_categories, fn cat -> cat.id == id end) do
        update_old_category(old_categories, category)
      else
        [category | old_categories]
      end
      |> KbfWeb.Category.sort_by_name()
    end)
  end

  defp update_old_category(old_categories, updated_category) do
    Enum.map(old_categories, fn category ->
      if category.id == updated_category.id do
        updated_category
      else
        category
      end
    end)
  end

  defp header_with_add_button() do
    ~E"""
    <span class="flex items-center justify-between">
      <span>Manage Categories</span>
      <%= component "button.html", phx_click: :open_modal, class: "text-base space-x-1" do %>
        <%= component "icon.html", name: "plus" %> <span>Add New Category</span>
      <% end %>
    </span>
    """
  end

  defp category_table_row(category) do
    [
      phx_click: :open_modal,
      phx_value_id: category.id,
      class: "cursor-pointer",
      id: "category-table-row-#{category.id}",
      do: [
        category.name,
        KbfWeb.Category.bg_color_on_display(category.color_code),
        category.transaction_count
      ]
    ]
  end
end
