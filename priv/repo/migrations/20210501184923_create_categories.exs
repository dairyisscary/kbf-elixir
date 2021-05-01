defmodule Kbf.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :color_code, :integer, null: false

      timestamps()
    end

    create unique_index(:categories, [:name])

    create table(:categories_transactions, primary_key: false) do
      add(:category_id, references(:categories, on_delete: :delete_all, type: :binary_id),
        null: false
      )

      add(:transaction_id, references(:transactions, on_delete: :delete_all, type: :binary_id),
        null: false
      )
    end

    create index(:categories_transactions, [:category_id])
    create index(:categories_transactions, [:transaction_id])
  end
end
