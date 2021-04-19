defmodule KbfWeb.Session do
  import Plug.Conn

  # 1 day timeout
  @timeout_after_seconds 86_400

  def login_user(conn, %{id: id}), do: login_user(conn, id)

  def login_user(conn, user_id) do
    Plug.CSRFProtection.delete_csrf_token()

    conn
    |> put_session(:user_id, user_id)
    |> put_session_fresh_expires_at()
  end

  def logout_user(conn) do
    conn
    |> clear_session()
    |> configure_session(renew: true)
  end

  def verify_user(conn) do
    case {get_session(conn, :user_id), get_session(conn, :expires_at)} do
      {nil, _} ->
        {:error, :empty}

      {_, nil} ->
        {:error, :empty}

      {user_id, expires_at} ->
        verify_expiration(conn, user_id, expires_at)
    end
  end

  def get_user_from_socket_session!(%{"user_id" => user_id}) do
    Kbf.User.get!(user_id)
  end

  defp verify_expiration(conn, user_id, expires_at) do
    if now_in_seconds() > expires_at do
      logout_user(conn)
      {:error, :expired}
    else
      put_session_fresh_expires_at(conn)
      {:ok, user_id}
    end
  end

  defp put_session_fresh_expires_at(conn) do
    expires_at = now_in_seconds() + @timeout_after_seconds

    conn
    |> put_session(:expires_at, expires_at)
  end

  defp now_in_seconds() do
    DateTime.utc_now()
    |> DateTime.to_unix()
  end
end
