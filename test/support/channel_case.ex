defmodule KbfWeb.ChannelCase do
  @moduledoc """
  This module defines the test case to be used by
  channel tests.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with channels
      import Phoenix.ChannelTest
      import KbfWeb.ChannelCase

      # The default endpoint for testing
      @endpoint KbfWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Kbf.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Kbf.Repo, {:shared, self()})
    end

    :ok
  end
end
