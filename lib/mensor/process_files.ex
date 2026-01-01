defmodule Mensor.ProcessFiles do
  def start_link() do
    IO.puts("Starting ProcessFiles")
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  def child_spec(_arg) do
    %{id: __MODULE__, start: {__MODULE__, :start_link, []}, type: :supervisor}
  end

  def process_filepath(path) do
    case start_child(path) do
      {:ok, pid} ->
        pid

      {:error, {:already_started, pid}} ->
        pid

      :ignore ->
        nil
    end
  end

  defp start_child(path) do
    case String.ends_with?(path, "proj") do
      true ->
        DynamicSupervisor.start_child(__MODULE__, {Mensor.DiscoverDependencies, path})

      false ->
        DynamicSupervisor.start_child(__MODULE__, {Mensor.DiscoverComponents, path})
    end
  end
end
