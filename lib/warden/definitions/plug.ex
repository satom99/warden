defmodule Warden.Plug do
    @moduledoc """
    Defines a behaviour for plugs to implement.
    """
    defmacro __using__(_options) do
        quote do
            @behaviour Plug

            import Plug.Conn
            import Warden.Helper

            alias Absinthe.Plug
            alias Warden.Provider
        end
    end
end