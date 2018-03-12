defmodule WebSocketsProject.RoomServer do
  use GenServer

  # Client API
  def start_link(default) do
      GenServer.start_link(__MODULE__, default,name: :server_room)
  end

  @doc """
  Stops the registry.
  """
  def stop(server) do
    GenServer.stop(server)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(room) do
    GenServer.call(:server_room, {:lookup, room})
  end

  def getAll() do
    GenServer.call(:server_room, {:lookup_all})
  end

  @doc """
  Ensures there is a bucket associated to the given `name` in `server`.
  """
  def create(name) do
    GenServer.call(:server_room, {:create, name})
  end

  def getCountry(room_name) do
    GenServer.call(:server_room, {:check_country, room_name})
  end

  def randomizeCountry(room_name) do
    GenServer.call(:server_room, {:random_country, room_name})
  end
  # Server implementation
  def init(name: :room_server) do
    Agent.start_link(fn -> MapSet.new end, name: :room_agent)
    Agent.start_link(fn -> Map.new end, name: :room_questioneer)
    countries = ["Germany","Italy","France","Colombia","Russia","Poland"]
    {:ok, {countries}}
  end

  def handle_call({:lookup, _room}, _from, {_countries} = state) do
    {:reply, Agent.get(:room_agent, &(&1)), state}
  end

  def handle_call({:lookup_all}, _from, {_countries} = state) do
    {:reply, Agent.get(:room_agent, &(&1)), state}
  end

  def handle_call({:create, room}, _from, {countries} = state) do
      Agent.update(:room_agent, &MapSet.put(&1, room))
      Agent.update(:room_questioneer, &Map.put_new(&1, room,Enum.random(countries)))
      {:reply, Agent.get(:room_agent, &(&1)), state}
  end

  def handle_call({:check_country, room_name}, _from, {_countries} = state) do
    {:reply, Agent.get(:room_questioneer, &Map.get(&1,room_name)),state}
  end

  def handle_call({:random_country, room_name}, _from, {countries} = state) do
    last = Agent.get(:room_questioneer, &Map.get(&1,room_name))
    Agent.update(:room_questioneer, &Map.update!(&1,room_name, fn _x -> Enum.random(Enum.filter(countries, fn x -> x != last end)) end))
    {:reply, Agent.get(:room_questioneer, &Map.get(&1,room_name)),state}
  end


  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
