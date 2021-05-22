defmodule Kbf.Calendar do
  def days_ago(days) do
    Date.utc_today() |> Date.add(-days)
  end

  def parse_date(possible_date, default \\ nil)

  def parse_date(nil, default), do: default

  def parse_date(possible_date, default) do
    case Date.from_iso8601(possible_date) do
      {:ok, parsed_date} ->
        parsed_date

      _ ->
        default
    end
  end
end
