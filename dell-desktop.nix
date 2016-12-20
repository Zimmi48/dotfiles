# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub = {
    enable = true;
    version = 2;

    # Define on which hard drive you want to install Grub.
    device = "/dev/sda";
  };

  boot.loader.timeout = 2;

  # Audio
  boot.extraModprobeConfig = ''
    options snd_hda_intel enable=0,1
  '';

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus22";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

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
    i3status
    i3lock
    dmenu
    rxvt_unicode
    pcmanfm
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
    feh
    gnome3.eog
    texlive.combined.scheme-full
  ];

  programs.bash.enableCompletion = true;
  nix.useSandbox = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];

  # Enable Avahi for auto-discovery of printers
  # services.avahi.enable = true;

  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # Keyboards
    layout = "us,us(intl)";
    xkbOptions = "grp:alt_shift_toggle";

    # Login manager
    displayManager.sddm = {
      enable = true;

      # Auto numlock
      autoNumlock = true;
    };

    # Custom multi-display support
    # And set the background color
    displayManager.sessionCommands = ''
      xrandr --output HDMI2 --auto --primary --output HDMI1 --auto --left-of HDMI2
      xmodmap -e "keycode 118 ="
      xsetroot -solid "#999999"
    '';

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
