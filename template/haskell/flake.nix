{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.git-hooks.flakeModule ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        let
          # GHC with the project's dependencies in its package database, so cabal
          # resolves them without needing the Hackage index.
          ghc = pkgs.haskellPackages.ghcWithPackages (
            ps: with ps; [
              hspec
              hspec-discover
            ]
          );
        in
        {
          pre-commit.settings.hooks = {
            nixfmt.enable = true;
            yamlfmt.enable = true;
            yamllint.enable = true;
            ormolu.enable = true;
            hlint.enable = true;
          };

          devShells = {
            default =
              let
                __zed = pkgs.writers.writeJSON "settings.json" {
                  lsp.hls.initialization_options.haskell.formattingProvider = "ormolu";

                  languages.Haskell.format_on_save = "on";
                };
              in
              pkgs.mkShell {
                packages =
                  with pkgs;
                  [
                    nil
                    nixd
                    nixfmt
                    go-task
                    ghc
                    cabal-install
                    haskell-language-server
                    ormolu
                    hlint
                    hpack
                    haskellPackages.hspec-discover
                  ]
                  ++ config.pre-commit.settings.enabledPackages;

                shellHook = ''
                  mkdir -p .zed
                  ln -sf ${__zed} .zed/settings.json
                  ${config.pre-commit.shellHook}
                '';
              };

            ci = pkgs.mkShell {
              packages =
                with pkgs;
                [
                  go-task
                  ghc
                  cabal-install
                  ormolu
                  hlint
                  hpack
                  haskellPackages.hspec-discover
                ]
                ++ config.pre-commit.settings.enabledPackages;

              shellHook = ''
                ${config.pre-commit.shellHook}
              '';
            };
          };
        };
    };
}
