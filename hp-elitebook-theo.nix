{ config, pkgs, ... }:

{
  imports = [
    (import ./configuration-base.nix {
      hostName = "hp-elitebook-theo";
      efi = true;
    })
    ./laptops.nix
  ];

  boot.blacklistedKernelModules = [ "mei_wdt" ];
}
