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
}
