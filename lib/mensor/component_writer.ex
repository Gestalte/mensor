defmodule Mensor.ComponentWriter do
  use GenServer

  @output_folder "./output"
  @file_name "components.csv"

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    File.mkdir_p!(@output_folder)
    File.rm(@output_folder <> "\\" <> @file_name)

    {:ok, file} = File.open(@output_folder <> "\\" <> @file_name, [:write, :append])
    IO.binwrite(file, "name|line|path|extension")

    {:ok, nil}
  end

  def write(data) do
    GenServer.cast(__MODULE__, {:write, data})
  end

  @impl GenServer
  def handle_cast({:write, data}, nil) do
    {:ok, file} = File.open(@output_folder <> "\\" <> @file_name, [:write, :append])

    IO.binwrite(file, "\n#{data.name}|#{data.line}|#{data.path}|#{data.extension}")
    File.close(file)

    {:noreply, nil}
  end
end
