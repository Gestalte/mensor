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

  def filename(path, include_extension \\ true) do
    case include_extension do
      true ->
        len = String.length(path) - 1
        IO.inspect(len)
        sep_pos = find_char_position(path, "\\", len)
        IO.inspect(sep_pos)
        String.slice(path, (sep_pos + 1)..len)

      false ->
        len = String.length(path) - 1
        sep_pos = find_char_position(path, "\\")
        base = String.slice(path, (sep_pos + 1)..len)
        period_pos = find_char_position(base, ".")
        String.slice(base, 0..(period_pos - 1))
    end
  end

  def find_char_position(str, char) do
    len = String.length(str) - 1
    find_char_position(str, char, len)
  end

  def find_char_position(str, char, pos) do
    case String.at(str, pos) do
      nil -> -1
      ^char -> pos
      _ -> find_char_position(str, char, pos - 1)
    end
  end

  defp separator_at(str) do
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
