{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;

  environment.systemPackages = [ pkgs.networkmanagerapplet ];

  # Desktop Environment.
  services.xserver.desktopManager.xfce.enable = true;

  services.xserver.windowManager.i3.extraSessionCommands = ''
    # Volume manager
    xfce4-volumed &

    # Network manager
    nm-applet &
  '';
}
