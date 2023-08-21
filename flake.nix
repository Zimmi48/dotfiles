{
  description = "NixOS Flake";

  inputs = {
    # We use the stable NixOS channel as our main input
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs: {

    nixosConfigurations = {
      "telecom-laptop-theo" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # Make all inputs available in the NixOS modules
        specialArgs = inputs;
        modules = [
          ./telecom-laptop-theo.nix
        ];
      };
      "hp-elitebook-theo" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./hp-elitebook-theo.nix
        ];
      };
      "dell-latitude-theo" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./dell-latitude-theo.nix
        ];
      };
    };

    # This flake also exports packages for each older Coq version (from 8.6 to 8.16) and for Coq dev
    packages.x86_64-linux = with nixpkgs-unstable.legacyPackages.x86_64-linux; {
      inherit coq_8_6 coq_8_7 coq_8_8 coq_8_9 coq_8_10 coq_8_11 coq_8_12 coq_8_13;
      coq_8_14 = coqPackages_8_14.coqide;
      coq_8_15 = coqPackages_8_15.coqide;
      coq_8_16 = coqPackages_8_16.coqide;
      coq_dev = coq.override { version = "dev"; buildIde = true; };
    };
  };
}