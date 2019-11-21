defmodule Warden.Middleware do
    @moduledoc """
    Defines a behaviour for middlewares to implement.
    """
    alias Absinthe.Middleware

    @doc """
    Convenience function used to inject the middleware
    from the `c:Absinthe.Schema.middleware/3` callback.
    """
    @callback inject([Middleware.t]) :: [Middleware.t]

    defmacro __using__(_options) do
        quote do
            @behaviour Absinthe.Middleware
            @behaviour Warden.Middleware

            import Warden.Helper

            alias Absinthe.Pipeline
            alias Absinthe.Resolution
            alias Warden.Provider

            @resolution {Resolution, :call}
        end
    end
end