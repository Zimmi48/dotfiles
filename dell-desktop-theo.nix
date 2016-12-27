# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    (import ./configuration-base.nix "dell-desktop-theo")
    ./grub.nix
    ./qwerty.nix
  ];

  # Audio
  boot.extraModprobeConfig = ''
    options snd_hda_intel enable=0,1
  '';

  # Additional packages
  environment.systemPackages = with pkgs; [
    pcmanfm
    feh
    gnome3.eog
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];

  # Enable Avahi for auto-discovery of printers
  # services.avahi.enable = true;

  # Custom multi-display support
  services.xserver.displayManager.sessionCommands = ''
    xrandr --output HDMI2 --auto --primary --output HDMI1 --auto --left-of HDMI2
  '';
}
