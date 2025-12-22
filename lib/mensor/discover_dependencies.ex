defmodule Mensor.DiscoverDependencies do
  use GenServer

  def start(path) do
    GenServer.start(Mensor.DiscoverDependencies, path)
  end

  @impl GenServer
  def init(path) do
    IO.inspect(path)
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

    File.stream!(path)
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&String.starts_with?(&1, "<Reference Include=\""))
    |> Enum.map(&extract_string(&1))
    |> Enum.map(&parse_line(&1))
    |> Enum.map(fn x -> Mensor.Dependency.new(filename, language, x.name, x.version, path) end)
    |> Enum.map(&Mensor.Writer.write(&1))

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
