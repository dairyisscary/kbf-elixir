defmodule KbfWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import KbfWeb.ConnCase

      alias KbfWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint KbfWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Kbf.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Kbf.Repo, {:shared, self()})
    end

    conn = Phoenix.ConnTest.build_conn()

    conn =
      unless tags[:without_user] do
        conn_with_user(conn)
      else
        conn
      end

    {:ok, conn: conn}
  end

  def conn_with_user(conn) do
    %{password_hash: password_hash} = Pbkdf2.add_hash("password")

    user = Kbf.Repo.insert!(%Kbf.Account{username: "test_user", password_hash: password_hash})

    now_in_seconds = DateTime.utc_now() |> DateTime.to_unix()

    conn
    |> Plug.Test.init_test_session(user_id: user.id, expires_at: now_in_seconds + 24 * 60 * 60)
  end
end
