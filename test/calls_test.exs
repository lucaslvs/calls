defmodule CallsTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  test "should calculate the total cost of a list of calls" do
    assert capture_io(fn -> Calls.main(["calls.csv"]) end) == "0.55\n"
  end
end
