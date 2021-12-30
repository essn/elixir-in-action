defmodule Todo.Cache do
  def start_link() do
    IO.puts("Starting to-do cache")
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  def server_process(todo_list_name) do
    :rpc.call(node_for_list(todo_list_name), Todo.Cache, :server_process, [todo_list_name])
  end

  defp node_for_list(todo_list_name) do
    all_sorted_nodes = Enum.sort(Node.list([:this, :visible]))
    node_index = :erlang.phash2(todo_list_name, length(all_sorted_nodes))
    Enum.at(all_sorted_nodes, node_index)
  end
end
