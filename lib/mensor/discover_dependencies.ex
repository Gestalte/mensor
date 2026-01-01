defmodule Mensor.DiscoverDependencies do
  use GenServer, restart: :temporary

  def start_link(path) do
    GenServer.start_link(__MODULE__, path, name: via_tuple(path))
  end

  defp via_tuple(path) do
    {:via, Registry, {:my_registry, {__MODULE__, path}}}
  end

  @impl GenServer
  def init(path) do
    IO.puts("Start DiscoverDependencies for #{path}")
    {:ok, path, {:continue, :init}}
  end

  @impl GenServer
  def handle_continue(:init, path) do
    filename = PathHelpers.filename(path, false)

    language =
      case Path.extname(path) do
        ".csproj" -> "C#"
        ".vbproj" -> "VB.Net"
        ".fsproj" -> "F#"
        _ -> "Unknown"
      end

    relative_path = "..\\DolfinMono" <> Enum.at(String.split(path, "DolfinMono"), 1)

    File.stream!(path)
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&String.starts_with?(&1, "<Reference Include=\""))
    |> Stream.map(&extract_string(&1))
    |> Stream.map(&parse_line(&1))
    |> Stream.map(fn x ->
      Mensor.Dependency.new(filename, language, x.name, x.version, relative_path)
    end)
    |> Enum.to_list()
    |> Enum.each(&Mensor.DependencyWriter.write(&1))

    {:noreply, nil}
  end

  defp extract_string(line) do
    len = String.length(line)
    String.slice(line, 20..(len - 2))
  end

  defp parse_line(line) do
    line_parts = String.split(line, ",")
    count = Enum.count(line_parts)

    cond do
      count == 1 ->
        str = Enum.at(line_parts, 0)
        len = String.length(str)
        sep = PathHelpers.find_char_position(str, ~S("), len - 1)
        %{name: String.slice(str, 0..(sep - 1)), version: nil}

      count >= 2 ->
        version = Enum.at(line_parts, 1)
        len = String.length(version)
        %{name: Enum.at(line_parts, 0), version: String.slice(version, 9..len)}
    end
  end
end
