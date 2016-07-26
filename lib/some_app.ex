defmodule SomeApp do
  use Application
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    redis = redis_options

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(SomeApp.Endpoint, []),

      supervisor(SomeApp.Fastlane.Supervisor, [:some_app_redis, [host: redis[:host],
                                                                 port: redis[:port],
                                                                 pool_size: 5,
                                                                 namespace: redis[:namespace]]]),
      # Start your own worker by calling: SomeApp.Worker.start_link(arg1, arg2, arg3)
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SomeApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SomeApp.Endpoint.config_change(changed, removed)
    :ok
  end

  def redis_options do
    Application.get_env(:some_app, :redis)
    |> Keyword.update!(:port, &(String.to_integer(&1)))
  end
end
