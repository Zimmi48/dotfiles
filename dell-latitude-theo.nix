{ config, pkgs, ... }:

let
  hostName = "dell-latitude-theo";
in
{
  imports = [
    (import ./configuration-base.nix hostName)
    ./grub.nix
    ./azerty.nix
    ./laptops.nix
  ];
}
