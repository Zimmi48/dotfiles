{
  config,
  lib,
  pkgs,
  modulesPath,
  unfree-stable,
  ...
}:

let
  # `services.llama-cpp` only supports a single instance (hardcoded to
  # `systemd.services.llama-cpp`), so a second (chat) model can't be added by
  # just setting more options on it. Evaluating the real upstream module in
  # an isolated, throwaway NixOS system (unrelated to this host's own
  # `config`) reuses all of its systemd hardening/ExecStart-building logic
  # per instance instead of copying it by hand; referencing this host's own
  # `config.systemd.services.*` from here instead triggers "infinite
  # recursion" (self-referential fixed point).
  mkLlamaCppUnit =
    settings:
    let
      unit =
        (import (pkgs.path + "/nixos/lib/eval-config.nix") {
          inherit pkgs;
          system = null; # reuse the real `pkgs` above instead of building a new one
          modules = [
            {
              services.llama-cpp = {
                enable = true;
              }
              // settings;
            }
            {
              system.stateVersion = "26.05";
              fileSystems."/" = {
                device = "none";
                fsType = "tmpfs";
              };
              boot.loader.grub.enable = false;
            }
          ];
        }).config.systemd.services.llama-cpp;
    in
    # Only reuse the specific fields the module actually sets (description,
    # after, wantedBy, serviceConfig): its submodule's resolved `config` has
    # every other systemd.service option pre-populated too (many as
    # "accessed but has no value defined" thunks for options with no real
    # default, e.g. startLimitIntervalSec), and re-assigning that whole
    # attrset as a single definition for a new unit confuses systemd.nix's
    # `isDefined` checks on the real config.
    {
      inherit (unit)
        description
        after
        wantedBy
        serviceConfig
        ;
    };

  # Same problem as ollama below: the module's `DynamicUser = true` is
  # unconditional and offers no `user`/`group` option to opt out with, which
  # Impermanence can't handle (see ollama's config for the full explanation).
  mkLlamaCppServer =
    settings:
    let
      unit = mkLlamaCppUnit settings;
    in
    unit
    // {
      serviceConfig = unit.serviceConfig // {
        DynamicUser = false;
        User = "llama-cpp";
        Group = "llama-cpp";
      };
    };
in
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

  #  Without the settings below, logind's defaults only suspend to RAM.
  # `HandleLidSwitchDocked` is deliberately left at its default ("ignore"):
  # the "docked" autorandr profile below turns the laptop panel off, which
  # means the lid is normally closed while an external monitor is connected.
  # "suspend-then-hibernate" suspends to RAM first and only hibernates later,
  # so the usual lid open/close cycle stays instant and we avoid the full
  # firmware/bootloader/LUKS resume path except when the machine has been
  # left closed for a while.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    # Direct hibernation supported with the sleep key.
    HandleSuspendKey = "hibernate";
  };

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "1h";
    # Only start the countdown once the machine is unplugged: while docked on
    # AC it just stays suspended.
    HibernateOnACPower = false;
  };

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

  services.ollama = {
    enable = true;
    package = unfree-stable.ollama-cuda;
    # The default (`user = null`) means `DynamicUser`, which stores state in
    # /var/lib/private/ollama and is painful to persist under impermanence.
    user = "ollama";
  };

  # Setting `services.ollama.user` is not enough: the module unconditionally
  # adds `DynamicUser = true` *after* the static User/Group, so systemd still
  # tries to migrate /var/lib/ollama to /var/lib/private/ollama, which fails
  # with EBUSY on the Impermanence bind mount.
  systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;

  # The module declares `ReadWritePaths` on the models directory but only lists
  # `ollama` in `StateDirectory`, so with empty state systemd fails to set up
  # the mount namespace ("/var/lib/ollama/models: No such file or directory").
  # Creating it through `StateDirectory` also gets the ownership right and
  # happens at service start, i.e. after the Impermanence bind mount.
  systemd.services.ollama.serviceConfig.StateDirectory = lib.mkForce [
    "ollama"
    "ollama/models"
  ];

  # llama.cpp server, used for FIM code completion (llama.vscode) over an SSH
  # tunnel (see home-theo.nix); never exposed on the network directly, hence
  # the default `host = "127.0.0.1"`.
  systemd.services.llama-cpp = mkLlamaCppServer {
    package = unfree-stable.llama-cpp.override { cudaSupport = true; };
    # 8012 is llama.vscode's own default port for a completion model.
    port = 8012;
    # The RTX A3000 Mobile only has 6GB VRAM: use the smallest official FIM
    # preset.
    # These presets pick the model, context size and other server flags; see
    # https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md
    extraFlags = [ "--fim-qwen-1.5b-default" ];
  };

  # Second llama.cpp instance, for chat
  systemd.services.llama-cpp-chat =
    lib.recursiveUpdate
      (mkLlamaCppServer {
        package = unfree-stable.llama-cpp.override { cudaSupport = true; };
        # 8011 is llama.vscode's own default port for a chat model.
        port = 8011;
        # Gemma 3 4B (~2.4GB at Q4_K_M) leaves headroom for the FIM model and its KV
        # cache within the RTX A3000 Mobile's 6GB VRAM.
        extraFlags = [
          "-hf"
          "ggml-org/gemma-3-4b-it-GGUF:Q4_K_M"
        ];
      })
      {
        description = "llama.cpp HTTP server (chat model)";
        serviceConfig = {
          StateDirectory = "llama-cpp-chat";
          CacheDirectory = "llama-cpp-chat";
          WorkingDirectory = "/var/lib/llama-cpp-chat";
          Environment = [ "LLAMA_CACHE=/var/cache/llama-cpp-chat" ];
        };
      };

  users.users.llama-cpp = {
    isSystemUser = true;
    group = "llama-cpp";
  };
  users.groups.llama-cpp = { };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/ollama";
      user = "ollama";
      group = "ollama";
      mode = "0755";
    }
    {
      directory = "/var/cache/llama-cpp";
      user = "llama-cpp";
      group = "llama-cpp";
      mode = "0755";
    }
    {
      directory = "/var/cache/llama-cpp-chat";
      user = "llama-cpp";
      group = "llama-cpp";
      mode = "0755";
    }
  ];

  # Manage display with autorandr. "docked" is the same DELL P2722H used at
  # work on telecom-laptop-theo, connected here via USB-C; the laptop panel
  # is turned off when it's plugged in, matching that other host's behavior.
  services.autorandr = {
    enable = true;
    profiles =
      let
        fingerprint = {
          eDP-1 = "00ffffffffffff0006afed2300000000001b010495221378026e8593585892281e505400000001010101010101010101010101010101783780b470382e406c30aa0058c21000001a602c80b470382e406c30aa0058c21000001a000000fe004b314d5039804231353648414e000000000000410296001100000a010a20200074";
          DP-2-1 = "00ffffffffffff0010ac4042424d34412d200104a53c22783ac525aa534f9d25105054a54b00714f8180a9c0d1c081c081cf01010101023a801871382d40582c450056502100001e000000ff0039464c505a4e330a2020202020000000fc0044454c4c205032373232480a20000000fd00384c1e5311010a2020202020200000";
        };
      in
      {
        "default" = {
          fingerprint = {
            inherit (fingerprint) eDP-1;
          };
          config.eDP-1 = {
            enable = true;
            primary = true;
            mode = "1920x1080";
          };
        };
        "docked" = {
          inherit fingerprint;
          config = {
            eDP-1.enable = false;
            DP-2-1 = {
              enable = true;
              primary = true;
              mode = "1920x1080";
            };
          };
        };
      };
  };

  services.xserver.displayManager.sessionCommands = ''
    autorandr --change
  '';

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  users.users.theo.openssh.authorizedKeys.keyFiles = [
    (builtins.fetchurl {
      url = "https://github.com/Zimmi48.keys";
      sha256 = "0k0pcbkzviripcmh93wfz8m12060c884cmpbh1gssyqs1f3pz63s";
    })
  ];
}
