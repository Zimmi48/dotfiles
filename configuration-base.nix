{ hostName
, user ? { name = "theo"; description = "Théo Zimmermann"; }
, efi ? false
, azerty ? false
}:

{ config, pkgs, ... }:

let
  home = "/home/${user.name}";
  unfree = (import ./nixos { config.allowUnfree = true; }).pkgs;
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
    firewall.allowedTCPPorts = [ 11371 ]; # gpg key servers
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
      "coq.cachix.org-1:5QW/wwEnD+l2jvN6QRbRRsa4hBHG3QiQQ26cxu1F5tI="
      "theozim.cachix.org-1:5EJKeabhe2URfk+NSF2kbwQi4yVotOAjNKtJ5v4DBow="
    ];
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [

    # Command-line utilities

    nix-bash-completions
    wget
    which
    zip
    unzip
    rlwrap
    gnupg1
    pass
    alsaUtils
    poppler_utils
    bashmount
    pavucontrol
    xorg.xkill

    # Applications

    firefox-esr
    chromium
    thunderbird
    irssi
    tdesktop
    emacs
    vscodium
    libreoffice
    texstudio
    evince
    zotero
    vlc
    languagetool

    # Non-free applications

    unfree.mendeley
    unfree.skype
    unfree.zoom-us

    # Development (stable packages)

    gnumake
    git
    imagemagick
    jq
    mustache-go
    pandoc
    texlive.combined.scheme-full
    inotifyTools # Useful for dune build --watch in particular
    (callPackage ./coq-tools.nix {}) # Jason's bug minimizer

  ];

  environment.shellAliases.bashmount = "rlwrap bashmount";

  programs = {
    bash.enableCompletion = true;

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
      extraPackages = with pkgs; [
        # Desktop packages

        libnotify
        xfce.xfce4-notifyd
        networkmanagerapplet
        xfce.xfce4-volumed
        rxvt_unicode
        i3lock
        i3status

        (dmenu.override {
          patches = [
            (fetchpatch rec {
              name = "dmenu-prefixcompletion-4.9.diff";
              url = "https://tools.suckless.org/dmenu/patches/prefix-completion/${name}";
              sha256 = "1nxxi6aa2bz6kkkcms1isy9v1lmbb393j8bvpqsvgngda6wpxrhs";
            })
          ];
        })
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
    temperature = {
      day = 4000;
      night = 2500;
    };
    extraOptions = [ "-m randr" ];
  };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint pkgs.hplip pkgs.splix ];
  };

  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers."${user.name}" = {
    isNormalUser = true;
    inherit home;
    description = user.description;

    # To allow normal-user to broadcast a wifi network, and control backlight
    extraGroups = [ "networkmanager" "video" ];
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";

}
