defmodule PathHelpers do
  @spec join(binary(), binary()) :: binary()
  def join(left, right) do
    left <> "\\" <> right
  end

  @spec join(binary(), binary(), binary()) :: binary()
  def join(left, right, separator) do
    left <> separator <> right
  end
end
