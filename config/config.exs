use Mix.Config

config :kbf,
  ecto_repos: [Kbf.Repo]

config :kbf, :generators,
  migration: true,
  binary_id: true,
  sample_binary_id: "11111111-1111-1111-1111-111111111111"

config :kbf, Kbf.Repo,
  migration_timestamps: [type: :utc_datetime],
  migration_primary_key: [name: :id, type: :binary_id]

config :kbf, KbfWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "tMKM88ZcFDzDRxypttKZsuoaltVQpQW2wi4eOC1MV3AeraYsqEiHc9U5U2fIwp1D",
  render_errors: [view: KbfWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Kbf.PubSub,
  live_view: [signing_salt: "Ta5Bo9MO"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
