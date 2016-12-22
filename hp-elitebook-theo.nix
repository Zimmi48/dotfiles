# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./configuration-base.nix
    ./qwerty.nix
    ./laptops.nix
  ];

  # Use the gummiboot efi boot loader.
  boot.loader = {
    gummiboot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.hostName = "hp-elitebook-theo";

  environment.systemPackages = with pkgs; [
    xss-lock
    xorg.xbacklight
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Does it really work?
  services.logind.extraConfig = "HandleLidSwitch=suspend";

  # Brightness up and down keys
  services.udev.extraHwdb = ''
    evdev:atkbd:dmi:*                 # all the built-in keyboards
      KEYBOARD_KEY_97=brightnessup    # scan code: hexadecimal code minus 0x
      KEYBOARD_KEY_92=brightnessdown  # (can be found with dmesg | tail)
  '';

  fonts.fontconfig.dpi = 120;
}
