{
  description = "dangreco/flakes/env";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    {
      lib.mkEnv =
        f:
        flake-utils.lib.eachDefaultSystem (
          system:
          let
            pkgs = import nixpkgs { inherit system; };

            deepMerge =
              lhs: rhs:
              lhs
              // rhs
              // (builtins.mapAttrs (
                rName: rValue:
                let
                  lValue = lhs.${rName} or null;
                in
                if builtins.isAttrs lValue && builtins.isAttrs rValue then
                  deepMerge lValue rValue
                else if builtins.isList lValue && builtins.isList rValue then
                  lValue ++ rValue
                else
                  rValue
              ) rhs);

            __runtime = pkgs.writeShellApplication {
              name = "runtime";
              text = ''
                #!/usr/bin/env bash
                set -euo pipefail

                for rt in podman docker; do
                  if command -v "''$rt" >/dev/null 2>&1; then
                    echo "''$rt"
                    exit 1
                  fi
                done
                exit 1
              '';
            };

            __act = pkgs.writeShellApplication {
              name = "act";
              text = ''
                #!/usr/bin/env bash
                set -euo pipefail

                rt=''$({ runtime 2>/dev/null || true; } | head -n 1)
                [[ ''$rt ]] || { echo "No container runtime found" >&2; exit 1; }

                case ''$rt in
                    docker) socket=/var/run/docker.sock ;;
                    podman)
                        for s in /run/podman/podman.sock "''${XDG_RUNTIME_DIR:-}/podman/podman.sock"; do
                            [[ -S ''$s ]] && { socket=''$s; break; }
                        done
                    ;;
                esac

                [[ ''${socket:-} ]] || { echo "No container socket found for runtime: ''$rt" >&2; exit 1; }

                exec env DOCKER_HOST="unix://''$socket" ${pkgs.act}/bin/act "''$@"
              '';
            };

            base = {
              nativeBuildInputs = with pkgs; [
                gh
                git
                act
                just
                nixd
                nixfmt-rfc-style

                __runtime
                __act
              ];
            };

            extra = f system pkgs;
            config = deepMerge base extra;
          in
          {
            devShells.default = pkgs.mkShell config;
          }
        );
    };
}
