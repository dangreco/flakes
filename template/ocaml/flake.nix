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
            _ocamlformat = {
              enable = true;
              name = "ocamlformat";
              files = "\\.mli?$";
              entry = "${pkgs.ocamlformat}/bin/ocamlformat --inplace";
              pass_filenames = true;
            };
          };

          devShells = {
            default =
              let
                __zed = pkgs.writers.writeJSON "settings.json" {
                  lsp.ocaml-lsp.binary.path = "${pkgs.ocamlPackages.ocaml-lsp}/bin/ocamllsp";

                  languages.OCaml = {
                    formatter = "language_server";
                    format_on_save = "on";
                  };
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
                    ocaml
                    dune_3
                    ocamlformat
                    ocamlPackages.ocaml-lsp
                    ocamlPackages.findlib
                    ocamlPackages.utop
                  ]
                  ++ config.pre-commit.settings.enabledPackages;

                buildInputs = with pkgs.ocamlPackages; [ alcotest ];

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
                  ocaml
                  dune_3
                  ocamlformat
                  ocamlPackages.findlib
                ]
                ++ config.pre-commit.settings.enabledPackages;

              buildInputs = with pkgs.ocamlPackages; [ alcotest ];

              shellHook = ''
                ${config.pre-commit.shellHook}
              '';
            };
          };
        };
    };
}
