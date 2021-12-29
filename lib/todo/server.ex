defmodule Todo.Server do
  use GenServer, restart: :temporary

  @expiry_idle_timeout :timer.seconds(10)

  # Client

  def start_link(name) do
    IO.puts("Starting to-do server for #{name}.")

    GenServer.start_link(Todo.Server, name, name: via_tuple(name))
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  # Server

  @impl true
  def init(name) do
    {:ok, {name, Todo.Database.get(name) || Todo.List.new()}, @expiry_idle_timeout}
  end

  @impl true
  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}, @expiry_idle_timeout}
  end

  @impl true
  def handle_call({:entries, date}, _, {name, todo_list}) do
    {
      :reply,
      Todo.List.entries(todo_list, date),
      {name, todo_list},
      @expiry_idle_timeout
    }
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end
end
