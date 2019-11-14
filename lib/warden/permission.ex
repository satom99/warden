defmodule Warden.Permission do
    @moduledoc """
    Provides authorization functionality as a *middleware*.
    """
    use Warden.Middleware

    alias Absinthe.Resolution
    alias Absinthe.Pipeline
    alias Warden.Identity

    @resolution {Resolution, :call}

    @doc """
    Injects the middleware right before resolution.
    """
    @spec inject(list) :: list

    def inject(middleware) do
        Pipeline.insert_before(middleware, @resolution, __MODULE__)
    end

    @doc false
    def call(resolution, _options) do
        with %{middleware: middleware} <- resolution,
             %{arguments: arguments} <- resolution,
             %{context: context} <- resolution,
             %{identity: identity} <- context,
             resolver = get_resolver(middleware),
             %{module: module} <- resolver,
             %{name: action} <- resolver,
             true <- can?(identity, module, action, arguments)
        do
            resolution
        else
            _error -> Resolution.put_result(resolution, {:error, "forbidden"})
        end
    end

    @doc """
    Checks whether a given identity has admin perms.
    """
    @spec is_admin?(Identity.t) :: boolean

    def is_admin?(%Identity{admin?: admin?}) do
        admin?
    end

    defp can?(identity, module, action, params) do
        cond do
            is_admin?(identity) ->
                true
            not exports?(module, :can?, 3) ->
                false
            true ->
                module.can?(identity, action, params)
        end
    end

    defp exports?(module, function, arity) do
        with true <- Code.ensure_loaded?(module) do
            function_exported?(module, function, arity)
        end
    end

    defp get_resolver(middleware) do
        middleware
        |> Pipeline.from(@resolution)
        |> Enum.at(0, {:none, & &1})
        |> Kernel.elem(1)
        |> Function.info
        |> Map.new
    end
end