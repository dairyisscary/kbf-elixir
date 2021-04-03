defmodule KbfWeb.LayoutView do
  use KbfWeb, :view

  def main_logo do
    ~E"""
    <div class="kbf-main-logo">
      <%= for i <- 1..10 do %>
        <div class="kbf-main-logo-dot"></div>
      <% end %>
    </div>
    """
  end

  def nav_link(content, to: to, icon: icon) do
    ~E"""
    <a href="<%= to %>" class="flex items-center transition-colors space-x-2 p-2 rounded-md hover:bg-gray-100">
      <%= component "icon.html", name: icon, class: "w-6 h-6 text-gray-400" %><span><%= content %></span>
    </a>
    """
  end
end
