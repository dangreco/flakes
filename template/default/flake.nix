{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    files.url = "github:mightyiam/files";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.files.flakeModules.default
        inputs.git-hooks.flakeModule
      ];
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
          files.files = [
            {
              path_ = ".zed/settings.json";
              drv = pkgs.writers.writeJSON "settings.json" { };
            }
          ];

          pre-commit.settings.hooks = {
            nixfmt.enable = true;
          };

          devShells = {
            default = pkgs.mkShell {
              packages =
                with pkgs;
                [
                  nil
                  nixd
                  nixfmt
                ]
                ++ config.pre-commit.settings.enabledPackages;

              shellHook = ''
                ${config.files.writer.drv}/bin/write-files
                ${config.pre-commit.shellHook}
              '';
            };
          };
        };
    };
}
