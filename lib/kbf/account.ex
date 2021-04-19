defmodule Kbf.Account do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Kbf.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :username, :string
    field :password_hash, :string
    field :password, :string, virtual: true
  end

  def login_changeset(attrs) do
    %Kbf.Account{}
    |> cast(attrs, [:username, :password])
    |> validate_required([:username, :password])
  end

  def verify_login(%{"password" => password} = params) do
    params
    |> get_by_username()
    |> Pbkdf2.check_pass(password)
  end

  defp get_by_username(%{"username" => username} = _params) do
    from(a in Kbf.Account, where: a.username == ^username)
    |> Repo.one()
  end
end
