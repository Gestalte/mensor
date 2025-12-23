defmodule Mensor.DiscoverComponents do
  use GenServer

  def start(path) do
    cond do
      String.contains?(path, "\\bin\\") ->
        :ignore

      String.contains?(path, "\\obj\\") ->
        :ignore

      not String.ends_with?(path, [".cs", ".fs", ".fsx", ".vb", ".xaml"]) ->
        :ignore

      true ->
        GenServer.start(Mensor.DiscoverComponents, path)
    end
  end

  @impl GenServer
  def init(path) do
    {:ok, path, {:continue, :init}}
  end

  @impl GenServer
  def handle_continue(:init, path) do
    File.stream!(path)
    |> Enum.map(&String.trim/1)
    |> Enum.each(&collect_occurance(&1, path))

    {:noreply, nil}
  end

  defp collect_occurance(line, path) do
    telerik_pattern = ~r/(?<!\/)(?<!schemas\.)(?<!namespace(:|\s))telerik[a-z0-9.:]+/i

    file_extension = Path.extname(path)
    relative_path = "..\\DolfinMono" <> Enum.at(String.split(path, "DolfinMono"), 1)

    Regex.scan(telerik_pattern, line)
    |> Enum.filter(fn x -> x != [] end)
    |> Enum.map(fn x ->
      %{name: x, line: line, path: relative_path, extension: file_extension}
    end)
    |> Enum.each(&Mensor.ComponentWriter.write(&1))
  end
end
