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

  # Multi-display support
  services.xserver.xrandrHeads = [ "HDMI1" "HDMI2" ];

  # Time sync university servers
  services.ntp.servers = [ "ntp.univ-paris-diderot.fr" ];
}
