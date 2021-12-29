defmodule Todo.Web do
  def child_spec(_args) do
    Plug.Adapters.Cowboy.child_spec(scheme: :http, options: [port: 5454], plug: __MODULE__)
  end
end
