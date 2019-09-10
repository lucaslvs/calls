defmodule Calls.CallTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias Calls.Call

  @invalid_parameters [
    nil,
    1,
    1.0,
    "str",
    'bin',
    :atom,
    %{},
    [foo: "bar"],
    %{foo: "bar"}
  ]

  describe "new/1" do
    @valid_keyword_parameters [
      time_of_start: "09:11:30",
      time_of_finish: "09:15:22",
      call_from: "+351914374373",
      call_to: "+351215355312"
    ]
    @valid_map_parameters %{
      time_of_start: "09:11:30",
      time_of_finish: "09:15:22",
      call_from: "+351914374373",
      call_to: "+351215355312"
    }
    test "should return a Call struct when pass a valid keyword list like parameters" do
      assert {:ok, %Call{} = call} = Call.new(@valid_keyword_parameters)
      assert call.time_of_start == ~T[09:11:30]
      assert call.time_of_finish == ~T[09:15:22]
      assert call.call_from == @valid_keyword_parameters[:call_from]
      assert call.call_to == @valid_keyword_parameters[:call_to]
      assert call.minutes_of_duration == nil
      assert call.total_cost == nil
    end

    test "should return a Call struct when pass a map like parameters" do
      assert {:ok, %Call{} = call} = Call.new(@valid_map_parameters)
      assert call.time_of_start == ~T[09:11:30]
      assert call.time_of_finish == ~T[09:15:22]
      assert call.call_from == @valid_map_parameters[:call_from]
      assert call.call_to == @valid_map_parameters[:call_to]
      assert call.minutes_of_duration == nil
      assert call.total_cost == nil
    end

    test "should return a error when pass a invalid parameters" do
      Enum.each(@invalid_parameters, fn parameter ->
        assert Call.new(parameter) == {:error, :invalid_call}
      end)
    end
  end

  describe "calculate_duration/1" do
    test "should calculate the minutes of duration from a call" do
      call = %Call{
        time_of_start: ~T[09:11:30],
        time_of_finish: ~T[09:15:22],
        call_from: "+351914374373",
        call_to: "+351215355312",
        minutes_of_duration: nil,
        total_cost: nil
      }

      assert %Call{} = call = Call.calculate_duration(call)
      assert call.minutes_of_duration == 3
    end

    test "should print a error message when not receive a call struct" do
      Enum.each(@invalid_parameters, fn parameter ->
        assert capture_io(fn ->
                 Call.calculate_duration(parameter)
               end) == "Parameter is not a call struct\n"
      end)
    end
  end

  describe "calculate_cost/1" do
    test "should calculate the cost of call with 5 cents per minutes for the first 5 minutes" do
      call = %Call{
        time_of_start: ~T[09:11:30],
        time_of_finish: ~T[09:15:22],
        call_from: "+351914374373",
        call_to: "+351215355312",
        minutes_of_duration: nil,
        total_cost: nil
      }

      call =
        call
        |> Call.calculate_duration()
        |> Call.calculate_cost()

      assert %Call{} = call
      assert call.total_cost == 0.15
    end

    test "should calculate the cost of call with 5 cents per minutes for the first 5 minutes and 2 cents per minutes" do
      call = %Call{
        time_of_start: ~T[09:11:30],
        time_of_finish: ~T[09:18:22],
        call_from: "+351914374373",
        call_to: "+351215355312",
        minutes_of_duration: nil,
        total_cost: nil
      }

      call =
        call
        |> Call.calculate_duration()
        |> Call.calculate_cost()

      assert %Call{} = call
      assert call.total_cost == 0.27
    end

    test "should print a error message when receive a call struct without minutes_of_duration key" do
      call = %Call{
        time_of_start: ~T[09:11:30],
        time_of_finish: ~T[09:15:22],
        call_from: "+351914374373",
        call_to: "+351215355312",
        minutes_of_duration: nil,
        total_cost: nil
      }

      assert capture_io(fn ->
        Call.calculate_cost(call)
      end) == "Call struct don't have minutes_of_duration key\n"
    end

    test "should print a error message when not receive a call struct" do
      Enum.each(@invalid_parameters, fn parameter ->
        assert capture_io(fn ->
          Call.calculate_cost(parameter)
        end) == "Parameter is not a call struct\n"
      end)
    end
  end
end
