defmodule Mensor.DiscoverComponents do
  use GenServer, restart: :temporary

  def start_link(path) do
    cond do
      String.contains?(path, "\\bin\\") ->
        :ignore

      String.contains?(path, "\\obj\\") ->
        :ignore

      not String.ends_with?(path, [".cs", ".fs", ".fsx", ".vb", ".xaml"]) ->
        :ignore

      true ->
        GenServer.start_link(__MODULE__, path, name: via_tuple(path))
    end
  end

  defp via_tuple(path) do
    {:via, Registry, {:my_registry, {__MODULE__, path}}}
  end

  @impl GenServer
  def init(path) do
    IO.puts("Starting DiscoverComponents for #{path}")
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

    Regex.scan(telerik_pattern, line)
    |> Enum.filter(fn x -> x != [] end)
    |> Enum.map(fn x ->
      %{
        name: x,
        line: line,
        path: path
      }
    end)
    |> Enum.each(&Mensor.ComponentWriter.write(&1))
  end
end
