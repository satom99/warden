defmodule Warden.Identity do
    @moduledoc """
    Provides authentication functionality as a *plug*.

    Defines a behaviour for identity handlers to implement.
    """
    @behaviour Plug

    use Warden.Resolver

    import Plug.Conn
    import Phoenix.Controller

    alias Absinthe.Plug
    alias Warden.Token
    alias __MODULE__

    defstruct [
        :id,
        :handler,
        :title,
        :name,
        :email,
        :phone,
        roles: [],
        admin?: false,
        guest?: true,
    ]
    @type t :: %Identity{
        id: term,
        handler: module,
        title: String.t,
        name: String.t,
        email: String.t,
        phone: String.t,
        roles: [String.t],
        admin?: boolean,
        guest?: boolean
    }

    @doc false
    def init(options) do
        options
    end

    @doc """
    Updates Absinthe's context with a `t:t/0` struct.

    In case a valid token is provided, the attached struct is used. \\
    If otherwise, an empty struct with default values is used instead.
    """
    def call(conn, _options) do
        endpoint = endpoint_module(conn)

        token = conn
        |> get_req_header("authorization")
        |> Enum.at(0, "")
        |> String.split(" ")
        |> List.last

        identity = endpoint
        |> Token.verify(token)
        || %Identity{}

        context = %{
            identity: identity,
            endpoint: endpoint
        }
        options = [context: context]
        Plug.put_options(conn, options)
    end

    @doc """
    Resolver responsible for handling credential validation.

    Returns an object with a `token` field upon success.
    """
    def login(params, resolution) do
        with %{identity: module} <- params,
                %{username: username} <- params,
                %{password: password} <- params,
                %{context: context} <- resolution,
                %{endpoint: endpoint} <- context,
                identity = %Identity{} <- module.login(username, password),
                identity = %{identity | handler: module, guest?: false},
                token = Token.sign(endpoint, identity),
                object = %{token: token}
        do
            {:ok, object}
        else
            _error -> {:error, "invalid credentials"}
        end
    end

    @doc """
    Resolver responsible for displaying stored identity data.

    Returns an `t:t/0` struct when identified.
    """
    def show(_params, resolution) do
        with %{context: context} <- resolution,
                %{identity: identity} <- context,
                %Identity{guest?: false} <- identity
        do
            {:ok, identity}
        else
            _error -> {:error, "not identified"}
        end
    end

    @doc false
    def can?(_identity, _action, _params) do
        true
    end

    @doc """
    Called to verify a credential combo.

    Must return a `t:t/0` struct upon success.
    """
    @callback login(String.t, String.t) :: t | term

    defmacro __using__(_options) do
        quote do
            @behaviour Warden.Identity

            alias Warden.Identity
        end
    end
end