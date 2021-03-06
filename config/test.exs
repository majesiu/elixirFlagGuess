use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :web_sockets_project, WebSocketsProject.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :web_sockets_project, WebSocketsProject.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "web_sockets_project_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
