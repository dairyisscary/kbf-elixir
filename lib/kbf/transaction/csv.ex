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
      with {:ok, date_when} <- marshal_date(parsed_row),
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
    |> Stream.filter(fn params ->
      !exclude_credits || params["amount"] < 0
    end)
    |> Enum.to_list()
    |> Kbf.Transaction.create_many_with_dedupe()
  end

  defp process_csv(error), do: error

  defp marshal_date(%{"Date" => raw_date}), do: Date.from_iso8601(raw_date)

  defp marshal_date(%{"Transaction Date" => raw_date}) do
    raw_date
    |> String.split("/")
    |> case do
      [month, day, year] ->
        Date.from_iso8601("#{year}-#{month}-#{day}")

      _ ->
        {:error, "Could not parse #{raw_date}"}
    end
  end

  defp marshal_description(%{} = row) do
    {:ok, row["Description"] || row["Merchant Name"]}
  end

  defp marshal_amount(%{"Amount" => raw_amount}, invert_amount) do
    raw_amount
    |> String.replace("$", "")
    |> Float.parse()
    |> case do
      {amount, _} ->
        {:ok, if(invert_amount, do: amount * -1, else: amount)}

      :error ->
        {:error, "Could not parse #{raw_amount}"}
    end
  end

  defp flat_map_oks(stream) do
    Stream.flat_map(stream, fn
      {:ok, value} ->
        [value]

      _ ->
        []
    end)
  end
end
