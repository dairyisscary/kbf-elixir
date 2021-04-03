defmodule KbfWeb.PageControllerTest do
  use KbfWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Dashboard"
  end

  test "GET /transactions", %{conn: conn} do
    conn = get(conn, "/transactions")
    assert html_response(conn, 200) =~ "All Transactions"
  end
end
