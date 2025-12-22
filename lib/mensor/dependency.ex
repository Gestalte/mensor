defmodule Mensor.Dependency do
  defstruct project: nil, language: nil, name: nil, version: nil, path: nil

  def new(project, language, name, version, path) do
    %Mensor.Dependency{
      project: project,
      language: language,
      name: name,
      version: version,
      path: path
    }
  end
end
