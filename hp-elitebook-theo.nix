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
      options = [ "size=2G" "mode=755" ];
    };

    fileSystems."/home" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "size=4G" "mode=777" ];
      neededForBoot = true; # needed so that user home creation works and also for Impermanence
    };

    # This was previously my root partition and it still contains all the accumulated state
    fileSystems."/persist" = {
      device = "/dev/disk/by-uuid/fcb15ad2-678e-42df-90aa-e8438466f326";
      fsType = "ext4";
      neededForBoot = true;
    };

    fileSystems."/persisthome" = {
      device = "/dev/disk/by-uuid/fdf37485-32d5-4288-b889-7cd38e86cedc";
      fsType = "ext4";
      neededForBoot = true;
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/D371-11E9";
      fsType = "vfat";
    };

    environment.persistence."/persist" = {
      files = [
        "/etc/adjtime"
        "/etc/dhcpcd.duid"
        "/etc/printcap"
      ];
      directories = [
        "/etc/NetworkManager/system-connections"
        # Surprisingly, /nix is mounted early enough with Impermanence
        "/nix"
        "/var/cache/cups"
        "/var/cache/powertop"
        "/var/lib/blueman"
        "/var/lib/bluetooth"
        "/var/lib/cups"
        "/var/lib/docker"
        "/var/lib/libvirt"
        "/var/lib/NetworkManager"
        "/var/lib/nixos"
        "/var/lib/upower"
        "/var/spool/cups"
      ];
    };

    # These files cannot be persisted with Impermanence because they would be mounted too late
    environment.etc."group".source = "/persist/etc/group";
    environment.etc."passwd".source = "/persist/etc/passwd";
    environment.etc."shadow".source = "/persist/etc/shadow";

    # Related to the use of the Home Manager Impermanence module
    programs.fuse.userAllowOther = true;

    nix.settings.max-jobs = lib.mkDefault 4;

    services.xserver.libinput.touchpad.disableWhileTyping = true;
}
