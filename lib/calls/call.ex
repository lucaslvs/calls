defmodule Calls.Call do
  alias __MODULE__

  @enforce_keys [:time_of_start, :time_of_finish, :call_from, :call_to]
  @keys [:minutes_of_duration, :total_cost]

  defstruct @enforce_keys ++ @keys

  def new(parameters) when is_list(parameters) or is_map(parameters) do
    case parse_parameters(parameters) do
      {:ok, parameters} ->
        {:ok, struct(Call, parameters)}

      {:error, :invalid_call} ->
        {:error, :invalid_call}
    end
  end

  def new(_parameters), do: {:error, :invalid_call}

  def calcutate_duration(%Call{} = call) do
    time_of_duration =
      call.time_of_finish
      |> Time.diff(call.time_of_start)
      |> convert_to_minutes()

    %Call{call | minutes_of_duration: time_of_duration}
  end

  def calculate_cost(%Call{minutes_of_duration: minutes_of_duration} = call) do
    %Call{call | total_cost: cost_by_minute(minutes_of_duration)}
  end

  defp parse_parameters(parameters) do
    try do
      {:ok, time_of_start} = Time.from_iso8601(parameters[:time_of_start])
      {:ok, time_of_finish} = Time.from_iso8601(parameters[:time_of_finish])

      parameters = put_in(parameters[:time_of_start], time_of_start)
      parameters = put_in(parameters[:time_of_finish], time_of_finish)

      {:ok, parameters}
    catch
      _ -> {:error, :invalid_call}
    end
  end

  defp convert_to_minutes(seconds), do: Float.floor(seconds / 60, 2) |> trunc()

  defp cost_by_minute(minute) when minute <= 5, do: Float.floor(minute * 0.05, 2)

  defp cost_by_minute(minute), do: Float.floor(0.25 + (minute - 5) * 0.02, 2)
end
