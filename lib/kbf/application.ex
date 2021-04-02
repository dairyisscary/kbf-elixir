defmodule Kbf.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Kbf.Repo,
      # Start the Telemetry supervisor
      KbfWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Kbf.PubSub},
      # Start the Endpoint (http/https)
      KbfWeb.Endpoint
      # Start a worker by calling: Kbf.Worker.start_link(arg)
      # {Kbf.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Kbf.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    KbfWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
