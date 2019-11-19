defmodule Warden.Document do
    @moduledoc false

    @behaviour Absinthe.Plug.DocumentProvider

    use Absinthe.Phase

    alias Absinthe.Pipeline
    alias Absinthe.Phase.Document.Execution.Resolution
    alias Absinthe.Phase.Document.Result
    alias Absinthe.Plug.Request.Query
    alias Warden.Idempotent
    alias __MODULE__

    def pipeline(%Query{pipeline: pipeline}) do
        pipeline
        |> Pipeline.insert_after(Result, Idempotent)
        |> Pipeline.insert_before(Resolution, Document)
    end

    def process(%Query{document: nil} = query, _options) do
        {:cont, query}
    end
    def process(%Query{document: _document} = query, _options) do
        {:halt, query}
    end

    def run(blueprint, _options) do
        {:ok, blueprint}
    end
end