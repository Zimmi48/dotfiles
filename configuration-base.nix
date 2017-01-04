hostName:
{ config, pkgs, ... }:

let
  home = "/home/theo";
in
{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  boot.loader.timeout = 2;

  networking = { inherit hostName; };

  time.timeZone = "Europe/Paris";

  nix = {
    useSandbox = true;

    # Manually manage nix-channels
    nixPath = [
      # Our local clone to track nixpkgs-unstable
      "unstable=${home}/dotfiles/unstable"
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos/nixpkgs"
      "nixos-config=${home}/dotfiles/${hostName}.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };

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
    chromium
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
    inherit home;
    description = "Théo Zimmermann";
    extraGroups = [ "audio" ];
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";

}
