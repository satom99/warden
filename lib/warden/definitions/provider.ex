defmodule Warden.Provider do
    @moduledoc """
    Defines a behaviour for token providers to implement.
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

    defmacro __using__(_options) do
        quote do
            @behaviour Warden.Provider

            alias Warden.Identity
        end
    end
end