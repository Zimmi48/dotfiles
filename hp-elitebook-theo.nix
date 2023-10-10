{ config, lib, pkgs, modulesPath, ... }:

{
    imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

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
      device = "none";
      fsType = "tmpfs";
      options = [ "size=3G" "mode=755" ];
    };

    # This was previously my root partition and it still contains all the accumulated state
    fileSystems."/persist" = {
      device = "/dev/disk/by-uuid/fcb15ad2-678e-42df-90aa-e8438466f326";
      fsType = "ext4";
      neededForBoot = true;
    };

    fileSystems."/home" = {
      device = "/dev/disk/by-uuid/fdf37485-32d5-4288-b889-7cd38e86cedc";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/D371-11E9";
      fsType = "vfat";
    };

    environment.persistence."/persist" = {
      directories = [
        # Surprisingly, /nix is mounted early enough with Impermanence
        "/nix"
        "/var/lib/nixos"
      ];
    };

    # These files cannot be persisted with Impermanence because they would be mounted too late
    environment.etc."group".source = "/persist/etc/group";
    environment.etc."passwd".source = "/persist/etc/passwd";
    environment.etc."shadow".source = "/persist/etc/shadow";

    nix.settings.max-jobs = lib.mkDefault 4;

    services.xserver.libinput.touchpad.disableWhileTyping = true;
}
