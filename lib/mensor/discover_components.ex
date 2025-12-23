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
    IO.inspect("path")
    IO.inspect(path)
    {:ok, {path, %{}}, {:continue, :init}}
  end

  @impl GenServer
  def handle_continue(:init, {path, dict}) do
    new_dict =
      File.stream!(path)
      |> Enum.map(&String.trim/1)
      |> Enum.reduce(dict, fn x, acc -> count_occurance(x, acc) end)

    # TODO: Send counts on to a tally actor.
    IO.inspect("new_dict")
    IO.inspect(new_dict)
    {:noreply, nil}
  end

  @spec count_occurance(binary(), map()) :: map()
  defp count_occurance(line, dict) do
    telerik_pattern = ~r/(?<!\/)(?<!schemas\.)(?<!namespace(:|\s))telerik[a-z0-9.:]+/iu

    matches =
      Regex.scan(telerik_pattern, line)

    case Enum.count(matches) do
      0 ->
        dict

      _ ->
        matches
        |> Enum.reduce(dict, fn
          occurance, acc ->
            case(Map.fetch(dict, occurance)) do
              :error ->
                Map.put_new(acc, occurance, 1)

              {:ok, value} ->
                entry = value + 1
                Map.put(acc, occurance, entry)
            end
        end)
    end
  end
end
