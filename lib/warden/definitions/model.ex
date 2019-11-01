defmodule Warden.Model do
    @moduledoc """
    Defines a behaviour for models to implement.
    """
    import Ecto.Query

    alias Ecto.Schema
    alias Ecto.Queryable
    alias Ecto.Changeset

    @doc """
    Function used to filter a queryable.
    """
    @callback filter(Queryable.t, Enumerable.t) :: Queryable.t

    @doc """
    Wrapper around `c:Ecto.Repo.all/2`.
    """
    @callback all(Queryable.t) :: [Schema.t]

    @doc """
    Wrapper around `c:Ecto.Repo.one/2`.
    """
    @callback one(Queryable.t) :: Schema.t | nil

    @doc """
    Wrapper around `c:Ecto.Repo.preload/3`.
    """
    @callback preload(struct, Keyword.t) :: struct

    @doc """
    Wrapper around `c:Ecto.Repo.update/2`.
    """
    @callback update(Changeset.t, map) :: tuple

    @doc """
    Wrapper around `c:Ecto.Repo.delete/2`.
    """
    @callback delete(Schema.t | Changeset.t) :: tuple

    @optional_callbacks [filter: 2, all: 1, one: 1, preload: 2, update: 2, delete: 1]

    defmacro __using__(_options) do
        quote do
            @behaviour Warden.Model

            use Ecto.Schema

            def filter(object, params) do
                fields = __schema__(:fields)

                params = params
                |> Map.new
                |> Map.take(fields)
                |> Keyword.new

                where(object, ^params)
            end            
            defoverridable [filter: 2]
        end
    end
end