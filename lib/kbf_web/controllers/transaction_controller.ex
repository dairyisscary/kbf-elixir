defmodule KbfWeb.TransactionController do
  use KbfWeb, :controller

  def dashboard_index(conn, _params) do
    render(conn, "dashboard_index.html",
      total_transaction_count: Kbf.Transaction.total_count(),
      recent_transactions: Kbf.Transaction.newer_than_n_days_ago(10)
    )
  end

  def index(conn, _params) do
    render(conn, "index.html", transactions: Kbf.Transaction.newer_than_n_days_ago(30))
  end
end
