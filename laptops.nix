{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];

  # Desktop Environment.
  services.xserver.desktopManager.xfce.enable = true;

  # To allow normal-user theo to broadcast a wifi network
  users.extraUsers.theo.extraGroups = [ "networkmanager" ];

  # Touchpad
  # Without it we might have problems
  # - at boot on dell-latitude
  # - after suspend on hp-elitebook
  services.xserver.synaptics = {
    enable = true;
    accelFactor = "0.002"; # default 0.001
    minSpeed = "1.0"; # default 0.6
    maxSpeed = "2.0"; # default 1.0
  };
}
