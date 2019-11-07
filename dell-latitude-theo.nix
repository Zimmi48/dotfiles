import ./nixos/nixos {
  configuration = {
    imports = [
      (import ./configuration-base.nix {
        hostName = "dell-latitude-theo";
        azerty = true;
      })
      ./nixos/nixos/modules/installer/scan/not-detected.nix
    ];

    boot = {
      initrd.availableKernelModules = [
        "uhci_hcd"
        "ehci_pci"
        "ahci"
        "firewire_ohci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "sr_mod"
        "sdhci_pci"
      ];
      kernelModules = [ "kvm-intel" ];
    };

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/245c8490-4e85-4836-aa1a-13a3fc9d94c3";
      fsType = "ext4";
    };

    fileSystems."/home" = {
      device = "/dev/disk/by-uuid/c464e14f-1002-4828-8859-a55766355b9c";
      fsType = "ext4";
    };

    swapDevices = [ {
      device = "/dev/disk/by-uuid/36b77ea3-bb39-4458-92cf-374308ff52d4";
    } ];

    nix.maxJobs = (import ./nixos/lib).mkDefault 2;

    # Enable Avahi for auto-discovery of printers
    services.avahi.enable = true;

    # Support for scanner
    hardware.sane.enable = true;

    environment.systemPackages = [ (import ./nixos {}).pkgs.simple-scan ];

    services.xserver = {
      desktopManager.xfce.enable = true;

      # Might be worth checking if it can be switched to lipinput
      synaptics = {
        enable = true;
        accelFactor = "0.002"; # default 0.001
        minSpeed = "1.0"; # default 0.6
        maxSpeed = "2.0"; # default 1.0
      };
    };

    # Location info for RedShift
    location.provider = "geoclue2";
  };
}
