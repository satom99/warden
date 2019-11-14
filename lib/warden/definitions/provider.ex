defmodule Warden.Provider do
    @moduledoc """
    Defines a behaviour for providers to implement.
    """
    alias Warden.Identity

    @doc """
    Issues a new token for a given identity.
    """
    @callback sign(Identity.t, Keyword.t) :: String.t

    @doc """
    Verifies a previously issued token.
    """
    @callback verify(String.t, Keyword.t) :: Identity.t | nil

    @doc """
    Stores a given term under a specific key.
    """
    @callback store(String.t, term, pos_integer) :: any

    @doc """
    Fetches a previously stored term under a given key.
    """
    @callback fetch(String.t) :: any

    @optional_callbacks [sign: 2, verify: 2, store: 3, fetch: 1]

    defmacro __using__(_options) do
        quote do
            @behaviour Warden.Provider

            alias Warden.Identity
        end
    end
end