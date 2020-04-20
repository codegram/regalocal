# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :regalocal,
  ecto_repos: [Regalocal.Repo]

config :regalocal, :basic_auth, username: "admin", password: "admin1234"

# Configures the endpoint
config :regalocal, RegalocalWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XMuJ7ME/8moiixzMitosPT8iArJ5MLQZBU1q9N6gDVZ8+rh+BRJs1VtqUlCvN4aG",
  render_errors: [view: RegalocalWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Regalocal.PubSub,
  pubsub_config: [name: Regalocal.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "jyq71W8L"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

# -- Veil Configuration    Don't remove this line
config :veil,
  site_name: "Regalocal",
  email_from_name: "Regalocal",
  email_from_address: "regalocal@codegram.com",
  # How long should emailed sign-in links be valid for?
  sign_in_link_expiry: 12 * 3_600,
  # How long should sessions be valid for?
  session_expiry: 86_400 * 30,
  # How often should existing sessions be extended to session_expiry
  refresh_expiry_interval: 86_400,
  # How many recent sessions to keep in cache (to reduce database operations)
  sessions_cache_limit: 250,
  # How many recent users to keep in cache
  users_cache_limit: 100

config :regalocal, Regalocal.Veil,
  request_salt: "ink8S8TjVvDsrEwZNOwDXGBqHYoUL6QwLVOOSm+7ezkunQ==",
  session_salt: "Da7enKE5RxV9Hw8A7Yi1JzIx2pAeorqnqxzfsCOn/ndi1hU="

config :veil, Veil.Scheduler,
  jobs: [
    # Runs every midnight to delete all expired requests and sessions
    {"@daily", {Regalocal.Veil.Clean, :expired, []}}
  ]
