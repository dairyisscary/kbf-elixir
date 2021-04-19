defmodule KbfWeb.Account.LoginLive do
  use KbfWeb, :bare_live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(
       socket,
       page_title: "Login to the Moon!",
       trigger_submit: false,
       changeset: Kbf.Account.login_changeset(%{})
     )}
  end

  @impl true
  def handle_params(_params, _url, socket), do: {:noreply, socket}

  @impl true
  def handle_event("attempt_login", %{"account" => login_params}, socket) do
    changeset = Kbf.Account.login_changeset(login_params)

    with_changeset = assign(socket, :changeset, changeset)

    if changeset.valid? do
      {:noreply, verify_login(with_changeset, login_params)}
    else
      {:noreply, with_changeset}
    end
  end

  defp verify_login(socket, login_params) do
    case Kbf.Account.verify_login(login_params) do
      {:ok, _user} ->
        assign(socket, trigger_submit: true)

      {:error, _message} ->
        put_flash(socket, :error, "Could not login with that username password pair.")
    end
  end
end
