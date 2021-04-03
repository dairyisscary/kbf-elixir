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
      where: t.when >= ^days_ago(days) or is_nil(t.when)
    )
    |> Repo.all()
  end

  def total_count() do
    from(t in Kbf.Transaction, select: count(t.id))
    |> Repo.one()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:description, :amount, :when])
    |> validate_required([:description, :amount, :when])
  end

  defp days_ago(days) do
    Date.utc_today() |> Date.add(-days)
  end
end
