# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./configuration-base.nix
    ./grub.nix
    ./azerty.nix
    ./laptops.nix
  ];

  networking.hostName = "theo-latitude"; # Define your hostname.

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Touchpad
  services.xserver.synaptics = {
    enable = true;
    accelFactor = "0.002"; # default 0.001
    minSpeed = "1.0"; # default 0.6
    maxSpeed = "2.0"; # default 1.0
  };
}
