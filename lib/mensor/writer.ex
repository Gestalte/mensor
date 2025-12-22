defmodule Mensor.Writer do
  use GenServer

  @output_folder "./output"

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    File.mkdir_p!(@output_folder)
    File.rm(@output_folder <> "\\" <> "dependencies.csv")

    {:ok, file} = File.open(@output_folder <> "\\" <> "dependencies.csv", [:write, :append])

    IO.binwrite(
      file,
      "project,language,name,version,path"
    )

    {:ok, nil}
  end

  def write(data) do
    GenServer.cast(__MODULE__, {:write, data})
  end

  @impl GenServer
  def handle_cast({:write, data}, nil) do
    {:ok, file} = File.open(@output_folder <> "\\" <> "dependencies.csv", [:write, :append])

    IO.binwrite(
      file,
      "\n#{data.project},#{data.language},#{data.name},#{data.version},#{data.path}"
    )

    File.close(file)

    {:noreply, nil}
  end
end
