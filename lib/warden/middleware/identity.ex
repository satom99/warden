defmodule Warden.Identity do
    @moduledoc """
    Provides authentication functionality as a plug.
    """
    use Warden.Plug
    use Warden.Resolver

    alias Warden.Prover
    alias __MODULE__

    defstruct [
        :id,
        :name,
        :email,
        :phone,
        :title,
        :handler,
        roles: [],
        admin?: false,
        guest?: true
    ]
    @type t :: %Identity{
        id: term,
        name: String.t,
        email: String.t,
        phone: String.t,
        title: String.t,
        handler: module,
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
    """
    def call(conn, _options) do
        token = conn
        |> get_req_header("authorization")
        |> Enum.at(0, "")
        |> String.split
        |> List.last

        identity = conn
        |> Prover.verify(token)
        || %Identity{}

        context = %{identity: identity}
        options = [context: context]
        Plug.put_options(conn, options)
    end

    @doc """
    Checks whether a given identity has admin perms.
    """
    @spec is_admin?(Identity.t) :: boolean

    def is_admin?(%Identity{admin?: admin?}) do
        admin?
    end

    @doc """
    Resolver responsible for handling credential validation.

    Returns a map with a `token` field upon success.
    """
    def login(params, resolution) do
        with %{handler: handler} <- params,
             %{username: username} <- params,
             %{password: password} <- params,
             identity = %Identity{} <- handler.login(username, password),
             identity = %{identity | handler: handler, guest?: false},
             token = Prover.sign(resolution, identity),
             object = %{token: token}
        do
            {:ok, object}
        else
            _term -> {:error, "invalid credentials"}
        end
    end

    @doc """
    Resolver that displays the stored identity.
    """
    def show(_params, resolution) do
        with %{context: context} <- resolution,
             %{identity: identity} <- context,
             %Identity{guest?: false} <- identity
        do
            {:ok, identity}
        else
            _term -> {:error, "not identified"}
        end
    end

    @doc false
    def can?(_identity, _action, _params) do
        true
    end
end