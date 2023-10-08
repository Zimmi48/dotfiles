{ config, lib, pkgs, modulesPath, ... }:

{
    imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

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

    nix.settings.max-jobs = lib.mkDefault 2;
}
