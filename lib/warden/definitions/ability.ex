defprotocol Warden.Ability do
    @moduledoc """
    Protocol for Ecto queryables. 
    """
    alias Ecto.Queryable
    alias Warden.Identity

    @doc """
    Must return a limited queryable based on
    the permissions of a specific identity.
    """
    @spec query(struct, Identity.t, atom) :: Queryable.t

    def query(struct, identity, action \\ :fetch)

    @doc """
    Convenience function for delegation from
    the `c:Warden.Resolver.can?/3` callback.
    """
    @spec can?(struct, Identity.t, atom) :: boolean

    def can?(struct, identity, action)
end