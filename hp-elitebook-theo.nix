# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Use the gummiboot efi boot loader.
  boot.loader = {
    gummiboot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 2;
  };

  # networking.hostName = "nixos"; # Define your hostname.
  networking = {
    hostName = "hp-elitebook-theo";

    # I'm using network manager for easy eduroam support
    networkmanager.enable = true;
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # List packages installed in system profile.
  # To search by name, use http://nixos.org/nixos/packages.html
  environment.systemPackages = with pkgs; [
    nix-repl
    wget
    which
    gnumake
    zip
    unzip
    git
    dmenu
    i3lock
    xss-lock
    networkmanagerapplet
    xorg.xbacklight
    rxvt_unicode
    irssi
    rlwrap
    emacs
    firefox
    libreoffice
    evince
    imagemagick
    texlive.combined.scheme-full
  ];

  # option does not exist !?
  # nix.useSandbox = true;

  programs.bash.enableCompletion = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    # Keyboard
    layout = "us,us(intl)";
    xkbOptions = "grp:alt_shift_toggle";

    # Touchpad
    # synaptics.enable = true;

    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;
    windowManager.i3.enable = true;
  };

  # Does it really work?
  services.logind.extraConfig = "HandleLidSwitch=suspend";

  # Brightness up and down keys
  services.udev.extraHwdb = ''
    evdev:atkbd:dmi:*                 # all the built-in keyboards
      KEYBOARD_KEY_97=brightnessup    # scan code: hexadecimal code minus 0x
      KEYBOARD_KEY_92=brightnessdown  # (can be found with dmesg | tail)
  '';

  fonts.fontconfig.dpi = 120;

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
