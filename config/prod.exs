import Config

http_port = String.to_integer(System.get_env("HTTP_PORT") || "4000")

config :kbf, KbfWeb.Endpoint,
  url: [host: System.get_env("HTTP_HOST"), port: http_port],
  http: [
    port: http_port,
    transport_options: [socket_opts: [:inet6]]
  ],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :kbf, Kbf.Repo, pool_size: String.to_integer(System.get_env("DB_POOL_SIZE") || "20")

config :logger, level: :notice

import_config "prod.secret.exs"
