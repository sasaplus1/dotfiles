# NOTE: need --impure
# $ home-manager switch --flake ".#common" --impure
{
  description = "Home Manager configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      system = builtins.currentSystem;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          # Disable direnv's checkPhase globally; it hangs on macOS.
          # This also unifies direnv into a single derivation so that
          # downstream build inputs (e.g. mise) reuse the same one
          # and avoid a duplicate rebuild.
          (final: prev: {
            direnv = prev.direnv.overrideAttrs (_: { doCheck = false; });
          })
        ];
      };
      lib = pkgs.lib;

      commonPkgs = import ./packages/common.nix { inherit pkgs pkgs-unstable lib; };
      extraPkgs = import ./packages/extra.nix { inherit pkgs lib; };

      mkHome =
        profilePackages:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
          extraSpecialArgs = { inherit profilePackages; };
        };
    in
    {
      homeConfigurations = {
        common = mkHome commonPkgs;
        extra = mkHome (commonPkgs ++ extraPkgs);
        full = mkHome (commonPkgs ++ extraPkgs);
      };
      packages.${system}.default = (mkHome commonPkgs).activationPackage;
    };
}
