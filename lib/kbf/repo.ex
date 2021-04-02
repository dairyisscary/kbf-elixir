defmodule Kbf.Repo do
  use Ecto.Repo,
    otp_app: :kbf,
    adapter: Ecto.Adapters.Postgres
end
