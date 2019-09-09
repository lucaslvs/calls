defmodule Calls.Call do
  alias __MODULE__

  @enforce_keys [:time_of_start, :time_of_finish, :call_from, :call_to] ++ [:minutes_of_duration, :total_cost]

  defstruct @enforce_keys

  def new(params) when is_list(params) or is_map(params) do
    case parse_params(params) do
      {:error, :invalid_call} ->
        {:error, :invalid_call}
      params ->
        {:ok, struct(Call, params)}
    end
  end

  def new(_params), do: {:error, :invalid_call}

  def calcutate_duration(%Call{time_of_start: time_of_start, time_of_finish: time_of_finish} = call) do
    time_of_duration =
      time_of_finish
      |> Time.diff(time_of_start)
      |> convert_to_minutes()

    %Call{call | minutes_of_duration: time_of_duration}
  end

  def calculate_cost(%Call{minutes_of_duration: minutes_of_duration} = call) do
    %Call{call | total_cost: cost_by_minute(minutes_of_duration)}
  end

  defp cost_by_minute(minute) when minute <= 5, do: Float.floor(minute * 0.05, 2)

  defp cost_by_minute(minute), do: Float.floor(0.25 + ((minute - 5) * 0.02), 2)

  defp parse_params(params) do
    try do
      {:ok, time_of_start} = Time.from_iso8601(params[:time_of_start])
      {:ok, time_of_finish} = Time.from_iso8601(params[:time_of_finish])

      params = put_in(params[:time_of_start], time_of_start)

      put_in(params[:time_of_finish], time_of_finish)
    catch
      _ -> {:error, :invalid_call}
    end
  end

  defp convert_to_minutes(seconds), do: Float.floor(seconds / 60, 2) |> trunc()
end
