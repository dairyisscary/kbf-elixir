defmodule KbfWeb.Transaction.DashboardLiveTest do
  use KbfWeb.ConnCase, async: true

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Dashboard"
  end
end
