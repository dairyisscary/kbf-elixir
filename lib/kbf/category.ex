defmodule Kbf.Category do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Kbf.Repo

  @uncategorized_id "uncategorized"
  @default_select [:id, :name, :color_code, :ignored_for_breakdown_reporting]
  @max_color_code 11

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "categories" do
    field :name, :string
    field :color_code, :integer, default: 0
    field :ignored_for_breakdown_reporting, :boolean, default: false
    field :transaction_count, :integer, virtual: true

    timestamps()
  end

  def uncategorized(attrs \\ %{}) do
    %Kbf.Category{
      id: @uncategorized_id,
      name: "Uncategorized",
      color_code: -1,
      ignored_for_breakdown_reporting: false
    }
    |> Map.merge(attrs)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :color_code, :ignored_for_breakdown_reporting])
    |> validate_required([:name, :color_code])
    |> validate_number(:color_code,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: @max_color_code
    )
    |> unique_constraint(:name)
  end

  def color_code_range(), do: 0..@max_color_code

  def all_by_name_preload() do
    from(c in Kbf.Category, select: ^@default_select, order_by: c.name)
  end

  def all_by_name() do
    all_by_name_preload()
    |> Repo.all()
  end

  def all_with_counts() do
    categories =
      from(c in Kbf.Category, select: ^@default_select)
      |> Repo.all()

    transaction_counts = counts_of_transactions()

    categories
    |> Enum.map(fn category ->
      category
      |> Map.put(:transaction_count, Map.get(transaction_counts, category.id, 0))
    end)
  end

  def create(attrs) do
    %Kbf.Category{}
    |> changeset(attrs)
    |> Repo.insert()
    |> broadcast(:category_created)
  end

  def update(%Kbf.Category{} = category, attrs) do
    category
    |> changeset(attrs)
    |> Repo.update()
    |> broadcast(:category_updated)
  end

  def delete(%Kbf.Category{} = category) do
    category
    |> Repo.delete()
    |> broadcast(:category_deleted)
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(Kbf.PubSub, "categories")
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast({:ok, category} = success, event) do
    Phoenix.PubSub.broadcast(Kbf.PubSub, "categories", {event, category})

    success
  end

  def counts_of_transactions() do
    from(j in "categories_transactions", select: {j.category_id, count()}, group_by: :category_id)
    |> Repo.all()
    |> Enum.into(%{}, fn {raw_id, count} -> {Ecto.UUID.cast!(raw_id), count} end)
  end
end
