{ config, pkgs, ... }:

{
  # Settings for the virtual terminals
  i18n = {
    consoleFont = "Lat2-Terminus22";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Settings for the graphic mode
  services.xserver = {
    layout = "us,us(intl)";
    xkbOptions = "grp:alt_shift_toggle";
  };
}
