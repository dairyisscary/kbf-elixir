defmodule Kbf.Repo.Migrations.AddReportingIgnoreCategory do
  use Ecto.Migration

  def up do
    alter table(:categories) do
      add :ignored_for_breakdown_reporting, :boolean
    end

    flush()

    Kbf.Repo.update_all(Kbf.Category, set: [ignored_for_breakdown_reporting: false])

    alter table(:categories) do
      modify :ignored_for_breakdown_reporting, :boolean, null: false, default: false
    end
  end

  def down do
    alter table(:categories) do
      remove :ignored_for_breakdown_reporting
    end
  end
end
