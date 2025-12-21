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

    projFiles =
      Mensor.Finder.FilepathEnumeration.proj_files(@start_path)
      |> IO.inspect()

    slnPaths =
      Mensor.Finder.FilepathEnumeration.solution_proj_files(@start_path <> ".sln")
      |> IO.inspect()

    diff =
      MapSet.symmetric_difference(MapSet.new(projFiles), MapSet.new(slnPaths))
      |> IO.inspect()

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
