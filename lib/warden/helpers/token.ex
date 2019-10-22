defmodule Warden.Token do
    @moduledoc """
    Delegates token validation to the configured provider.
    """
    alias Phoenix.Endpoint
    alias Warden.Identity

    @doc """
    Delegates to `c:Warden.Provider.sign/2`.
    """
    @spec sign(Endpoint.t, Identity.t) :: term

    def sign(endpoint, identity) do
        execute(:sign, endpoint, identity)
    end

    @doc """
    Delegates to `c:Warden.Provider.verify/2`. 
    """
    @spec verify(Endpoint.t, String.t) :: term

    def verify(endpoint, token) do
        execute(:verify, endpoint, token)
    end

    defp execute(function, endpoint, argument) do
        options = endpoint
        |> :ets.tab2list
        |> Enum.filter(&tuple_size(&1) == 2)

        arguments = [argument, options]

        options
        |> Keyword.fetch!(:provider)
        |> apply(function, arguments)
    end
end