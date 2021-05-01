defmodule KbfWeb.LayoutView do
  use KbfWeb, :view

  @edit_modal_key :edit_transaction_for_modal
  @edit_modal_categories_key :edit_modal_categories

  def nav_link(content, to: to, icon: icon) do
    ~E"""
    <%= live_patch to: to, class: "flex items-center transition-colors space-x-2 p-2 rounded-md hover:bg-gray-100" do %>
      <%= component "icon.html", name: icon, class: "w-6 h-6 text-gray-400" %><span><%= content %></span>
    <% end %>
    """
  end

  def flash_alerts(flash) do
    alerts = ["error", "info"] |> Enum.filter(&Map.has_key?(flash, &1))

    if List.first(alerts) do
      ~E"""
      <div class="fixed animate-fade-in-down bottom-4 right-3 flex flex-col justify-end space-y-3">
        <%= for key <- alerts do
          flash_alert(flash, key)
        end %>
      </div>
      """
    end
  end

  def flash_alert(flash, key) do
    outer_class = if key == "error", do: "text-red-600", else: "text-purple-600"

    inner_class = if key == "error", do: "bg-red-600", else: "bg-purple-600"

    icon_name = if key == "error", do: "alert-triangle", else: "info"

    ~E"""
    <div role="alert" class="flex items-center relative shadow border bg-white px-5 py-4 rounded <%= outer_class %>">
      <%= component "icon.html", name: icon_name %>
      <span class="ml-2"><%= live_flash(flash, key) %></span>
      <div class="flex absolute h-3 w-3 -top-1 -right-1">
        <div class="animate-ping absolute inline-flex h-full w-full rounded-full opacity-75 <%= inner_class %>"></div>
        <div class="relative inline-flex rounded-full h-3 w-3 <%= inner_class %>"></div>
      </div>
    </div>
    """
  end

  def live_assign_edit_modal(socket, %{categories: categories, transaction: transaction}) do
    Phoenix.LiveView.assign(socket, %{
      @edit_modal_key => transaction,
      @edit_modal_categories_key => categories
    })
  end

  def live_assign_add_modal(socket, %{categories: categories}) do
    Phoenix.LiveView.assign(socket, %{
      @edit_modal_key => Kbf.Transaction.new(),
      @edit_modal_categories_key => categories
    })
  end

  def live_unassign_edit_modal(socket) do
    Phoenix.LiveView.assign(socket, %{@edit_modal_key => nil, @edit_modal_categories_key => nil})
  end

  def put_temporary_flash(socket, flash_kind, flash_message, proc_message) do
    Process.send_after(self(), proc_message, 8_000)

    Phoenix.LiveView.put_flash(socket, flash_kind, flash_message)
  end
end
