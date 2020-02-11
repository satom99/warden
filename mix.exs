defmodule Warden.MixProject do
    use Mix.Project

    def project do
        [
            app: :warden,
            version: "0.1.0",
            elixir: "~> 1.2",
            build_embedded: Mix.env == :prod,
            deps: deps(),
            docs: docs()
        ]
    end

    defp deps do
        [
            {:ecto, ">= 2.0.0"},
            {:plug, ">= 0.4.1"},
            {:cowboy, ">= 2.0.0"},
            {:phoenix, ">= 0.16.0", runtime: false},
            {:absinthe, ">= 1.3.0"},
            {:dataloader, ">= 1.0.0"},
            {:absinthe_plug, ">= 1.4.0"},
            {:absinthe_relay, ">= 1.4.0"},
            {:ex_doc, ">= 0.5.1", only: :dev}
        ]
    end

    defp docs do
        [
            groups_for_modules: [
                "Definitions": [
                    Warden.Middleware,
                    Warden.Resolver,
                    Warden.Provider,
                    Warden.Handler,
                    Warden.Plug
                ],
                "Authentication": [
                    Warden.Identity,
                    Warden
                ],
                "Authorization": [
                    Warden.Permission,
                    Warden.Ability,
                    Warden.Model
                ],
                "Cache": [
                    Warden.Cache
                ],
                "Helpers": [
                    Warden.Middleware,
                    Warden.Error,
                    Warden.Loader
                ]
            ]
        ]
    end
end