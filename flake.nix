{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... } @ inputs:
  let
    gitDetails = {
      userName = "starkipraggy";
      userEmail = "starkipraggy@hotmail.com";
    };

    defaultUser = "fezirix";
    usernameList = [ "starkipraggy" defaultUser ];
  in
  {
    nixosConfigurations.nixvm = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit gitDetails;
        inherit usernameList;
      };
      modules = [
        ./hosts/nixvm/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users = nixpkgs.lib.genAttrs usernameList (name: import ./users/${name}.nix);
        }
        ./programs/zsh/zsh-as-default-shell.nix
      ];
    };
    nixosConfigurations.fezirix = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
      ];
    };
  };
}
