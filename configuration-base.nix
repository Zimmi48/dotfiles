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

  hardware.cpu.intel.updateMicrocode = true;
  hardware.pulseaudio.enable = true;

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

  boot.tmpOnTmpfs = true;

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
    useSandbox = true;
    extraOptions = "gc-keep-outputs = true";

    # Manually manage nix-channels
    nixPath = [
      # Our local clone to track nixpkgs-unstable
      "unstable=${home}/dotfiles/unstable"
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos/nixpkgs"
      "nixos-config=${home}/dotfiles/${hostName}.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
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

    # Desktop utilities

    xorg.xbacklight
    libnotify
    xfce.xfce4-notifyd
    xautolock
    i3lock
    i3status
    networkmanagerapplet
    xfce.xfce4-volumed
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
    mendeley
    vlc
    languagetool

    # Development (stable packages)

    emacs
    imagemagick
    pandoc
    texlive.combined.scheme-full
    nodejs
    elmPackages.elm
    exercism

    # Jason's bug minimizer
    (callPackage ./coq-tools.nix {})
  ]);

  environment.shellAliases.bashmount = "rlwrap bashmount";

  programs.bash.enableCompletion = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
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

    # Login manager
    displayManager.lightdm.enable = true;

    # Window manager
    windowManager.i3 = {
      enable = true;
      configFile = ./i3-configuration-base;
      extraSessionCommands = ''
        # Volume manager
        xfce4-volumed &

        # Network manager
        nm-applet &

        # Screenlock
        xautolock -locker 'i3lock -c 000000' -notify 10 -notifier 'notify-send "Computer is idle." "Screen will be locked in 10 seconds."' -corners '+000' -cornerdelay 10 &

        # Launch a LanguageTool HTTP server for use within Firefox
        languagetool-http-server --allow-origin "*" &
      '';
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

    # To allow normal-user to broadcast a wifi network, to pass USB devices from host to guests
    extraGroups = [ "networkmanager" "docker" ];
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";

}
