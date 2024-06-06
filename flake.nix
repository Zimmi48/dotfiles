{
  description = "NixOS Flake";

  inputs = {
    # We use the stable NixOS channel as our main input
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, impermanence, ... }@inputs:
    let
      user = { name = "theo"; description = "Théo Zimmermann"; };
      home = "/home/${user.name}";
      unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
      # Use the latest possible version of non-free packages
      unfree-stable = (import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; }).pkgs;
      unfree-unstable = (import nixpkgs-unstable { system = "x86_64-linux"; config.allowUnfree = true; }).pkgs;
      system = "x86_64-linux";
      # Make all inputs available in the NixOS modules
      specialArgs = inputs;
      # Define the modules that are imported in every configuration
      commonModules = [
        ./nixos-tags.nix
        home-manager.nixosModules.home-manager
        impermanence.nixosModules.impermanence
      ];
    in {

    nixosConfigurations = {
      "telecom-laptop-theo" = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = commonModules ++ [
          ./telecom-laptop-theo.nix
          (import ./configuration-base.nix { hostName = "telecom-laptop-theo"; stateVersion = "22.05"; inherit user home; })
          { home-manager.users."${user.name}" = import ./home.nix { stateVersion = "23.05"; inherit user home unstable unfree-stable unfree-unstable; }; }
        ];
      };
      "hp-elitebook-theo" = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = commonModules ++ [
          ./hp-elitebook-theo.nix
          (import ./configuration-base.nix { hostName = "hp-elitebook-theo"; stateVersion = "16.09"; inherit user home; })
          { home-manager.users."${user.name}" = import ./home.nix { stateVersion = "23.05"; inherit user home unstable unfree-stable unfree-unstable; }; }
        ];
      };
      "dell-latitude-theo" = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = commonModules ++ [
          ./dell-latitude-theo.nix
          (import ./configuration-base.nix { hostName = "dell-latitude-theo"; azerty = true; efi = false; stateVersion = "23.05"; inherit user home; })
          { home-manager.users."${user.name}" = import ./home.nix { stateVersion = "23.05"; inherit user home unstable unfree-stable unfree-unstable; }; }
        ];
      };
    };
  };
}
