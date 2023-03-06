import Config

# Configure your database
database = [
  username: "postgres",
  password: "postgres",
  database: "glimesh_dev",
  hostname: System.get_env("DATABASE_URL") || "localhost",
  show_sensitive_data_on_connection_error: true,
  stacktrace: true,
  pool_size: 10
]

config :glimesh, Glimesh.Repo, database
config :glimesh, Glimesh.Repo.ReadReplica, database

# For development, we build directly to the priv/public folder so we can have instant reloads
# For production, build directly to priv/assets so it can be digested
config :esbuild,
  version: "0.12.18",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :glimesh, GlimeshWeb.Endpoint,
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    esbuild: {
      Esbuild,
      :install_and_run,
      [:default, ~w(--sourcemap=inline --watch)]
    },
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ],
  url: [host: "localhost", port: 4001],
  http: [port: 4000],
  https: [
    port: 4001,
    cipher_suite: :strong,
    keyfile: "priv/cert/selfsigned_key.pem",
    certfile: "priv/cert/selfsigned.pem",
    transport_options: [socket_opts: [:inet6]]
  ]

config :glimesh, GlimeshWeb.Emails.Mailer, adapter: Bamboo.LocalAdapter

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :glimesh, GlimeshWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/public/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/glimesh_web/(controllers|live|views|components)/.*(ex|heex|js)$",
      ~r"lib/glimesh_web/live/.*(sface)$",
      ~r"lib/glimesh_web/templates/.*(eex|md)$"
    ]
  ]

# Enable dev routes for dashboard and mailbox
config :glimesh, dev_routes: true

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Loads only the English and Spanish locales for development, which speeds up compilation time
config :glimesh, GlimeshWeb.Gettext, allowed_locales: ["en", "es"]

config :glimesh, :stripe_config,
  platform_sub_supporter_product_id: "prod_platform_supporter",
  platform_sub_supporter_price_id: "price_platform_supporter",
  platform_sub_supporter_price: 500,
  platform_sub_founder_product_id: "prod_platform_founder",
  platform_sub_founder_price_id: "price_platform_founder",
  platform_sub_founder_price: 2500,
  channel_sub_base_product_id: "prod_channel_sub",
  channel_sub_base_price_id: "price_channel_sub",
  channel_sub_base_price: 500,
  channel_donation_product_id: "prod_channel_donation"

if File.exists?("config/local.exs") do
  import_config "local.exs"
end
