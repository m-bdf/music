{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    sonic-pi-tool = {
      url = "github:Sohalt/sonic-pi-tool";
      inputs.utils.follows = "flake-utils";
    };
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      with inputs.nixpkgs.legacyPackages.${system};
    {
      packages.mondo = writeShellScriptBin "mondo" ''
        LD_LIBRARY_PATH+=:"${alsa-lib}/lib"

        src=$(realpath -e "$1") &&
        out=$(realpath "''${2-/.}") &&

        [ $# -lt 3 ] || {
          echo 'usage: mondo <src> [<out>]' >&2
          exit 1
        }

        cd "$(mktemp -d --tmpdir mondo-XXXXXX)"
        trap 'rm -rf $PWD' EXIT
        cp ${./mondo.mjs} mondo.mjs

        ${lib.getExe bun} install --analyze mondo.mjs --force
        ${lib.getExe nodejs_latest} mondo.mjs "$src" "''${out%/}"
      '';

      devShells.sonic-pi = mkShellNoCC {
        packages = [
          sonic-pi
          inputs.sonic-pi-tool.packages.${system}.default
        ];
      };
    });
}
