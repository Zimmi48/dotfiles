{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

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
    options = [
      "size=2G"
      "mode=755"
    ];
  };

  fileSystems."/home" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "size=4G"
      "mode=777"
    ];
    neededForBoot = true; # needed so that user home creation works and also for Impermanence
  };

  # This was previously my root partition and it still contains all the accumulated state
  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/fcb15ad2-678e-42df-90aa-e8438466f326";
    fsType = "ext4";
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/D371-11E9";
    fsType = "vfat";
  };

  environment.persistence."/persist" = {
    # System
    files = [
      "/etc/dhcpcd.duid"
    ];
    directories = [
      "/var/cache/powertop"
    ];
    # Home
    users.theo = {
      directories = [
        "Images"
        "Vidéos"
      ];
    };
  };

  # This file cannot be persisted with Impermanence because it would be mounted too late
  environment.etc."shadow".source = "/persist/etc/shadow";

  # Related to the use of the Home Manager Impermanence module
  programs.fuse.userAllowOther = true;

  nix.settings.max-jobs = lib.mkDefault 4;

  services.libinput.touchpad.disableWhileTyping = true;
}
