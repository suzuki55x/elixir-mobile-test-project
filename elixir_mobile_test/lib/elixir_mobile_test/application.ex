defmodule ElixirMobileTest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ElixirMobileTestWeb.Telemetry,
      # Start the Ecto repository
      ElixirMobileTest.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ElixirMobileTest.PubSub},
      # Start Finch
      {Finch, name: ElixirMobileTest.Finch},
      # Start the Endpoint (http/https)
      ElixirMobileTestWeb.Endpoint
      # Start a worker by calling: ElixirMobileTest.Worker.start_link(arg)
      # {ElixirMobileTest.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirMobileTest.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElixirMobileTestWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
