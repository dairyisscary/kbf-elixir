use Mix.Config

config :kbf, Kbf.Repo,
  username: "postgres",
  password: "postgres",
  database: "kbf_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: System.get_env("DB_HOST") || "postgres",
  pool: Ecto.Adapters.SQL.Sandbox

config :kbf, KbfWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warn
