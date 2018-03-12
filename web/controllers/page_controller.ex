defmodule WebSocketsProject.PageController do
  use WebSocketsProject.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
