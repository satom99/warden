defmodule Warden.Helper do
    @moduledoc false

    alias Plug.Conn
    alias Phoenix.Controller
    alias Absinthe.Resolution

    def provider(context) do
        config(context, :provider)
    end

    def endpoint(%Conn{} = conn) do
        Controller.endpoint_module(conn)
    end

    def config(%Conn{} = conn) do
        conn
        |> endpoint
        |> config
    end
    def config(%Resolution{} = resolution) do
        resolution
        |> Map.get(:context)
        |> Map.get(:endpoint)
        |> config
    end
    def config(endpoint) when is_atom(endpoint) do
        endpoint
        |> :ets.tab2list
        |> Enum.filter(&tuple_size(&1) == 2)
    end
    def config(context, name) do
        context
        |> config
        |> Keyword.fetch!(name)
    end
    def config(context, name, default) do
        context
        |> config
        |> Keyword.get(name, default)
    end
end