defmodule Mensor.DependencyWriter do
  use GenServer

  @output_folder "./output"

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  # TODO: Hold onto the open file and use it for all writes, close it when exiting.
  @impl GenServer
  def init(_) do
    IO.puts("Starting ComponentWriter")
    File.mkdir_p!(@output_folder)
    File.rm(@output_folder <> "\\" <> "dependencies.csv")

    {:ok, file} = File.open(@output_folder <> "\\" <> "dependencies.csv", [:write, :append])

    IO.binwrite(
      file,
      "project,language,name,version,path"
    )

    {:ok, file}
  end

  def write(data) do
    GenServer.cast(__MODULE__, {:write, data})
  end

  @impl GenServer
  def handle_cast({:write, data}, file) do
    # {:ok, file} = File.open(@output_folder <> "\\" <> "dependencies.csv", [:write, :append])

    IO.binwrite(
      file,
      "\n#{data.project},#{data.language},#{data.name},#{data.version},#{data.path}"
    )

    # File.close(file)

    {:noreply, file}
  end
end
