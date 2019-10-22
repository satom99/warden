defmodule Warden.Loader do
    @moduledoc """
    Implements multiple resource loading helpers.

    Serves as a mix between `Dataloader` and direct querying.
    """
    import Ecto.Query
    import Absinthe.Resolution.Helpers
    import Absinthe.Relay.Connection, except: [
        limit: 2,
        offset: 2
    ]

    alias Absinthe.Resolution
    alias Dataloader.Source
    alias Warden.{Model, Ability}
    alias Warden.Permission

    @doc """
    Updates Absinthe's context with the given source.
    """
    @spec add_source(map, atom, Source.t, term) :: map

    def add_source(%{identity: identity} = context, name, module, argument) do
        options = [
            query: &query/2,
            default_params: %{identity: identity}
        ]
        source = module.new(argument, options)

        loader = context
        |> Map.get(:loader, Dataloader.new())
        |> Dataloader.add_source(name, source)

        Map.put(context, :loader, loader)
    end

    @doc """
    Handles connections for a given model when resolving.
    """
    @spec connect(Model.t, Resolution.t) :: term

    def connect(model, %{arguments: arguments} = resolution) do
        model
        |> setup(resolution)
        |> from_query(&model.all/1, arguments)
    end

    @doc """
    Handles fetching for a given model when resolving.
    """
    @spec fetch(Model.t, Resolution.t) :: term

    def fetch(model, resolution) do
        model
        |> setup(resolution)
        |> model.one
        |> capsule
    end

    @doc """
    Handles mutations for a given model when resolving.
    """
    @spec mutate(Model.t, Resolution.t) :: term

    def mutate(model, %{arguments: arguments} = resolution) do
        fields = model.__schema__(:primary_key)
        arguments = Map.take(arguments, fields)
        resolution = %{resolution | arguments: arguments}

        case fetch(model, resolution) do
            {:ok, struct} ->
                model.update(struct, arguments)
            other ->
                other
        end
    end

    @doc """
    Handles deletion for a given model when resolving.
    """
    @spec delete(Model.t, Resolution.t) :: term

    def delete(model, resolution) do
        case fetch(model, resolution) do
            {:ok, struct} ->
                model.delete(struct)
            other ->
                other
        end
    end

    @doc """
    Wrapper around `Absinthe.Resolution.Helpers.dataloader/1`.
    """
    @spec assoc(atom) :: term

    def assoc(source) do
        dataloader(source)
    end

    @doc """
    Absinthe resolver meant for connected associations.
    """
    def assoc(%model{} = struct, params, resolution) do
        resource = resolution.definition.schema_node.identifier
        association = model.__schema__(:association, resource)

        case offset_and_limit_for_query(params, []) do
            {:ok, offset, limit} ->
                query = association.queryable
                |> setup(resolution)
                |> offset(^offset)
                |> limit(^limit)

                preload = [{resource, {query, []}}]

                struct
                |> model.preload(preload)
                |> Map.get(resource)
                |> from_slice(offset)
            other ->
                other
        end
    end

    defp setup(model, %{arguments: arguments, context: context}) do
        identity = context.identity
        params = Map.put(arguments, :identity, identity)
        query(model, params)
    end

    defp query(model, %{identity: identity} = params) do
        object = cond do
            Permission.is_admin?(identity) ->
                model
            true ->
                model
                |> struct(params)
                |> Ability.query(identity)
        end
        model.filter(object, params, model)
    end

    defp capsule(tuple) when is_tuple(tuple) do
        tuple
    end
    defp capsule(nil) do
        {:error, :not_found}
    end
    defp capsule(term) do
        {:ok, term}
    end
end