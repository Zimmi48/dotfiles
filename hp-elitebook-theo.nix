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
      device = "/dev/disk/by-uuid/fcb15ad2-678e-42df-90aa-e8438466f326";
      fsType = "ext4";
    };

    fileSystems."/home" = {
      device = "/dev/disk/by-uuid/fdf37485-32d5-4288-b889-7cd38e86cedc";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/D371-11E9";
      fsType = "vfat";
    };

    nix.settings.max-jobs = lib.mkDefault 4;

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

    environment.systemPackages = with pkgs; [
      blueman
      pulseaudioFull
      simple-scan
    ];

    services.xserver = {
      desktopManager.xfce.enable = true;

      libinput = {
        enable = true;
        touchpad.disableWhileTyping = true;
      };
    };

    # Enable sound with pipewire.
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
}
