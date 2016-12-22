{ config, pkgs, ... }:

{
  # Settings for the virtual terminals
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "fr";
    defaultLocale = "fr_FR.UTF-8";
  };

  # Settings for the graphic mode
  services.xserver = {
    layout = "fr";
    xkbOptions = "eurosign:e";
  };
}
