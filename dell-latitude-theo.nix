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
      device = "none";
      fsType = "tmpfs";
      options = [ "size=3G" "mode=755" ];
    };

    fileSystems."/home" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "size=4G" "mode=777" ];
      neededForBoot = true; # needed so that user home creation works and also for Impermanence
    };

    fileSystems."/nix" = {
      device = "/dev/disk/by-uuid/45e5699f-db82-41d1-8a5e-30abb1931be7";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/5556c5c5-64d8-4dfe-bd4a-e2fb2f4a191e";
      fsType = "ext4";
    };

    swapDevices = [ {
      device = "/dev/disk/by-uuid/178ad340-ffad-49da-a1d2-073e272cd627";
    } ];

    environment.persistence."/nix/persist/system" = {
      files = [
      ];
      directories = [
        "/var/lib/nixos"
      ];
    };

    # These files cannot be persisted with Impermanence because they would be mounted too late
    environment.etc."group".source = "/nix/persist/system/etc/group";
    environment.etc."passwd".source = "/nix/persist/system/etc/passwd";
    environment.etc."shadow".source = "/nix/persist/system/etc/shadow";

    nix.settings.max-jobs = lib.mkDefault 2;
}
