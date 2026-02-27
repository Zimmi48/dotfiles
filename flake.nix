{
  description = "NixOS Flake";

  inputs = {
    # We use the stable NixOS channel as our main input
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    impermanence.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.inputs.home-manager.follows = "home-manager";
    vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      impermanence,
      ...
    }@inputs:
    let
      theo = {
        name = "theo";
        description = "Théo Zimmermann";
      };
      cecile = {
        name = "cecile";
        description = "Cécile";
      };
      unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
      # Use the latest possible version of non-free packages
      unfree-stable =
        (import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        }).pkgs;
      unfree-unstable =
        (import nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        }).pkgs;
      system = "x86_64-linux";
      # Make all inputs available in the NixOS modules
      specialArgs = inputs;
      # Define the modules that are imported in every configuration
      commonModules = [
        ./nixos-tags.nix
        { system.nixos.tags = [ (self.shortRev or self.dirtyShortRev) ]; }
        home-manager.nixosModules.home-manager
        impermanence.nixosModules.impermanence
      ];
      # Generate a NixOS module for a list of { user, stateVersion } pairs
      mkUsersModule = entries: {
        home-manager.users = builtins.listToAttrs (
          map (
            { user, stateVersion }:
            {
              name = user.name;
              value = import ./home-${user.name}.nix {
                inherit
                  stateVersion
                  unstable
                  unfree-stable
                  unfree-unstable
                  ;
              };
            }
          ) entries
        );
        users.extraUsers = builtins.listToAttrs (
          map (
            { user, ... }:
            {
              name = user.name;
              value = {
                isNormalUser = true;
                home = "/home/${user.name}";
                description = user.description;
                # To allow normal-user to run various virtualization methods, broadcast a wifi network, and control backlight
                extraGroups = [
                  "docker"
                  "libvirtd"
                  "networkmanager"
                  "user-with-access-to-virtualbox"
                  "video"
                ];
              };
            }
          ) entries
        );
      };
    in
    {

      nixosConfigurations = {
        "telecom-laptop-theo" = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = commonModules ++ [
            ./telecom-laptop-theo.nix
            (import ./configuration-base.nix {
              hostName = "telecom-laptop-theo";
              stateVersion = "22.05";
              user = theo;
            })
            (mkUsersModule [
              {
                user = theo;
                stateVersion = "23.05";
              }
            ])
          ];
        };
        "hp-elitebook-theo" = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = commonModules ++ [
            ./hp-elitebook-theo.nix
            (import ./configuration-base.nix {
              hostName = "hp-elitebook-theo";
              stateVersion = "16.09";
              user = theo;
            })
            (mkUsersModule [
              {
                user = theo;
                stateVersion = "23.05";
              }
              {
                user = cecile;
                stateVersion = "25.11";
              }
            ])
            { services.xserver.desktopManager.xfce.enable = true; }
          ];
        };
        "dell-latitude-theo" = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = commonModules ++ [
            ./dell-latitude-theo.nix
            (import ./configuration-base.nix {
              hostName = "dell-latitude-theo";
              azerty = true;
              efi = false;
              stateVersion = "23.05";
              user = theo;
            })
            (mkUsersModule [
              {
                user = theo;
                stateVersion = "23.05";
              }
            ])
          ];
        };
      };
    };
}
