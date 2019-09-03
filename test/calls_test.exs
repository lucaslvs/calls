defmodule CallsTest do
  use ExUnit.Case
  doctest Calls

  test "greets the world" do
    assert Calls.hello() == :world
  end
end
