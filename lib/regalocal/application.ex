defmodule Regalocal.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Regalocal.Repo,
      RegalocalWeb.Telemetry,
      # Start the endpoint when the application starts
      RegalocalWeb.Endpoint,
      {Phoenix.PubSub, Application.get_env(:regalocal, RegalocalWeb.Endpoint)[:pubsub_config]}
      # Starts a worker by calling: Regalocal.Worker.start_link(arg)
      # {Regalocal.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Regalocal.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RegalocalWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
