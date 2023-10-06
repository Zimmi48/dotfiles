{ hostName
, user
, home
, efi ? true
, azerty ? false
, stateVersion
}:

{ config, lib, pkgs, modulesPath, specialArgs, nixpkgs, nixpkgs-unstable, ... }:

{
  hardware.cpu.intel.updateMicrocode = true;

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
    supportedFilesystems = [ "ntfs" ];
    tmp.useTmpfs = true;
  };

  networking = {
    inherit hostName;
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 11371 ]; # gpg key servers
  };

  time.timeZone = "Europe/Paris";

  console = {
    font = "Lat2-Terminus22";
    useXkbConfig = true;
  };

  # Select internationalisation properties.
  #i18n.defaultLocale = "en_US.utf8";
  # Setting this makes the build fail with lk_add_key called with bad keycode -1
  # But it was set in the auto-generated configuration of my telecom-laptop,
  # so this must be a bad interaction with some other setting.

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.utf8";
    LC_IDENTIFICATION = "fr_FR.utf8";
    LC_MEASUREMENT = "fr_FR.utf8";
    LC_MONETARY = "fr_FR.utf8";
    LC_NAME = "fr_FR.utf8";
    LC_NUMERIC = "fr_FR.utf8";
    LC_PAPER = "fr_FR.utf8";
    LC_TELEPHONE = "fr_FR.utf8";
    LC_TIME = "fr_FR.utf8";
  };

  nix = {
    extraOptions = "gc-keep-outputs = true";

    # Make `nix run nixpkgs#...` match nixpkgs-unstable
    registry.nixpkgs.flake = nixpkgs-unstable;
    # Make `nix run nixos#...` match nixpkgs
    registry.nixos.flake = nixpkgs;

    nixPath = ["/etc/nix/inputs"];

    settings.substituters = [
      "https://cache.nixos.org"
      "https://cachix.cachix.org"
      "https://coq.cachix.org"
      "https://coq-community.cachix.org"
      "https://math-comp.cachix.org"
      "https://nix-community.cachix.org"
    ];
    settings.trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "coq.cachix.org-1:5QW/wwEnD+l2jvN6QRbRRsa4hBHG3QiQQ26cxu1F5tI="
      "coq-community.cachix.org-1:WBDHojv8FM6nI4ZMh43X+2g6j4WpAn+dFhjhWmLCgnA="
      "math-comp.cachix.org-1:ZoAy3dSWncrBPpEsNHa1Rbio0Oly3TFrZXlVTdofbQU="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    # Enable Flakes and the new command-line interface
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  environment.etc = {
    # Make `nix repl '<nixpkgs>'` match nixpkgs-unstable
    "nix/inputs/nixpkgs".source = "${nixpkgs-unstable}";
    # Make `nix repl '<nixos>'` match nixpkgs
    "nix/inputs/nixos".source = "${nixpkgs}";
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [

    # Utilities
    nix-bash-completions
    wget
    which
    zip
    unzip
    rlwrap
    gnupg1
    alsaUtils
    poppler_utils
    bashmount
    pavucontrol
    xorg.xkill

    # Applications
    firefox
    libreoffice
    evince
    vlc
    languagetool

  ];

  environment.shellAliases.bashmount = "rlwrap bashmount";

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    light.enable = true;
  };

  services.actkbd = {
    enable = true;
    bindings = [
      { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
      { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
    ];
  };

  # List services that you want to enable:

  services.gnome = {
    # Fixing annoying Emacs warnings (cf. NixOS/nixpkgs#16327)
    at-spi2-core.enable = true;

    # Required for GitHub Copilot
    gnome-keyring.enable = true;
  };

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
        xfce4-volumed-pulse &

        # Network manager
        nm-applet &

        # Launch a LanguageTool HTTP server for use within Firefox
        languagetool-http-server --allow-origin "*" &
      '';
      extraPackages = with pkgs; [
        # Desktop packages

        libnotify
        xfce.xfce4-notifyd
        networkmanagerapplet
        xfce.xfce4-volumed-pulse
        i3lock
        i3status
        dmenu
        arandr
      ];
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
    extraOptions = [ "-m randr" ];
  };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint pkgs.hplip pkgs.splix ];
  };

  virtualisation = {
    docker.enable = true;
    virtualbox.host.enable = true;
    libvirtd.enable = true;
  };

  # Location info for RedShift
  location.provider = "geoclue2";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers."${user.name}" = {
    isNormalUser = true;
    inherit home;
    description = user.description;

    # To allow normal-user to run various virtualization methods, broadcast a wifi network, and control backlight
    extraGroups = [ "docker" "libvirtd" "networkmanager" "user-with-access-to-virtualbox" "video" ];
  };

  security.sudo.enable = false;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = specialArgs;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system = { inherit stateVersion; };
}
