defmodule Warden.Idempotent do
    @moduledoc false

    use Absinthe.Phase

    def run(blueprint, _options) do
        {:ok, blueprint}
    end
end