defmodule KbfWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :kbf

  @session_options [
    store: :cookie,
    key: "_kbf_key",
    same_site: "Strict",
    http_only: true,
    signing_salt: "vrlDC0YaqOUfgWAo7JD8wgkdW95yR+wQ"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  plug Plug.Static,
    at: "/",
    from: :kbf,
    gzip: true,
    only_matching: ~w(css fonts images js icon-sprite.svg favicon)

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :kbf
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug KbfWeb.Router
end
