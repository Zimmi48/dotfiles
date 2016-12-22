# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  boot.loader.timeout = 2;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # This is where e.g. to override packages
  nixpkgs.config = {
    # List the names of allowed non-free packages
    allowUnfreePredicate = with builtins; (pkg: elem (parseDrvName pkg.name).name [
      "mendeley"
    ]);
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    nix-repl
    wget
    which
    gnumake
    zip
    unzip
    git
    i3lock
    dmenu
    rxvt_unicode
    firefox
    thunderbird
    libreoffice
    irssi
    evince
    mendeley
    emacs
    rlwrap
    imagemagick
    texlive.combined.scheme-full
  ];

  programs.bash.enableCompletion = true;
  nix.useSandbox = true;

  # List services that you want to enable:

  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # Login manager
    displayManager.lightdm.enable = true;

    # Window manager
    windowManager.i3.enable = true;

  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.theo = {
    isNormalUser = true;
    home = "/home/theo";
    description = "Théo Zimmermann";
    extraGroups = [ "audio" ];
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";

}
