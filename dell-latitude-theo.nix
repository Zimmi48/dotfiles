{ config, pkgs, ... }:

{
  imports = [
    (import ./configuration-base.nix {
      hostName = "dell-latitude-theo";
      azerty = true;
    });
    ./laptops.nix
  ];
}
