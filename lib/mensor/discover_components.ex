defmodule Mensor.DiscoverComponents do
  use GenServer

  def start(path) do
    # TODO: Filter out nonsense file types, keep .cs, .vb and.xaml,
    cond do
      String.contains?(path, "\\bin\\") -> :ignore
      String.contains?(path, "\\obj\\") -> :ignore
      true -> GenServer.start(Mensor.DiscoverComponents, path)
    end
  end

  @impl GenServer
  def init(path) do
    IO.inspect(path)
    {:ok, path, {:continue, :init}}
  end

  @impl GenServer
  def handle_continue(:init, path) do
    # TODO: Count occurances of component names
    # TODO: Use a dictionary to get a count of each component.
    # TODO: Include file exension in output.
    {:noreply, nil}
  end
end
