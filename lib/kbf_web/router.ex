defmodule KbfWeb.Router do
  use KbfWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_live_flash
    plug :put_root_layout, {KbfWeb.LayoutView, :root}
  end

  pipeline :require_user do
    plug KbfWeb.Session.UserRequirement, must_be_present: true
  end

  pipeline :require_no_user do
    plug KbfWeb.Session.UserRequirement, must_be_present: false
  end

  scope "/", KbfWeb do
    pipe_through [:browser, :require_no_user]

    live "/login", Account.LoginLive
    post "/start-session", Account.Controller, :start_session, as: :account
  end

  scope "/", KbfWeb do
    pipe_through [:browser, :require_user]

    live "/", Transaction.DashboardLive
    live "/transactions", Transaction.ListingLive
    post "/end-session", Account.Controller, :end_session, as: :account
    live_dashboard "/dashboard", metrics: KbfWeb.Telemetry
  end
end
