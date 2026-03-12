# NOTE: need --impure
# $ home-manager switch --flake ".#${USER}" --impure
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
      homeConfig = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    in
    {
      homeConfigurations.${builtins.getEnv "USER"} = homeConfig;
      packages.${system}.default = homeConfig.activationPackage;
    };
}
