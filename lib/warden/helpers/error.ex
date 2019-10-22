defmodule Warden.Error do
    @moduledoc """
    Middleware that transforms changeset errors.
    """
    use Warden.Middleware

    alias Ecto.Changeset

    @doc """
    Injects the middleware at the end.
    """
    @spec inject(list) :: list

    def inject(middleware) do
        middleware ++ [__MODULE__]
    end

    @doc false
    def call(resolution, _config) do
        errors = resolution
        |> Map.get(:errors)
        |> Enum.map(&parse/1)
        |> List.flatten

        %{resolution | errors: errors}
    end

    defp parse(%Changeset{} = changeset) do
        changeset
        |> Changeset.traverse_errors(&format/1)
        |> Enum.map(
            fn {key, value} ->
                %{key: key, message: value}
            end
        )
    end
    defp parse(error), do: error

    defp format({message, options}) do
        Enum.reduce(
            options, message,
            fn {key, value}, acc ->
                value = to_string(value)
                String.replace(acc, "%{#{key}}", value)
            end
        )
    end
end