{ config, pkgs, ... }:

{
  imports = [
    (import ./configuration-base.nix {
      hostName = "dell-latitude-theo";
      azerty = true;
    })
    ./laptops.nix
  ];

  # Might be worth checking if it can be switched to lipinput
  services.xserver.synaptics = {
    enable = true;
    accelFactor = "0.002"; # default 0.001
    minSpeed = "1.0"; # default 0.6
    maxSpeed = "2.0"; # default 1.0
  };
}
