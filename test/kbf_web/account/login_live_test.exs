defmodule KbfWeb.Account.LoginLiveTest do
  use KbfWeb.ConnCase, async: true

  @tag :without_user
  test "GET /login", %{conn: conn} do
    conn = get(conn, "/login")
    assert html_response(conn, 200) =~ "Kbf Login"
  end
end
