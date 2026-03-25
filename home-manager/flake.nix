# NOTE: need --impure
# $ home-manager switch --flake ".#common" --impure
{
  description = "Home Manager configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      system = builtins.currentSystem;
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;

      commonPkgs = import ./packages/common.nix { inherit pkgs lib; };
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
        full = mkHome (commonPkgs ++ extraPkgs); # 将来 music 等が増えたら全部入り
      };
      packages.${system}.default = (mkHome commonPkgs).activationPackage;
    };
}
