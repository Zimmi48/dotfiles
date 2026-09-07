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

  # The system `pkgs` is deliberately free-only (see flake.nix); the NVIDIA
  # driver itself is unfree, so it needs a narrow exception here rather than
  # a blanket allowUnfree.
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
      "nvidia-kernel-modules"
    ];

  # Binary cache for CUDA/unfree packages: cache.nixos.org does not build these,
  # so without this substituter everything would compile locally.
  nix.settings.substituters = [ "https://cache.nixos-cuda.org" ];
  nix.settings.trusted-public-keys = [
    "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
  ];

  # Hybrid graphics: Intel iGPU (PRIME output) + NVIDIA RTX A3000 Mobile (offload,
  # used for CUDA inference workloads).
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    # Proprietary driver preferred over the open kernel module for better
    # inference/CUDA compatibility.
    open = false;
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
