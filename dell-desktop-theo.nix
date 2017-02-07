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

  # Custom multi-display support
  services.xserver.displayManager.sessionCommands = ''
    xrandr --output HDMI2 --auto --primary --output HDMI1 --auto --left-of HDMI2
  '';

  # RedShift changes the color of the screen to a redder tone when night is approaching
  services.redshift = {
    enable = true;
    latitude = "48.8";
    longitude = "2.3";
    extraOptions = [ "-m randr" ];
  };
}
