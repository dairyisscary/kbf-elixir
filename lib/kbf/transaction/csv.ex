defmodule Kbf.Transaction.CSV do
  import Ecto.Changeset

  @struct_types %{
    csv_content: :string,
    currency: Kbf.Transaction.Currency,
    invert_amount: :boolean,
    exclude_credits: :boolean,
    categories: {:array, :map}
  }

  defstruct [
    :csv_content,
    :currency,
    invert_amount: false,
    exclude_credits: true,
    categories: []
  ]

  def import_from_csv(params) do
    params
    |> empty_changeset()
    |> apply_action(:process)
    |> process_csv()
  end

  def empty_changeset(params) do
    {%Kbf.Transaction.CSV{}, @struct_types}
    |> cast(params, [:csv_content, :currency, :invert_amount, :exclude_credits, :categories])
    |> validate_required([:csv_content, :currency])
  end

  defp process_csv({:ok, csv_options}) do
    %Kbf.Transaction.CSV{
      invert_amount: invert_amount,
      currency: currency,
      exclude_credits: exclude_credits,
      categories: categories,
      csv_content: csv_content
    } = csv_options

    csv_content
    |> String.split("\n")
    |> CSV.decode(headers: true)
    |> flat_map_oks()
    |> Stream.map(fn parsed_row ->
      with {:ok, date_when} <- marshal_date(parsed_row, currency),
           {:ok, amount} <- marshal_amount(parsed_row, invert_amount),
           {:ok, description} <- marshal_description(parsed_row) do
        {:ok,
         %{
           "when" => date_when,
           "description" => description,
           "amount" => amount,
           "currency" => currency,
           "categories" => categories
         }}
      end
    end)
    |> flat_map_oks()
    |> filter_credits(exclude_credits)
    |> Enum.to_list()
    |> Kbf.Transaction.create_many_with_dedupe()
  end

  defp process_csv(error), do: error

  # Wise Euro/USD, Legacy TD, and Bunq
  defp marshal_date(%{"Date" => raw_date}, _currency) do
    # Wise always uses a matching non-ISO date in euro, so thats why we hardcode :euro as currency.
    # Legacy TD and bunq is just ISO.
    marshal_non_iso_date_if_matches(raw_date, "-", :euro, ~r/-[[:digit:]]{4}$/)
  end

  # TD and Chase
  defp marshal_date(%{"Transaction Date" => raw_date}, :usd) do
    marshal_non_iso_date_if_matches(raw_date, "/", :usd, ~r/^[[:digit:]]{2}\//)
  end

  defp marshal_non_iso_date(raw_date, char, currency) do
    case {String.split(raw_date, char), currency} do
      {[month, day, year], :usd} ->
        Date.from_iso8601("#{year}-#{month}-#{day}")

      {[day, month, year], :euro} ->
        Date.from_iso8601("#{year}-#{month}-#{day}")

      _ ->
        {:error, "Could not parse #{raw_date}"}
    end
  end

  defp marshal_non_iso_date_if_matches(raw_date, char, currency, regex) do
    if String.match?(raw_date, regex) do
      marshal_non_iso_date(raw_date, char, currency)
    else
      Date.from_iso8601(raw_date)
    end
  end

  defp marshal_description(%{} = row) do
    # Chase and Wise are Description, TD is Merchant Name
    # Bunq has both Description and Name, so Name is higher presedence
    value = row["Name"] || row["Description"] || row["Merchant Name"]

    if value, do: {:ok, value}, else: {:error, "could not find description"}
  end

  defp marshal_amount(%{"Amount" => raw_amount}, invert_amount) do
    raw_amount
    |> String.replace(["$", ",", "€"], "")
    |> Float.parse()
    |> case do
      {amount, _} ->
        {:ok, if(invert_amount, do: amount * -1, else: amount)}

      :error ->
        {:error, "Could not parse #{raw_amount}"}
    end
  end

  defp filter_credits(stream, true) do
    stream |> Stream.filter(fn params -> params["amount"] < 0 end)
  end

  defp filter_credits(stream, _exclude_credits), do: stream

  defp flat_map_oks(stream) do
    Stream.flat_map(stream, fn
      {:ok, value} ->
        [value]

      _ ->
        []
    end)
  end
end
