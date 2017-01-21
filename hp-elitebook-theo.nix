# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  hostName = "hp-elitebook-theo";
in
{
  imports = [
    (import ./configuration-base.nix hostName)
    ./qwerty.nix
    ./laptops.nix
  ];

  # Use the gummiboot efi boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  environment.systemPackages = with pkgs; [
    xss-lock
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  services.xserver.windowManager.i3.extraSessionCommands = ''
    # Screen locker
    xss-lock -- i3lock -b 000000 &

    # Volume manager
    xfce4-volumed &

    # Network manager
    nm-applet &
  '';

  # Brightness up and down keys
  services.udev.extraHwdb = ''
    evdev:atkbd:dmi:*                 # all the built-in keyboards
      KEYBOARD_KEY_97=brightnessup    # scan code: hexadecimal code minus 0x
      KEYBOARD_KEY_92=brightnessdown  # (can be found with dmesg | tail)
  '';

  fonts.fontconfig.dpi = 120;
}
