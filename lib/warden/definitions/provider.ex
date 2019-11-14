defmodule Warden.Provider do
    @moduledoc """
    Defines a behaviour for providers to implement.
    """
    import Warden.Helper

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

    @doc false
    def sign(context, identity) do
        options = config(context)
        provider = provider(context)
        provider.sign(identity, options)
    end

    @doc false
    def verify(context, token) do
        options = config(context)
        provider = provider(context)
        provider.verify(token, options)
    end

    @doc false
    def store(context, key, value, ttl) do
        provider = provider(context)
        provider.store(key, value, ttl)
    end

    @doc false
    def fetch(context, key) do
        provider = provider(context)
        provider.store(key)
    end
end