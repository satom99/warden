defmodule Warden.Resolver do
    @moduledoc """
    Defines a behaviour for resolvers to implement.
    """
    alias Warden.Identity

    @doc """
    Called from `Warden.Permission` to determine
    whether a given identity has enough permissions.
    """
    @callback can?(Identity.t, atom, map) :: boolean
    
    @optional_callbacks [can?: 3]

    defmacro __using__(_options) do
        quote do
            @behaviour Warden.Resolver

            alias Warden.{Identity, Ability}
        end
    end
end