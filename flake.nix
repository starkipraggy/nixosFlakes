{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";

      # Optional but recommended to limit the size of your system closure.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, lanzaboote, nixos-hardware, ... } @ inputs:
  let
    gitdetails = {
      userName = "starkipraggy";
      userEmail = "starkipraggy@hotmail.com";
    };

    defaultUser = "fezirix";
    usernameList = [ "starkipraggy" defaultUser ];
  in
  {
    nixosConfigurations = {
      nixvm = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit gitdetails;
          inherit usernameList;
        };
        modules = [
          ./hosts/nixvm/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit gitdetails; };

            home-manager.users = nixpkgs.lib.genAttrs usernameList (name: import ./users/userTemplate.nix {
              inherit gitdetails;
              pkgs = nixpkgs.pkgs;
              username = name;
            });
          }
          ./programs/zsh/zsh-as-default-shell.nix
        ];
      };
      nixos = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/surfacepro/configuration.nix
          nixos-hardware.nixosModules.microsoft-surface-pro-9

          lanzaboote.nixosModules.lanzaboote
          ({ pkgs, lib, ... }: {

              environment.systemPackages = [
                # For debugging and troubleshooting Secure Boot.
                pkgs.sbctl
              ];

              # Lanzaboote currently replaces the systemd-boot module.
              # This setting is usually set to true in configuration.nix
              # generated at installation time. So we force it to false
              # for now.
              boot.loader.systemd-boot.enable = lib.mkForce false;

              boot.lanzaboote = {
                enable = true;
                              pkiBundle = "/var/lib/sbctl";
                #pkiBundle = "/etc/secureboot";
              };
          })
        ];
      };

      fezirix = nixpkgs.lib.nixosSystem {
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
