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
    initrd = {
      # As reported by `nixos-generate-config --show-hardware-config` on this machine.
      # "vmd" is required because Intel RST / VMD is enabled in the BIOS.
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "vmd"
        "nvme"
        "rtsx_pci_sdmmc"
      ];
      # UUID of the LUKS partition itself (the "luks" partition below),
      # e.g. from `blkid /dev/disk/by-partlabel/luks`.
      luks.devices."cryptroot".device = "/dev/disk/by-uuid/3a0180c1-7482-4d9d-87df-f1f12a936b3d";
    };
    kernelModules = [ "kvm-intel" ];
    # Single LVM volume group "vg" inside the LUKS container holds both
    # the "swap" and "persist" logical volumes (one passphrase prompt).
    resumeDevice = "/dev/vg/swap";
  };

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "size=3G"
      "mode=755"
    ];
  };

  fileSystems."/home" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "size=6G"
      "mode=777"
    ];
    neededForBoot = true; # needed so that user home creation works and also for Impermanence
  };

  fileSystems."/persist" = {
    device = "/dev/vg/persist";
    fsType = "ext4";
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    # UUID of the EFI System Partition, e.g. from `blkid /dev/disk/by-partlabel/ESP`.
    device = "/dev/disk/by-uuid/73DB-DD17";
    fsType = "vfat";
  };

  swapDevices = [
    { device = "/dev/vg/swap"; }
  ];

  # This file cannot be persisted with Impermanence because it would be mounted too late
  environment.etc."shadow".source = "/persist/etc/shadow";

  # Related to the use of the Home Manager Impermanence module
  programs.fuse.userAllowOther = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  nix.settings.max-jobs = lib.mkDefault 4;

  # NVIDIA / CUDA configuration deliberately left out for now: this file is the
  # minimal base install. Hybrid graphics + CUDA will be added once the base
  # system is verified.
}
