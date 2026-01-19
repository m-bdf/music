{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    strudel-mondo = {
      # printf 'e/%s\nts/%s' '@strudel/core' 'mondo' | base64
      url = "https://esm.sh/v135/@strudel/mondo/X-ZS9Ac3RydWRlbC9jb3JlCnRzL21vbmRv/node/mondo.bundle.mjs";
      flake = false;
    };
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      with inputs.nixpkgs.legacyPackages.${system}.extend
        inputs.vscode-extensions.overlays.default;
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

      packages.mondo-vscode =
        vscode-marketplace.cmillsdev.strudelvs.overrideAttrs {
          patchPhase = ''
            sed '/@strudel\/core/{ s| as |:|g; s|*as||g
              s|import|var|g; s|from[^;]*|=globalThis|g
            }' ${inputs.strudel-mondo} > dist/mondo.js

            echo '
              registerControl("markcss");
              strudelScope.samples = url => pure({
                fetch: () => doughsamples(url.__pure),
              });
            ' >> dist/mondo.js

            sed -i '/repl.evaluate(tune)/c (async () => { \
              const pat = (await import("./mondo.js")).mondo(tune); \
              await Promise.all(pat.firstCycleValues.map(v => v.fetch?.())); \
              await repl.setPattern(pat.filterValues(v => !v.fetch)); \
            })();' dist/strudel.js
          '';
      };
    });
}
