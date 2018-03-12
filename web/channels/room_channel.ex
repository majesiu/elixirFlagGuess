defmodule WebSocketsProject.RoomChannel do
  require Logger
  use WebSocketsProject.Web, :channel
  alias WebSocketsProject.RoomServer, as: RoomServer

  def join(roomname, payload, socket) do
    if authorized?(payload) do
      WebSocketsProject.RoomServer.create(roomname)
      {:ok, %{:Room_names => WebSocketsProject.RoomServer.getAll}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, Map.put(payload,:Room_names,RoomServer.getAll)}, socket}
  end

  def handle_in("phx_close", payload, socket) do
    {:reply,  WebSocketsProject.Endpoint.unsubscribe(payload["message"]), socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", Map.put(payload,:Room_names,RoomServer.getAll)
    {:noreply, socket}
  end

  def handle_in("question", _payload, socket) do
    {:reply, {:ok, %{:type => "question", :country => RoomServer.getCountry(socket.topic),:Room_names => RoomServer.getAll}}, socket}
  end

  def handle_in("answer", payload, socket) do
    Logger.info "The answer for #{socket.topic} is #{RoomServer.getCountry(socket.topic)}"
    if payload["message"] === RoomServer.getCountry(socket.topic) do
      RoomServer.randomizeCountry(socket.topic)
      broadcast socket, "correct_answer", Map.merge(payload,%{:Room_names => RoomServer.getAll,
      :Next_question => RoomServer.getCountry(socket.topic)})
      {:reply, {:ok, %{:type => "answer", :state => "right"}}, socket}
    else
      {:reply, {:ok, %{:type => "answer", :state => "wrong"}}, socket}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
