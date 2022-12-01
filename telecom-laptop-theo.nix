import ./nixos/nixos {
  configuration = {
    imports = [
      (import ./configuration-base.nix {
        hostName = "telecom-laptop-theo";
        efi = true;
        stateVersion = "22.05";
      })
      ./nixos/nixos/modules/installer/scan/not-detected.nix
    ];

    boot = {
      initrd = {
        availableKernelModules = [
          "xhci_pci"
          "thunderbolt"
          "nvme"
          "usb_storage"
          "sd_mod"
          "rtsx_pci_sdmmc"
        ];
        luks.devices = {
          "luks-f5957cbf-0021-4d3f-82be-76616415858a".device = "/dev/disk/by-uuid/f5957cbf-0021-4d3f-82be-76616415858a";
          "luks-1cba3e5e-1239-4096-9bdc-8003ec5efbdc".device = "/dev/disk/by-uuid/1cba3e5e-1239-4096-9bdc-8003ec5efbdc";
          "luks-1cba3e5e-1239-4096-9bdc-8003ec5efbdc".keyFile = "/crypto_keyfile.bin";
        };
        secrets."/crypto_keyfile.bin" = null;
      };
      kernelModules = [ "kvm-intel" ];
      loader.efi.efiSysMountPoint = "/boot/efi";
    };

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/eed0513c-fc3a-4547-9cf4-c1f07815269a";
      fsType = "ext4";
    };

    fileSystems."/boot/efi" = {
      device = "/dev/disk/by-uuid/4D38-AD46";
      fsType = "vfat";
    };

    swapDevices = [
      { device = "/dev/disk/by-uuid/2007f2df-1f7b-4122-8ae8-b6c8f3244d0d"; }
    ];

    powerManagement.cpuFreqGovernor = (import ./nixos/lib).mkDefault "powersave";

    nix.maxJobs = (import ./nixos/lib).mkDefault 4;

    # Enable Avahi for auto-discovery of printers
    services.avahi.enable = true;

    services.blueman.enable = true;

    hardware = {
      # Support for bluetooth
      bluetooth.enable = true;

      # Support for scanner
      sane.enable = true;
    };

    # See https://unix.stackexchange.com/questions/412331/scanner-is-detected-just-once/482784#comment885284_482784
    environment.variables.SANE_USB_WORKAROUND = "1";

    environment.systemPackages = with (import ./nixos {}).pkgs; [
      blueman
      simple-scan
    ];

    services.xserver.desktopManager.xfce.enable = true;

    # Location info for RedShift
    location.provider = "geoclue2";
  };
}
