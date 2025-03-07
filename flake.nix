{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... } @ inputs:
  {
    nixosConfigurations.nixvm = nixpkgs.lib.nixosSystem {
      modules = [
        ./hosts/nixvm/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users.starkipraggy = import ./users/starkipraggy.nix;
          home-manager.users.fezirix = import ./users/fezirix.nix;
        }
        ./programs/zsh/zsh-as-default-shell.nix
        {
          _module.args = {
            usernameList = [ "starkipraggy" ];
          };
        }
      ];
    };
    nixosConfigurations.fezirix = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
      ];
    };
  };
}
