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
  hardware = {
    cpu.intel.updateMicrocode = true;
    pulseaudio.enable = true;
  };

  boot = {
    loader =
      if efi then { # Use the gummiboot efi boot loader.
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
        timeout = 2;
      }
      else { # Use the GRUB 2 boot loader.
        grub.device = "/dev/sda";
        timeout = 2;
      };
    tmpOnTmpfs = true;
  };

  networking = {
    inherit hostName;
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Paris";

  i18n = {
    consoleFont = "Lat2-Terminus22";
    consoleUseXkbConfig = true;
    defaultLocale = "fr_FR.UTF-8";
  };

  nix = {
    extraOptions = "gc-keep-outputs = true";

    # Manually manage nix-channels
    nixPath = [
      "nixpkgs=${home}/dotfiles/nixpkgs"
      "nixos=${home}/dotfiles/nixos"
    ];

    binaryCaches = [
      "https://cache.nixos.org"
      "https://cachix.cachix.org"
      "https://coq.cachix.org/"
      "https://theozim.cachix.org/"
    ];
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "coq.cachix.org-1:Jgt0DwGAUo+wpxCM52k2V+E0hLoOzFPzvg94F65agtI="
      "theozim.cachix.org-1:5EJKeabhe2URfk+NSF2kbwQi4yVotOAjNKtJ5v4DBow="
    ];
  };

  # This is where e.g. to override packages
  nixpkgs.config = {
    # List the names of allowed non-free packages
    allowUnfreePredicate = with builtins; (pkg: elem (parseDrvName pkg.name).name [
      "mendeley"
      "skypeforlinux"
    ]);
  };

  # List packages installed in system profile.
  environment.systemPackages = (with pkgs; [

    # Command-line utilities

    nix-bash-completions
    wget
    which
    gnumake
    zip
    unzip
    git
    rlwrap
    gnupg1
    pass
    alsaUtils
    poppler_utils

    # Desktop utilities

    xorg.xbacklight
    libnotify
    inotifyTools # Useful for dune build --watch in particular
    xfce.xfce4-notifyd
    i3lock
    i3status
    networkmanagerapplet
    xfce.xfce4-volumed
    pavucontrol
    dmenu
    rxvt_unicode
    bashmount

    # Applications

    firefox
    chromium
    thunderbird
    irssi
    skype
    tdesktop
    libreoffice
    evince
    zotero
    mendeley
    vlc
    languagetool

    # Development (stable packages)

    emacs
    imagemagick
    pandoc
    texlive.combined.scheme-full

    # Jason's bug minimizer
    (callPackage ./coq-tools.nix {})
  ]);

  environment.shellAliases.bashmount = "rlwrap bashmount";

  programs = {
    bash.enableCompletion = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # List services that you want to enable:

  # Fixing annoying Emacs warnings (cf. NixOS/nixpkgs#16327)
  services.gnome3.at-spi2-core.enable = true;

  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # Keyboard layout(s)
    layout = if azerty then "fr" else "us,us(intl)";
    xkbOptions =
      "${if azerty then "eurosign:e" else "grp:alt_shift_toggle"},nbsp:level2";

    # Window manager
    windowManager.i3 = {
      enable = true;
      configFile = ./i3-configuration-base;
      extraSessionCommands = ''
        # Volume manager
        xfce4-volumed &

        # Network manager
        nm-applet &

        # Launch a LanguageTool HTTP server for use within Firefox
        languagetool-http-server --allow-origin "*" &
      '';
    };

    xautolock = {
      enable = true;
      enableNotifier = true;
      locker = "${pkgs.i3lock}/bin/i3lock -c 000000";
      notifier = ''${pkgs.libnotify}/bin/notify-send "Locking in 10 seconds"'';
      time = 10;
    };
  };

  # RedShift changes the color of the screen to a redder tone when night is approaching
  services.redshift = {
    enable = true;
    latitude = "48.8";
    longitude = "2.3";
    extraOptions = [ "-m randr" ];
  };

  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers."${user.name}" = {
    isNormalUser = true;
    inherit home;
    description = user.description;

    # To allow normal-user to broadcast a wifi network
    extraGroups = [ "networkmanager" ];
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";

}
