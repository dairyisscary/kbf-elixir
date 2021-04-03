defmodule Kbf.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :text, null: false
      add :amount, :float, null: false
      add :when, :date

      timestamps()
    end

    create index(:transactions, [:when])
  end
end
