{ config, pkgs, ... }:

{
  imports = [
    (import ./configuration-base.nix { hostName = "dell-desktop-theo"; })
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

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];

  # Enable Avahi for auto-discovery of printers
  # Comment out once printer is installed to avoid seeing too many of them
  # services.avahi.enable = true;

  # Custom multi-display support
  services.xserver.displayManager.sessionCommands = ''
    xrandr --output HDMI1 --rotate left --auto --primary --output HDMI2 --auto --right-of HDMI1
  '';

  # Time sync university servers
  services.ntp.servers = [ "ntp.univ-paris-diderot.fr" ];
}
