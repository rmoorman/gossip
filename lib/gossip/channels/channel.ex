defmodule Gossip.Channels.Channel do
  @moduledoc """
  Channel schema
  """

  use Gossip.Schema

  alias Gossip.Channels

  schema "channels" do
    field(:name, :string)
    field(:description, :string)
    field(:hidden, :boolean, default: true)

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:name, :description])
    |> validate_required([:name])
    |> validate_format(:name, ~r/^[a-zA-Z]+$/)
    |> validate_length(:name, max: 15)
    |> check_name_against_block_list()
    |> unique_constraint(:name)
  end

  defp check_name_against_block_list(changeset) do
    case get_change(changeset, :name) do
      nil ->
        changeset

      name ->
        case Enum.member?(Channels.name_blocklist(), String.downcase(name)) do
          true ->
            add_error(changeset, :name, "is blocked")

          false ->
            changeset
        end
    end
  end
end
