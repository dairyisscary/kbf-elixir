defmodule Kbf.Transaction do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Kbf.Repo
  alias Ecto.Multi

  @default_select [:id, :description, :when, :amount, :currency]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    field :amount, :float
    field :currency, Kbf.Transaction.Currency
    field :description, :string
    field :when, :date

    many_to_many :categories, Kbf.Category,
      join_through: "categories_transactions",
      on_replace: :delete

    timestamps()
  end

  def from_filters(%{} = filters) do
    from(t in Kbf.Transaction,
      select: ^@default_select,
      preload: [categories: ^Kbf.Category.all_by_name_preload()],
      where: ^build_query_where_filters(filters),
      or_where: is_nil(t.when)
    )
    |> Repo.all()
    |> category_filter(filters[:categories])
  end

  def matches_filters(transaction, filters) do
    Enum.all?(filters, fn
      {:after, %Date{} = after_date} ->
        transaction.when >= after_date

      {:before, %Date{} = before_date} ->
        transaction.when <= before_date

      {:categories, %{} = categories} ->
        !Enum.empty?(category_filter([transaction], categories))

      _ ->
        true
    end)
  end

  def total_count() do
    from(t in Kbf.Transaction, select: count())
    |> Repo.one()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:description, :amount, :currency, :when])
    |> validate_required([:description, :amount, :currency])
    |> put_assoc(:categories, attrs["categories"])
  end

  def new() do
    %Kbf.Transaction{when: Date.utc_today(), categories: []}
  end

  def create(attrs) do
    %Kbf.Transaction{}
    |> changeset(attrs)
    |> Repo.insert()
    |> broadcast(:transaction_created)
  end

  def create_many_with_dedupe(all_attrs) when is_list(all_attrs) do
    changesets =
      all_attrs
      |> Enum.map(fn attrs -> changeset(%Kbf.Transaction{}, attrs) end)

    Multi.new()
    |> Multi.run(:dedupe, fn repo, _multi ->
      root_query =
        from(t in Kbf.Transaction,
          select: [:id, :when, :amount, :currency, :inserted_at]
        )

      dupes =
        changesets
        |> Enum.reduce(root_query, fn changeset, query ->
          %{when: w, amount: a, currency: c} = changeset.changes

          from(t in query, or_where: t.when == ^w and t.amount == ^a and t.currency == ^c)
        end)
        |> repo.all()

      deduped_changesets =
        changesets
        |> Enum.map(fn changeset ->
          %{when: w, amount: a, currency: c} = changeset.changes

          {changeset, Enum.find(dupes, &(&1.when == w && &1.amount == a && &1.currency == c))}
        end)

      {:ok, deduped_changesets}
    end)
    |> Multi.run(:inserted_transactions, fn repo, %{dedupe: dedupe} ->
      dedupe
      |> Enum.filter(fn {_changeset, dupe} -> !dupe end)
      |> Enum.reduce({:ok, []}, fn {changeset, _dupe}, {_, transactions_so_far} ->
        with {:ok, transaction} <- repo.insert(changeset) do
          {:ok, [transaction | transactions_so_far]}
        end
      end)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{inserted_transactions: transactions, dedupe: dedupe}} ->
        suspect_duplicates =
          dedupe
          |> Enum.filter(fn {_cs, dupe} -> dupe end)

        {:ok, %{inserted_transactions: transactions, suspect_duplicates: suspect_duplicates}}

      error ->
        error
    end
    |> broadcast(:transaction_created)
  end

  def update(%Kbf.Transaction{} = transaction, attrs) do
    transaction
    |> changeset(attrs)
    |> Repo.update()
    |> broadcast(:transaction_updated)
  end

  def delete(%Kbf.Transaction{} = transaction) do
    transaction
    |> Repo.delete()
    |> broadcast(:transaction_deleted)
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(Kbf.PubSub, "transactions")
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast({:ok, %{inserted_transactions: transactions} = multi}, event) do
    {Enum.each(transactions, &broadcast({:ok, &1}, event)), multi}
  end

  defp broadcast({:ok, transaction} = success, event) do
    Phoenix.PubSub.broadcast(Kbf.PubSub, "transactions", {event, transaction})

    success
  end

  defp build_query_where_filters(filters) do
    Enum.reduce(filters, dynamic(true), &get_where_from_pair/2)
  end

  defp get_where_from_pair({:before, %Date{} = before_date}, dynamic) do
    dynamic([t], ^dynamic and t.when <= ^before_date)
  end

  defp get_where_from_pair({:after, %Date{} = after_date}, dynamic) do
    dynamic([t], ^dynamic and t.when >= ^after_date)
  end

  defp get_where_from_pair(_, dynamic), do: dynamic

  defp category_filter(transactions, nil), do: transactions

  defp category_filter(transactions, %{} = category_ids) do
    desired_category_ids =
      category_ids
      |> Enum.filter(fn {_id, desired} -> desired end)
      |> Enum.map(fn {id, _desired} -> id end)

    Enum.filter(transactions, fn transaction ->
      Enum.all?(desired_category_ids, fn desired_id ->
        Enum.any?(transaction.categories, fn category -> category.id == desired_id end)
      end)
    end)
  end
end
