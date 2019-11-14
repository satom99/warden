defmodule Warden do
    @moduledoc """
    Plug that serves as an entry point for *Warden*.
    """
    use Warden.Plug

    alias Absinthe.Plug

    @doc false
    def init(options) do
        options
    end

    @doc false
    def call(conn, _options) do
        endpoint = endpoint(conn)
        context = %{endpoint: endpoint}
        options = [context: context]
        Plug.put_options(conn, options)
    end
end