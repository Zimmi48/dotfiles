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

    nix.settings.max-jobs = (import ./nixos/lib).mkDefault 4;

    # Manage display with autorandr
    services.autorandr = {
      enable = true;
      profiles = {
        "default" = {
          fingerprint = {
            eDP-1 = "00ffffffffffff000dae161400000000101e0104a51f117802ee95a3544c99260f505400000001010101010101010101010101010101363680a0703820402e1e240035ad1000001a602b80a0703820402e1e240035ad1000001a000000fe004348463037803134304843470a0000000000024101a8001000000a010a202000a0";
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
          fingerprint = {
            DP-1-1 = "00ffffffffffff0022f04c28010101010c160104a5342078229ec5a6564b9a25135054210800814081809500a940b300d1c001010101283c80a070b023403020360006442100001a000000fd00323f184c11000a202020202020000000fc004c41323430350a202020202020000000ff00434e34323132304339560a2020006f";
          };
          config = {
            eDP-1.enable = false;
            DP-1-1 = {
              enable = true;
              primary = true;
              mode = "1920x1200";
            };
          };
        };
      };
    };

    services.xserver.displayManager.sessionCommands = ''
      autorandr --change
    '';

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

    # Enable sound with pipewire.
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Location info for RedShift
    location.provider = "geoclue2";
  };
}
