defmodule Mensor.Finder do
  use GenServer

  @start_path ~S"D:\Programming\Work\DolfinMono\Atlantis"

  def start do
    GenServer.start(__MODULE__, nil)
  end

  @impl GenServer
  def init(_) do
    {:ok, nil, {:continue, :init}}
  end

  @impl GenServer
  def handle_continue(:init, nil) do
    IO.inspect(@start_path)

    Mensor.Finder.FileEnumeration.enumerate(@start_path)
    |> IO.inspect()

    # TODO: find *proj files
    # TODO: send their paths to discover dependencies

    {:noreply, nil}
  end
end

defmodule Mensor.Finder.FileEnumeration do
  def enumerate(path) do
    File.ls!(path)
    |> Enum.map(&PathHelpers.join(path, &1))
    |> Enum.map(fn p ->
      case File.dir?(p) do
        false -> p
        true -> enumerate(p)
      end
    end)
    |> List.flatten()
  end
end
