defmodule Warden.Cache do
    @moduledoc """
    Provides caching functionality as a middleware.
    """
    use Warden.Middleware

    alias Absinthe.Middleware.Async
    alias Absinthe.Middleware.Dataloader

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

    defp perform(resolution, function, options) when is_list(options) do
        name = name(resolution, function, options)
        case Provider.fetch(resolution, name) do
            {:ok, tuple, ttl} when ttl > 0 ->
                options
                |> Keyword.put(:max_age, ttl)
                |> dictionary

                tuple
            _other ->
                function
                |> execute(resolution)
                |> cache(resolution, name, options)
        end
    end
    defp perform(resolution, function, _options) do
        dictionary([max_age: nil])
        execute(function, resolution)
    end

    defp cache({:ok, _term} = tuple, resolution, name, options) do
        max_age = Keyword.fetch!(options, :max_age)
        Provider.store(resolution, name, tuple, max_age)
        dictionary(options)
        tuple
    end
    defp cache({:middleware, Async = middleware, {function, options}}, resolution, name, options) do
        handler = fn ->
            cache(function.(), resolution, name, options)
        end
        {:middleware, middleware, {handler, options}}
    end
    defp cache({:middleware, Dataloader = middleware, {loader, function}}, resolution, name, options) do
        handler = fn loader ->
            loader
            |> function.()
            |> cache(resolution, name, options)
        end
        {:middleware, middleware, {loader, handler}}
    end
    defp cache(tuple, _resolution, _name, _options) do
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
        |> config(:cache, [])
        |> Keyword.get(name)
    end

    defp dictionary(options) do
        max_age = Keyword.get(options, :max_age)
        private = Keyword.get(options, :private, false)

        max_age = :cache_ttl
        |> Process.get
        |> min(max_age)

        private = :cache_private
        |> Process.get(private)
        |> Kernel.or(private)

        Process.put(:cache_ttl, max_age)
        Process.put(:cache_private, private)
    end
end