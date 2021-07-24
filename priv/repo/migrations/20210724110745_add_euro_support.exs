defmodule Kbf.Repo.Migrations.AddEuroSupport do
  use Ecto.Migration
  alias Kbf.Transaction.Currency

  def up do
    Currency.create_type()

    alter table(:transactions) do
      add :currency, :currency
    end

    flush()

    Kbf.Repo.update_all(Kbf.Transaction, set: [currency: :usd])

    alter table(:transactions) do
      modify :currency, :currency, null: false
    end
  end

  def down do
    alter table(:transactions) do
      remove :currency
    end

    Currency.drop_type()
  end
end
