{
  inputs = {
    tidal = {
      url = "github:mitchmindtree/tidalcycles.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sonic-pi-tool = {
      url = "github:lpil/sonic-pi-tool";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, tidal, sonic-pi-tool }:
    tidal.utils.eachSupportedSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells = {
        inherit (tidal.devShells.${system}) tidal;

        sonic-pi = pkgs.mkShell {
          packages = [
            pkgs.sonic-pi

            (pkgs.rustPlatform.buildRustPackage rec {
              name = "sonic-pi-tool";
              src = sonic-pi-tool;
              cargoLock.lockFile = src + /Cargo.lock;
            })
          ];
        };

        glicol = pkgs.mkShell {
          packages = [
            pkgs.cargo
            pkgs.flac
          ];
        };
      };
    });
}
