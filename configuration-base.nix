{ hostName
, user ? { name = "theo"; description = "Théo Zimmermann"; }
, efi ? false
, azerty ? false
, stateVersion ? "16.09"
}:

{ config, pkgs, ... }:

let
  home = "/home/${user.name}";
  nixpkgs = (import ./nixpkgs {}).pkgs;
  # Use the latest possible version of unfree packages
  unfree = (import ./nixpkgs { config.allowUnfree = true; }).pkgs;
in
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
    tmpOnTmpfs = true;
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

    # Manually manage nix-channels
    nixPath = [
      "nixpkgs=${home}/dotfiles/nixpkgs"
      "nixos=${home}/dotfiles/nixos"
    ];

    binaryCaches = [
      "https://cache.nixos.org"
      "https://cachix.cachix.org"
      "https://coq.cachix.org"
      "https://coq-community.cachix.org"
      "https://math-comp.cachix.org"
      "https://nix-community.cachix.org"
    ];
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "coq.cachix.org-1:5QW/wwEnD+l2jvN6QRbRRsa4hBHG3QiQQ26cxu1F5tI="
      "coq-community.cachix.org-1:WBDHojv8FM6nI4ZMh43X+2g6j4WpAn+dFhjhWmLCgnA="
      "math-comp.cachix.org-1:ZoAy3dSWncrBPpEsNHa1Rbio0Oly3TFrZXlVTdofbQU="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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
    scrot

    # Applications

    firefox
    chromium
    thunderbird
    tdesktop
    signal-desktop
    (emacsWithPackages (epkgs: (with epkgs.melpaPackages; [
      company-coq
      dracula-theme
      proof-general
    ])))
    libreoffice
    evince
    zotero
    vlc
    languagetool

    # Non-free applications and development tools

    unfree.elmPackages.lamdera
    unfree.obsidian
    unfree.skypeforlinux
    (unfree.vscode-with-extensions.override
      { vscodeExtensions = with unfree.vscode-extensions; [
          eamodio.gitlens
          elmtooling.elm-ls-vscode
          github.copilot
          github.vscode-pull-request-github
          james-yu.latex-workshop
          jnoortheen.nix-ide
          maximedenes.vscoq
          ms-python.python
          ms-python.vscode-pylance
          ms-toolsai.jupyter
          ms-toolsai.jupyter-keymap
          ms-toolsai.jupyter-renderers
          ms-toolsai.vscode-jupyter-cell-tags
          ms-toolsai.vscode-jupyter-slideshow
          ms-vsliveshare.vsliveshare
          ocamllabs.ocaml-platform
        ]; })
    unfree.zoom-us

    # Development (stable packages)

    gnumake
    imagemagick
    mustache-go
    pandoc
    texlive.combined.scheme-full
    inotifyTools # Useful for dune build --watch in particular
    elmPackages.elm-format

    # Development (unstable packages)
    nixpkgs.git
    nixpkgs.gitAndTools.gh
    nixpkgs.coq_8_16
    nixpkgs.coqPackages_8_16.coqide
    nixpkgs.opam

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
    extraOptions = [ "-m randr" ];
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
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

    # To allow normal-user to run docker, broadcast a wifi network, and control backlight
    extraGroups = [ "docker" "networkmanager" "video" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system = { inherit stateVersion; };
}
