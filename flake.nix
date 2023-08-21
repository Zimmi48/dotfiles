{
  description = "NixOS Flake";

  inputs = {
    nixpkgs.url = "path:/home/theo/dotfiles/nixos";
    nixpkgs-unstable.url = "path:/home/theo/dotfiles/nixpkgs";
  };

  # `outputs` are all the build result of the flake.
  #
  # A flake can have many use cases and different types of outputs.
  # 
  # parameters in function `outputs` are defined in `inputs` and
  # can be referenced by their names. However, `self` is an exception,
  # this special parameter points to the `outputs` itself(self-reference)
  # 
  # The `@` syntax here is used to alias the attribute set of the
  # inputs's parameter, making it convenient to use inside the function.
  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      "telecom-laptop-theo" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # Make all inputs available in the NixOS modules.
        specialArgs = inputs;
        modules = [
          ./telecom-laptop-theo.nix
        ];
      };
      "hp-elitebook-theo" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # Make all inputs available in the NixOS modules.
        specialArgs = inputs;
        modules = [
          ./hp-elitebook-theo.nix
        ];
      };
      "dell-latitude-theo" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # Make all inputs available in the NixOS modules.
        specialArgs = inputs;
        modules = [
          ./dell-latitude-theo.nix
        ];
      };
    };
  };
}