defmodule Warden.Before do
    @moduledoc false

    import Plug.Conn

    alias Absinthe.Blueprint

    @header "cache-control"

    def call(conn, blueprint) do
        with max_age = Process.get(:cache_ttl),
             private = Process.get(:cache_private),
             false <- has_errors?(blueprint),
             false <- is_nil(max_age)
        do
            scope = if private do "private" else "public" end
            control = "#{scope}, max_age=#{max_age}"
            put_resp_header(conn, @header, control)
        else
            _error -> conn
        end
    end

    defp has_errors?(%Blueprint{result: %{errors: _errors}}) do
        true
    end
    defp has_errors?(_blueprint) do
        false
    end
end