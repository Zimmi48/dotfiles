{ config, lib, pkgs, modulesPath, ... }:

{
    imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

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
      device = "none";
      fsType = "tmpfs";
      options = [ "size=3G" "mode=755" ];
    };

    fileSystems."/persist" = {
      device = "/dev/disk/by-uuid/eed0513c-fc3a-4547-9cf4-c1f07815269a";
      fsType = "ext4";
      neededForBoot = true;
    };

    fileSystems."/boot/efi" = {
      device = "/dev/disk/by-uuid/4D38-AD46";
      fsType = "vfat";
    };

    swapDevices = [
      { device = "/dev/disk/by-uuid/2007f2df-1f7b-4122-8ae8-b6c8f3244d0d"; }
    ];

    environment.persistence."/persist" = {
      files = [
        "/etc/adjtime"
        "/etc/printcap"
      ];
      directories = [
        "/etc/NetworkManager/system-connections"
        # For now, I keep /home mutable
        "/home"
        # Surprisingly, /nix is mounted early enough with Impermanence
        "/nix"
        "/var/cache/cups"
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

    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

    nix.settings.max-jobs = lib.mkDefault 4;

    # Manage display with autorandr
    services.autorandr = {
      enable = true;
      profiles =
        let
          fingerprint = {
            eDP-1 = "00ffffffffffff000dae161400000000101e0104a51f117802ee95a3544c99260f505400000001010101010101010101010101010101363680a0703820402e1e240035ad1000001a602b80a0703820402e1e240035ad1000001a000000fe004348463037803134304843470a0000000000024101a8001000000a010a202000a0";
            DP-1-1 = "00ffffffffffff0010ac4042424d34412d200104a53c22783ac525aa534f9d25105054a54b00714f8180a9c0d1c081c081cf01010101023a801871382d40582c450056502100001e000000ff0039464c505a4e330a2020202020000000fc0044454c4c205032373232480a20000000fd00384c1e5311010a2020202020200000";
          };
          work-config = {
            eDP-1.enable = false;
            DP-1-1 = {
              enable = true;
              primary = true;
              mode = "1920x1080";
            };
          };
        in {
          "default" = {
            fingerprint = {
              inherit (fingerprint) eDP-1;
            };
            config = {
              eDP-1 = {
                enable = true;
                primary = true;
                mode = "1920x1080";
              };
            };
          };
          "work" = {
            inherit fingerprint;
            config = work-config;
          };
          "work-laptop-lid-closed" = {
            fingerprint = {
              inherit (fingerprint) DP-1-1;
            };
            config = work-config;
          };
      };
    };

    services.xserver.displayManager.sessionCommands = ''
      autorandr --change
    '';
}
