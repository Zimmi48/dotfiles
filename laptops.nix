{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
    xss-lock
  ];

  # Desktop Environment.
  services.xserver.desktopManager.xfce.enable = true;

  services.xserver.windowManager.i3.extraSessionCommands = ''
    # Screen locker
    xss-lock -- i3lock -b 000000 &

    # Volume manager
    xfce4-volumed &

    # Network manager
    nm-applet &
  '';
}
