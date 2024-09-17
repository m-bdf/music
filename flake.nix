{
  inputs.sonic-pi-tool = {
    url = "github:Sohalt/sonic-pi-tool/fix-on-nix";
    inputs.utils.follows = "flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs, sonic-pi-tool }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.sonic-pi
          sonic-pi-tool.packages.${system}.default
        ];
      };
    });
}
