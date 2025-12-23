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
    atlantis_filepaths = Mensor.Finder.FilepathEnumeration.enumerate_filepaths(@start_path)

    projFiles =
      atlantis_filepaths
      |> Enum.filter(fn x -> String.ends_with?(x, "proj") end)

    slnProjPaths = Mensor.Finder.FilepathEnumeration.solution_proj_files(@start_path <> ".sln")

    (projFiles ++ Enum.to_list(slnProjPaths))
    |> Enum.sort()
    |> Enum.dedup()
    |> Enum.each(fn x -> Mensor.DiscoverDependencies.start(x) end)

    external_filepaths =
      MapSet.difference(MapSet.new(slnProjPaths), MapSet.new(projFiles))
      |> Enum.map(&PathHelpers.parent(&1))
      |> Enum.map(&Mensor.Finder.FilepathEnumeration.enumerate_filepaths(&1))
      |> List.flatten()

    (atlantis_filepaths ++ external_filepaths)
    |> Enum.each(&Mensor.DiscoverComponents.start(&1))

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

  def solution_proj_files(path) do
    File.stream!(path)
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&String.starts_with?(&1, "Project("))
    |> Stream.map(&String.split(&1, ","))
    |> Stream.filter(fn x -> String.ends_with?(Enum.at(x, 1), "proj\"") end)
    |> Stream.map(&Enum.at(&1, 1))
    |> Stream.map(fn x -> String.slice(x, 2..(String.length(x) - 2)) end)
    |> Stream.map(fn x -> PathHelpers.parent(path) <> "\\" <> x end)
  end
end
