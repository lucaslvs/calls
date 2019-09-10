defmodule Calls do
  alias Calls.Call

  def main([csv_file_path]) do
    csv_file_path
    |> parse_parameters()
    |> create_and_calculate_calls()
    |> disregard_longer_call()
    |> calculate_total_cost_of_calls()
    |> IO.puts()
  end

  def main(_args), do: IO.puts("Invalid arguments")

  def parse_parameters(csv_file_path) do
    case File.read(csv_file_path) do
      {:ok, content} ->
        String.split(content, "\n")

      {:error, :enoent} ->
        IO.puts("The file #{csv_file_path} does not exist")

      {:error, :eisdir} ->
        IO.puts("The named file #{csv_file_path} is a directory")

      _ ->
        IO.puts("Invalid file")
    end
  end

  def create_and_calculate_calls(calls_parameters) do
    if Enum.empty?(calls_parameters) do
      IO.puts("The file has no calls")
    else
      calls_parameters
      |> Enum.map(&proccess_call_async/1)
      |> Enum.map(&Task.await/1)
    end
  end

  def proccess_call_async(call) do
    Task.async(fn ->
      calculate_duration_and_cost_call(call)
    end)
  end

  def calculate_duration_and_cost_call(call) do
    call
    |> create_call()
    |> Call.calcutate_duration()
    |> Call.calculate_cost()
  end

  def create_call(
        <<time_of_start::bytes-size(8)>> <>
          ";" <>
          <<time_of_finish::bytes-size(8)>> <>
          ";" <>
          <<call_from::bytes-size(13)>> <>
          ";" <>
          <<call_to::bytes-size(13)>>
      ) do
    try_create_call =
      Call.new(
        time_of_start: time_of_start,
        time_of_finish: time_of_finish,
        call_from: call_from,
        call_to: call_to
      )

    case try_create_call do
      {:ok, call} ->
        call

      {:error, :invalid_call} ->
        IO.puts("Invalid call register")
    end
  end

  def disregard_longer_call(calls) do
    calls
    |> Enum.sort_by(& &1.minutes_of_duration)
    |> Enum.drop(-1)
  end

  def calculate_total_cost_of_calls(calls) do
    calls
    |> Enum.map(& &1.total_cost)
    |> Enum.sum()
  end
end
