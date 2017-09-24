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

  services.xserver.libinput = {
    enable = true;
    naturalScrolling = true;
    disableWhileTyping = true;
  };

  fonts.fontconfig.dpi = 120;
}
