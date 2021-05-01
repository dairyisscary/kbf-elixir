defmodule KbfWeb.Category.ListingLiveTest do
  use KbfWeb.ConnCase, async: true

  test "GET /categories", %{conn: conn} do
    conn = get(conn, "/categories")
    assert html_response(conn, 200) =~ "Manage Categories"
  end
end
