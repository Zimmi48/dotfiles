{
  description = "NixOS Flake";

  inputs = {
    # We use the stable NixOS channel as our main input
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
    let
      user = { name = "theo"; description = "Théo Zimmermann"; };
      home = "/home/${user.name}";
      unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
      # Use the latest possible version of non-free packages
      unfree = (import nixpkgs-unstable { system = "x86_64-linux"; config.allowUnfree = true; }).pkgs;
    in {

    nixosConfigurations = {
      "telecom-laptop-theo" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # Make all inputs available in the NixOS modules
        specialArgs = inputs;
        modules = [
          ./telecom-laptop-theo.nix
          (import ./configuration-base.nix { hostName = "telecom-laptop-theo"; stateVersion = "22.05"; inherit user home unstable unfree; })
          home-manager.nixosModules.home-manager
          { home-manager.users."${user.name}" = import ./home.nix { stateVersion = "23.05"; inherit user home unstable; }; }
        ];
      };
      "hp-elitebook-theo" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./hp-elitebook-theo.nix
          (import ./configuration-base.nix { hostName = "hp-elitebook-theo"; stateVersion = "16.09"; inherit user home unstable unfree; })
          home-manager.nixosModules.home-manager
          { home-manager.users."${user.name}" = import ./home.nix { stateVersion = "23.05"; inherit user home unstable; }; }
        ];
      };
      "dell-latitude-theo" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./dell-latitude-theo.nix
          (import ./configuration-base.nix { hostName = "dell-latitude-theo"; azerty = true; efi = false; stateVersion = "16.09"; inherit user home unstable unfree; })
          home-manager.nixosModules.home-manager
          { home-manager.users."${user.name}" = import ./home.nix { stateVersion = "23.05"; inherit user home unstable; }; }
        ];
      };
    };
  };
}