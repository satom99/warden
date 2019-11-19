defmodule Warden.Cache do
    @moduledoc """
    Provides caching functionality as a middleware.
    """
    use Warden.Middleware

    alias Absinthe.Middleware.Async
    alias Absinthe.Middleware.Dataloader
    alias Warden.Provider

    @space "cache:"

    @doc """
    Injects the middleware right before resolution.
    """
    @spec inject(list) :: list

    def inject(middleware) do
        Pipeline.insert_before(middleware, @resolution, __MODULE__)
    end

    @doc false
    def call(%{state: :unresolved} = resolution, _options) do
        options = options(resolution)

        function = resolution
        |> Map.get(:middleware)
        |> Pipeline.from(@resolution)
        |> List.first
        |> elem(1)

        handler = fn _params, _resolution ->
            perform(resolution, function, options)
        end
        Resolution.call(resolution, handler)
    end
    def call(resolution, _options) do
        resolution
    end

    defp perform(resolution, function, %{max_age: max_age} = options) do
        name = name(resolution, function, options)
        case Provider.fetch(resolution, name) do
            {:ok, tuple} when is_tuple(tuple) ->
                tuple
            _other ->
                function
                |> execute(resolution)
                |> cache(resolution, name, max_age)
        end
    end
    defp perform(resolution, function, _options) do
        execute(function, resolution)
    end

    defp cache({:ok, _term} = tuple, resolution, name, max_age) do
        Provider.store(resolution, name, tuple, max_age)
        tuple
    end
    defp cache({:middleware, Async = middleware, {function, options}}, resolution, name, max_age) do
        handler = fn ->
            cache(function.(), resolution, name, max_age)
        end
        {:middleware, middleware, {handler, options}}
    end
    defp cache({:middleware, Dataloader = middleware, {loader, function}}, resolution, name, max_age) do
        handler = fn loader ->
            loader
            |> function.()
            |> cache(resolution, name, max_age)
        end
        {:middleware, middleware, {loader, handler}}
    end
    defp cache(tuple, _resolution, _name, _max_age) do
        tuple
    end

    defp execute(function, %{source: source, arguments: params} = resolution) do
        case function do
            function when is_function(function, 2) ->
                function.(params, resolution)
            function when is_function(function, 3) ->
                function.(source, params, resolution)
            {module, function} ->
                apply(module, function, [source, params, resolution])
        end
    end

    defp name(resolution, function, options) do
        parent = resolution.source
        params = resolution.arguments
        viewer = if options[:private] do
            resolution.context.identity.id
        end
        object = [function, parent, params, viewer]
        binary = :erlang.term_to_binary(object)
        crypto = :crypto.hash(:md5, binary)
        string = Base.encode16(crypto)
        @space <> string
    end

    defp options(resolution) do
        name = resolution
        |> Map.get(:definition)
        |> Map.get(:schema_node)
        |> Map.get(:identifier)

        resolution
        |> config(:cache, %{})
        |> Map.new
        |> Map.get(name, %{})
        |> Map.new
    end
end