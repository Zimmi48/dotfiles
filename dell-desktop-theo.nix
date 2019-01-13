let pkgs = import ./nixos {}; in

import ./nixos/nixos {
  configuration = {
    imports = [
      (import ./configuration-base.nix { hostName = "dell-desktop-theo"; })
      ./nixos/nixos/modules/installer/scan/not-detected.nix
    ];

    boot = {
      initrd.availableKernelModules = [
        "xhci_pci"
        "ehci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "sr_mod"
        "sdhci_pci"
      ];
      kernelModules = [ "kvm-intel" ];

      # Audio
      extraModprobeConfig = ''
        options snd_hda_intel enable=0,1
      '';
    };

    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    fileSystems."/home" = {
      device = "/dev/disk/by-label/home";
      fsType = "ext4";
    };

    nix.maxJobs = (import ./nixos/lib).mkDefault 4;

    # Additional packages
    environment.systemPackages = with pkgs; [
      pcmanfm
      feh
      gnome3.eog

      # Fix Gtk warning (see NixOS/nixpkgs#18479)
      gnome3.adwaita-icon-theme
    ];

    # Fix Gtk warning (see NixOS/nixpkgs#18479)
    environment.variables.GTK_DATA_PREFIX = "/run/current-system/sw";

    # Enable Avahi for auto-discovery of printers
    # Comment out once printer is installed to avoid seeing too many of them
    # services.avahi.enable = true;

    # Custom multi-display support
    services.xserver.displayManager.sessionCommands = ''
      xrandr --output HDMI1 --rotate left --auto --primary --output HDMI2 --auto --right-of HDMI1
    '';

    # Time sync university servers
    services.ntp.servers = [ "ntp.univ-paris-diderot.fr" ];
  };
}
