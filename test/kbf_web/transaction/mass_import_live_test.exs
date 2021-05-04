defmodule KbfWeb.Transaction.MassImportLiveTest do
  use KbfWeb.ConnCase, async: true

  test "GET /mass-import", %{conn: conn} do
    conn = get(conn, "/mass-import")
    assert html_response(conn, 200) =~ "Mass Import Transactions from CSV"
  end
end
