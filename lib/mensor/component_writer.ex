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
    IO.binwrite(file, "name|project|line|path|extension")

    {:ok, nil}
  end

  def write(data) do
    GenServer.cast(__MODULE__, {:write, data})
  end

  @impl GenServer
  def handle_cast({:write, data}, nil) do
    {:ok, file} = File.open(@output_folder <> "\\" <> @file_name, [:write, :append])

    project = find_proj(Path.dirname(data.path))
    relative_path = "..\\DolfinMono" <> Enum.at(String.split(data.path, "DolfinMono"), 1)
    file_extension = Path.extname(data.path)

    IO.binwrite(
      file,
      "\n#{data.name}|#{project}|#{data.line}|#{relative_path}|#{file_extension}"
    )

    File.close(file)

    {:noreply, nil}
  end

  def find_proj(path) do
    proj =
      File.ls!(path)
      |> Enum.filter(fn x -> String.ends_with?(x, "proj") end)
      |> List.first()

    case proj == nil do
      false -> proj
      true -> find_proj(PathHelpers.parent(path))
    end
  end
end
