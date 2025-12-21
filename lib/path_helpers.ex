defmodule PathHelpers do
  @spec join(binary(), binary()) :: binary()
  def join(left, right) do
    left <> "\\" <> right
  end

  @spec join(binary(), binary(), binary()) :: binary()
  def join(left, right, separator) do
    left <> separator <> right
  end

  def parent(path) do
    sep_pos = separator_at(path)
    String.slice(path, 0..(sep_pos - 1))
  end

  def separator_at(str) do
    len = String.length(str) - 1
    separator_at(str, len)
  end

  defp separator_at(str, pos) do
    case String.at(str, pos) do
      nil -> -1
      "\\" -> pos
      "/" -> pos
      _ -> separator_at(str, pos - 1)
    end
  end
end
