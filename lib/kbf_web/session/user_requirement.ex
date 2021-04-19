defmodule KbfWeb.Session.UserRequirement do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]

  def init(opts \\ []) do
    Keyword.fetch!(opts, :must_be_present)
  end

  def call(conn, must_be_present) do
    case KbfWeb.Session.verify_user(conn) do
      {:ok, _user_id} when must_be_present ->
        conn

      {:error, _reason} when must_be_present ->
        conn
        |> stop_to(KbfWeb.Router.Helpers.live_path(conn, KbfWeb.Account.LoginLive))

      {:ok, _user_id} ->
        conn
        |> stop_to(KbfWeb.Router.Helpers.live_path(conn, KbfWeb.Transaction.DashboardLive))

      {:error, _reason} ->
        conn
    end
  end

  defp stop_to(conn, to) do
    conn
    |> redirect(to: to)
    |> halt()
  end
end
