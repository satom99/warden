defmodule Warden.Prover do
    @moduledoc false

    import Warden.Helper

    def sign(context, identity) do
        options = config(context)
        provider = provider(context)
        provider.sign(identity, options)
    end

    def verify(context, token) do
        options = config(context)
        provider = provider(context)
        provider.verify(token, options)
    end

    def store(context, key, value, ttl) do
        provider = provider(context)
        provider.store(key, value, ttl)
    end

    def fetch(context, key) do
        provider = provider(context)
        provider.store(key)
    end
end