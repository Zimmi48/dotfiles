{ hostName
, user ? { name = "theo"; description = "Théo Zimmermann"; }
, efi ? false
, azerty ? false
}:

{ config, pkgs, ... }:

let
  home = "/home/${user.name}";
in
{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  boot.loader =
    if efi then {
        # Use the gummiboot efi boot loader.
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
        timeout = 2;
    }
    else {
        # Use the GRUB 2 boot loader.
        grub.enable = true;
        grub.version = 2;
        grub.device = "/dev/sda";
        timeout = 2;
    };

  networking = { inherit hostName; };

  time.timeZone = "Europe/Paris";

  i18n = {
    consoleFont = "Lat2-Terminus22";
    consoleUseXkbConfig = true;
    defaultLocale = "fr_FR.UTF-8";
  };

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
    xorg.xbacklight
    i3lock
    i3status
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

    # Keyboard layout(s)
    layout = if azerty then "fr" else "us,us(intl)";
    xkbOptions = if azerty then "eurosign:e" else "grp:alt_shift_toggle";

    # Login manager
    displayManager.lightdm.enable = true;

    # Window manager
    windowManager.i3 = {
      enable = true;
      configFile = ./i3-configuration-base;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers."${user.name}" = {
    isNormalUser = true;
    inherit home;
    description = user.description;

    # To allow normal-user to broadcast a wifi network
    extraGroups = [ "audio" "networkmanager" ];
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";

}
