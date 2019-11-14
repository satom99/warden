defmodule Warden.Handler do
    @moduledoc """
    Defines a behaviour for identity handlers to implement.
    """
    alias Warden.Identity

    @doc """
    Called to verify a credential combo.

    Must return an `t:Warden.Identity.t/0` struct upon success.
    """
    @callback login(String.t, String.t) :: Identity.t | nil

    defmacro __using__(_options) do
        quote do
            @behaviour Warden.Handler

            alias Warden.Identity
        end
    end
end