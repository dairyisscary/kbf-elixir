defmodule KbfWeb do
  def controller do
    quote do
      use Phoenix.Controller, namespace: KbfWeb

      import Plug.Conn
      import Phoenix.LiveView.Controller

      alias KbfWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/kbf_web/templates",
        namespace: KbfWeb

      import Phoenix.LiveView.Helpers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  defp view_helpers do
    quote do
      use Phoenix.HTML

      import Phoenix.View
      import KbfWeb.ErrorHelpers
      import KbfWeb.ComponentHelpers
      import KbfWeb.Format

      alias KbfWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
