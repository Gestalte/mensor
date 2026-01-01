defmodule Mensor.System do
  @start_path ~S"D:\Programming\Work\DolfinMono\Atlantis"

  def start_link do
    Supervisor.start_link(
      [
        Mensor.DependencyWriter,
        Mensor.ComponentWriter,
        Mensor.DiscoverFiles,
        Mensor.ProcessFiles
      ],
      strategy: :one_for_one
    )

    Registry.start_link(name: :my_registry, keys: :unique)
    Mensor.DiscoverFiles.discover_files(@start_path)
  end
end
