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
    projFiles =
      Mensor.Finder.FilepathEnumeration.proj_files(@start_path)

    slnPaths =
      Mensor.Finder.FilepathEnumeration.solution_proj_files(@start_path <> ".sln")

    (projFiles ++ slnPaths)
    |> Enum.sort()
    |> Enum.dedup()
    |> Enum.each(fn x -> Mensor.DiscoverDependencies.start(x) end)

    {:noreply, nil}
  end
end

defmodule Mensor.Finder.FilepathEnumeration do
  def enumerate_filepaths(path) do
    File.ls!(path)
    |> Enum.map(&PathHelpers.join(path, &1))
    |> Enum.map(fn p ->
      case File.dir?(p) do
        false -> p
        true -> enumerate_filepaths(p)
      end
    end)
    |> List.flatten()
  end

  def proj_files(path) do
    enumerate_filepaths(path)
    |> Enum.filter(fn x -> String.ends_with?(x, "proj") end)
  end

  # TODO: Replace Enum with Stream
  def solution_proj_files(path) do
    File.stream!(path)
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&String.starts_with?(&1, "Project("))
    |> Enum.map(&String.split(&1, ","))
    |> Enum.filter(fn x -> String.ends_with?(Enum.at(x, 1), "proj\"") end)
    |> Enum.map(&Enum.at(&1, 1))
    |> Enum.map(fn x -> String.slice(x, 2..(String.length(x) - 2)) end)
    |> Enum.map(fn x -> PathHelpers.parent(path) <> "\\" <> x end)
  end
end
