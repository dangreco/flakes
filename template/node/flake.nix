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
        {
          pre-commit.settings.hooks = {
            nixfmt.enable = true;
            yamlfmt.enable = true;
            yamllint.enable = true;
            oxlint.enable = true;
            oxfmt.enable = true;
          };

          devShells = {
            default =
              let
                __zed =
                  let
                    defaults = {
                      language_servers = [
                        "oxfmt"
                        "oxlint"
                        "!typescript-language-server"
                        "!vtsls"
                        "!eslint"
                        "!biome"
                      ];
                      formatter = [
                        {
                          code_action = "source.fixAll.oxc";
                        }
                        {
                          external = {
                            command = "${pkgs.oxfmt}/bin/oxfmt";
                            arguments = [
                              "--stdin-filepath"
                              "{buffer_path}"
                            ];
                          };
                        }
                      ];
                      format_on_save = "on";
                    };
                  in
                  pkgs.writers.writeJSON "settings.json" {
                    lsp.oxlint.binary = {
                      path = "${pkgs.oxlint}/bin/oxlint";
                      arguments = [ "--lsp" ];
                    };
                    lsp.oxfmt.binary = {
                      path = "${pkgs.oxfmt}/bin/oxfmt";
                      arguments = [ "--lsp" ];
                    };

                    languages.JavaScript = defaults;
                    languages.JSX = defaults;
                    languages.TypeScript = defaults;
                    languages.TSX = defaults;
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
                    nodejs_24
                    corepack_24
                    oxlint
                    oxfmt
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
                  nodejs_24
                  corepack_24
                  oxlint
                  oxfmt
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
