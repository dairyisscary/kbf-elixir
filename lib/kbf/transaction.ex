defmodule Kbf.Transaction do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Kbf.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    field :amount, :float
    field :description, :string
    field :when, :date

    timestamps()
  end

  def newer_than_n_days_ago(days) do
    from(t in Kbf.Transaction,
      select: ^default_select(),
      where: t.when >= ^days_ago(days) or is_nil(t.when)
    )
    |> Repo.all()
  end

  def happened_on_or_before_days_ago(transaction, days) do
    transaction.when >= days_ago(days)
  end

  def total_count() do
    from(t in Kbf.Transaction, select: count())
    |> Repo.one()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:description, :amount, :when])
    |> validate_required([:description, :amount])
  end

  def new() do
    %Kbf.Transaction{when: Date.utc_today()}
  end

  def create(attrs) do
    %Kbf.Transaction{}
    |> changeset(attrs)
    |> Repo.insert()
    |> broadcast(:transaction_created)
  end

  def update(%Kbf.Transaction{} = transaction, attrs) do
    transaction
    |> changeset(attrs)
    |> Repo.update()
    |> broadcast(:transaction_updated)
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(Kbf.PubSub, "transactions")
  end

  defp days_ago(days) do
    Date.utc_today() |> Date.add(-days)
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast({:ok, transaction} = success, event) do
    Phoenix.PubSub.broadcast(Kbf.PubSub, "transactions", {event, transaction})

    success
  end

  defp default_select() do
    [:id, :description, :when, :amount]
  end
end
