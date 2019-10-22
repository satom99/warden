defmodule Warden.Middleware do
    @moduledoc """
    Defines a behaviour for middlewares to implement.
    """
    alias Absinthe.Middleware

    @doc """
    Called to insert the middleware into a list.
    """
    @callback inject([Middleware.t]) :: [Middleware.t]

    defmacro __using__(_options) do
        quote do
            @behaviour Absinthe.Middleware
            @behaviour Warden.Middleware
        end
    end
end