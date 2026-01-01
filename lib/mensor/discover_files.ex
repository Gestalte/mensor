defmodule Mensor.DiscoverFiles do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    IO.puts("Starting DiscoverFiles")
    {:ok, nil}
  end

  def discover_files(path) do
    GenServer.cast(__MODULE__, path)
  end

  @impl GenServer
  def handle_cast(path, _) do
    File.ls!(path)
    |> Enum.map(&PathHelpers.join(path, &1))
    |> Enum.each(&handle_filepath/1)

    {:noreply, nil}
  end

  defp handle_filepath(path) do
    case File.dir?(path) do
      true -> Mensor.DiscoverFiles.discover_files(path)
      false -> Mensor.ProcessFiles.process_filepath(path)
    end
  end
end
