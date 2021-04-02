defmodule KbfWeb.TransactionController do
  use KbfWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
