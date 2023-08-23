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
          { home-manager.users."${user.name}" = import ./home.nix { stateVersion = "23.05"; inherit user home; }; }
        ];
      };
      "hp-elitebook-theo" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./hp-elitebook-theo.nix
          (import ./configuration-base.nix { hostName = "hp-elitebook-theo"; stateVersion = "16.09"; inherit user home unstable unfree; })
          home-manager.nixosModules.home-manager
          { home-manager.users."${user.name}" = import ./home.nix { stateVersion = "23.05"; inherit user home; }; }
        ];
      };
      "dell-latitude-theo" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./dell-latitude-theo.nix
          (import ./configuration-base.nix { hostName = "dell-latitude-theo"; azerty = true; efi = false; stateVersion = "16.09"; inherit user home unstable unfree; })
          home-manager.nixosModules.home-manager
          { home-manager.users."${user.name}" = import ./home.nix { stateVersion = "23.05"; inherit user home; }; }
        ];
      };
    };

    # This flake also exports packages for each older Coq version (from 8.6 to 8.16) and for Coq dev
    packages.x86_64-linux = with unstable; {
      inherit coq_8_6 coq_8_7 coq_8_8 coq_8_9 coq_8_10 coq_8_11 coq_8_12 coq_8_13;
      coq_8_14 = coqPackages_8_14.coqide;
      coq_8_15 = coqPackages_8_15.coqide;
      coq_8_16 = coqPackages_8_16.coqide;
      coq_dev = coq.override { version = "dev"; buildIde = true; };
    };
  };
}