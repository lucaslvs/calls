defmodule Calls do
  alias Calls.Call

  @spec main(any) :: :ok
  def main([csv_file_path]) do
    csv_file_path
    |> parse_parameters()
    |> create_and_calculate_calls()
    |> disregard_longer_call()
    |> calculate_total_cost_of_calls()
    |> IO.puts()
  end

  def main(_args), do: IO.puts("Invalid arguments")

  @spec parse_parameters(binary | maybe_improper_list(binary | maybe_improper_list(any, binary | []) | char, binary | [])) :: :ok | [binary]
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

  @spec create_and_calculate_calls(any) :: :ok | [any]
  def create_and_calculate_calls(calls_parameters) do
    if Enum.empty?(calls_parameters) do
      IO.puts("The file has no calls")
    else
      calls_parameters
      |> Enum.map(&proccess_call_async/1)
      |> Enum.map(&Task.await/1)
    end
  end

  @spec proccess_call_async(any) :: Task.t()
  def proccess_call_async(call) do
    Task.async(fn ->
      call
      |> create_call()
      |> calculate_duration_and_cost_call()
    end)
  end

  @spec create_call(<<_::360>>) :: :ok | Calls.Call.t()
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

  @spec calculate_duration_and_cost_call(Calls.Call.t()) :: Calls.Call.t()
  def calculate_duration_and_cost_call(%Call{} = call) do
    call
    |> Call.calcutate_duration()
    |> Call.calculate_cost()
  end

  @spec disregard_longer_call(any) :: [Calls.Call.t()]
  def disregard_longer_call(calls) do
    calls
    |> Enum.sort_by(& &1.minutes_of_duration)
    |> Enum.drop(-1)
  end

  @spec calculate_total_cost_of_calls(any) :: number
  def calculate_total_cost_of_calls(calls) do
    calls
    |> Enum.map(& &1.total_cost)
    |> Enum.sum()
  end
end
