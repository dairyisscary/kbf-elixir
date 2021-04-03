defmodule KbfWeb.Router do
  use KbfWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", KbfWeb do
    pipe_through :browser

    get "/", TransactionController, :dashboard_index
    get "/transactions", TransactionController, :index
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: KbfWeb.Telemetry
    end
  end
end
