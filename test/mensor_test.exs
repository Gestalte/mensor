defmodule MensorTest do
  use ExUnit.Case
  doctest Mensor

  test "greets the world" do
    assert Mensor.hello() == :world
  end
end
