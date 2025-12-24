{
  description = "dangreco/env environment";

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
          };

          devShells = {
            default =
              let
                __zed = pkgs.writers.writeJSON "settings.json" { };
              in
              pkgs.mkShell {
                packages =
                  with pkgs;
                  [
                    nil
                    nixd
                    nixfmt
                  ]
                  ++ config.pre-commit.settings.enabledPackages;

                shellHook = ''
                  mkdir -p .zed
                  ln -sf ${__zed} .zed/settings.json
                  ${config.pre-commit.shellHook}
                '';
              };
          };
        };
      flake = {
        templates = {
          default = {
            path = ./template/default;
            description = ''
              A minimal flake template including git hooks and file management.
            '';
          };
          deno = {
            path = ./template/deno;
            description = ''
              A Deno development flake template including git hooks and file management.
            '';
          };
          python = {
            path = ./template/python;
            description = ''
              A Python development flake template including git hooks and file management.
            '';
          };
          rust = {
            path = ./template/rust;
            description = ''
              A Rust development flake template including git hooks and file management.
            '';
          };
        };
      };
    };
}
