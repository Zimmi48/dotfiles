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
