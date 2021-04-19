defmodule KbfWeb.Transaction.ListingLiveTest do
  use KbfWeb.ConnCase, async: true

  test "GET /transactions", %{conn: conn} do
    conn = get(conn, "/transactions")
    assert html_response(conn, 200) =~ "All Transactions"
  end
end
