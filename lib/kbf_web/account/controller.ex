defmodule KbfWeb.Account.Controller do
  use KbfWeb, :controller

  def end_session(conn, _params) do
    conn
    |> KbfWeb.Session.logout_user()
    |> send_to_login()
  end

  def start_session(conn, %{"account" => params}) do
    case Kbf.Account.verify_login(params) do
      {:ok, user} ->
        conn
        |> KbfWeb.Session.login_user(user.id)
        |> send_to(Routes.live_path(conn, KbfWeb.Transaction.DashboardLive))

      {:error, _message} ->
        send_to_login(conn)
    end
  end

  defp send_to_login(conn) do
    send_to(conn, Routes.live_path(conn, KbfWeb.Account.LoginLive))
  end

  defp send_to(conn, to) do
    conn
    |> redirect(to: to)
    |> halt()
  end
end
