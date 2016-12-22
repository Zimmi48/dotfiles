{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];

  # Desktop Environment.
  services.xserver.desktopManager.xfce.enable = true;
}
