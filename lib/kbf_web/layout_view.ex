defmodule KbfWeb.LayoutView do
  use KbfWeb, :view

  @edit_modal_key :edit_transaction_for_modal

  def main_logo do
    ~E"""
    <span class="kbf-main-logo">
      <%= for _ <- 1..10 do %>
        <span class="kbf-main-logo-dot"></span>
      <% end %>
    </span>
    """
  end

  def nav_link(content, to: to, icon: icon) do
    ~E"""
    <%= live_patch to: to, class: "flex items-center transition-colors space-x-2 p-2 rounded-md hover:bg-gray-100" do %>
      <%= component "icon.html", name: icon, class: "w-6 h-6 text-gray-400" %><span><%= content %></span>
    <% end %>
    """
  end

  def live_assign_edit_modal(socket, transaction) do
    Phoenix.LiveView.assign(socket, @edit_modal_key, transaction)
  end

  def live_assign_add_modal(socket) do
    Phoenix.LiveView.assign(socket, @edit_modal_key, Kbf.Transaction.new())
  end

  def live_unassign_edit_modal(socket) do
    Phoenix.LiveView.assign(socket, @edit_modal_key, nil)
  end
end
