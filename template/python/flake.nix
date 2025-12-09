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
        let
          python = rec {
            version = "3.13";
            package = pkgs."python${builtins.replaceStrings [ "." ] [ "" ] version}".withPackages (
              ps: with ps; [
                uv
                ruff
              ]
            );
          };
        in
        {
          files.files = [
            {
              path_ = ".zed/settings.json";
              drv = pkgs.writers.writeJSON "settings.json" {
                lsp.ty = {
                  binary = "${pkgs.ty}/bin/ty";
                  arguments = [ "server" ];
                };
                languages.Python = {
                  language_servers = [
                    "ty"
                    "!pylsp"
                    "!pyright"
                    "!basedpyright"
                  ];
                  formatter.external = {
                    command = "${python.package}/bin/ruff";
                    args = [
                      "format"
                      "--stdin-filename"
                      "{buffer_path}"
                    ];
                  };
                };
              };
            }
          ];

          pre-commit.settings.hooks = {
            nixfmt.enable = true;
            taplo.enable = true;
            yamlfmt.enable = true;
            yamllint.enable = true;
            ruff = {
              enable = true;
              package = python.package;
            };
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

              buildInputs = with pkgs; [
                ty
                python.package
              ];

              shellHook = ''
                ${config.files.writer.drv}/bin/write-files
                ${config.pre-commit.shellHook}
              '';
            };
          };
        };
    };
}
