defmodule Warden.Error do
    @moduledoc """
    Transforms changeset errors as a middleware.
    """
    use Warden.Middleware

    alias Ecto.Changeset

    @doc """
    Injects the middleware at the tail.
    """
    @spec inject(list) :: list

    def inject(middleware) do
        middleware ++ [__MODULE__]
    end

    @doc false
    def call(resolution, _options) do
        errors = resolution
        |> Map.get(:errors)
        |> Enum.map(&transform/1)
        |> List.flatten

        %{resolution | errors: errors}
    end

    defp transform(%Changeset{} = changeset) do
        changeset
        |> Changeset.traverse_errors(&format/1)
        |> Enum.map(&object/1)
    end
    defp transform(error) do
        error
    end

    defp format({message, options}) do
        Enum.reduce(
            options, message,
            fn {key, value}, acc ->
                value = to_string(value)
                String.replace(acc, "%{#{key}}", value)
            end
        )
    end
    defp object({key, value}) do
        %{key: key, message: value}
    end
end