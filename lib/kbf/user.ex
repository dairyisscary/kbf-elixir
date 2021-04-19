defmodule Kbf.User do
  use Ecto.Schema
  alias Kbf.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :first_name, :string
    field :last_name, :string
  end

  def get!(id), do: Repo.get!(Kbf.User, id)
end
