defmodule Calls do
  alias Calls.Call

  @spec main(any) :: :ok
  def main([file]) do
    try do
      file
      |> parse_parameters()
      |> create_and_calculate_calls()
      |> disregard_longer_call()
      |> calculate_total_cost_of_calls()
      |> IO.puts()
    rescue
      _ -> System.halt(1)
    end
  end

  def main(_arguments), do: IO.puts("Invalid arguments")

  defp parse_parameters(file) do
    read_file =
      file
      |> Path.expand()
      |> File.read()

    case read_file do
      {:ok, content} ->
        String.split(content, "\n")

      {:error, :enoent} ->
        IO.puts("The file #{file} does not exist")

      {:error, :eisdir} ->
        IO.puts("The named file #{file} is a directory")

      _ ->
        IO.puts("Invalid file")
    end
  end

  defp create_and_calculate_calls(calls_parameters) do
    if Enum.empty?(calls_parameters) do
      IO.puts("The file has no calls")
    else
      calls_parameters
      |> Enum.map(&proccess_call_async/1)
      |> Enum.map(&Task.await/1)
    end
  end

  defp proccess_call_async(call) do
    Task.async(fn ->
      call
      |> create_call()
      |> calculate_duration_and_cost_call()
    end)
  end

  defp create_call(
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
        System.halt(1)
    end
  end

  defp create_call(_parameter) do
    IO.puts("Invalid call register")
    System.halt(1)
  end

  defp calculate_duration_and_cost_call(%Call{} = call) do
    call
    |> Call.calculate_duration()
    |> Call.calculate_cost()
  end

  defp disregard_longer_call(calls) do
    calls
    |> Enum.sort_by(& &1.minutes_of_duration)
    |> Enum.drop(-1)
  end

  defp calculate_total_cost_of_calls(calls) do
    calls
    |> Enum.map(& &1.total_cost)
    |> Enum.sum()
  end
end
