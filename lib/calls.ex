defmodule Calls do
  alias Calls.Call

  def main([csv_file_path]) do
    csv_file_path
    |> File.stream!()
    |> Enum.map(&create_task_to_calculate_call/1)
    |> Enum.map(&Task.await/1)
    |> disregard_longer_call()
    |> calculate_total_cost()
    |> IO.puts()
  end

  def main(_args), do: IO.puts("Invalid arguments")

  def create_task_to_calculate_call(call), do: Task.async(fn -> calculate_call(call) end)

  def calculate_call(call) do
    call
    |> create_call()
    |> Call.calcutate_duration()
    |> Call.calculate_cost()
  end

  def create_call(
    <<time_of_start::bytes-size(8)>> <> ";" <>
    <<time_of_finish::bytes-size(8)>> <> ";" <>
    <<call_from::bytes-size(13)>> <> ";" <>
    <<call_to::bytes-size(13)>> <> "\n"
    ) do
    try_create_call(
      time_of_start: time_of_start,
      time_of_finish: time_of_finish,
      call_from: call_from,
      call_to: call_to
    )
  end

  def create_call(
    <<time_of_start::bytes-size(8)>> <> ";" <>
    <<time_of_finish::bytes-size(8)>> <> ";" <>
    <<call_from::bytes-size(13)>> <> ";" <>
    <<call_to::bytes-size(13)>>
    ) do
    try_create_call(
      time_of_start: time_of_start,
      time_of_finish: time_of_finish,
      call_from: call_from,
      call_to: call_to
    )
  end

  def disregard_longer_call(calls) do
    calls
    |> Enum.sort_by(&(&1.minutes_of_duration))
    |> Enum.drop(-1)
  end

  def calculate_total_cost(calls) do
    calls
    |> Enum.map(&(&1.total_cost))
    |> Enum.sum()
  end

  defp try_create_call(params) do
    case Call.new(params) do
      {:ok, call} ->
        call
      {:error, :invalid_call} ->
        IO.puts("Invalid call register")
    end
  end
end
