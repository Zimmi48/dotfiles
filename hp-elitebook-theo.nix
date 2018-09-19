import ./nixos/nixos {
  configuration = {
    imports = [
      (import ./configuration-base.nix {
        hostName = "hp-elitebook-theo";
        efi = true;
      })
      ./nixos/nixos/modules/installer/scan/not-detected.nix
    ];

    boot = {
      initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ "kvm-intel" ];
      blacklistedKernelModules = [ "mei_wdt" ];
    };

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/fcb15ad2-678e-42df-90aa-e8438466f326";
      fsType = "ext4";
    };

    fileSystems."/home" = {
      device = "/dev/disk/by-uuid/fdf37485-32d5-4288-b889-7cd38e86cedc";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/D371-11E9";
      fsType = "vfat";
    };

    nix.maxJobs = (import ./nixos/lib).mkDefault 4;

    # Desktop Environment.
    services.xserver = {
      desktopManager.xfce.enable = true;

      libinput = {
        enable = true;
        naturalScrolling = true;
        disableWhileTyping = true;
      };
    };
  };
}
