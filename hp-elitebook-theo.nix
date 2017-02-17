{ config, pkgs, ... }:

{
  imports = [
    (import ./configuration-base.nix {
      hostName = "hp-elitebook-theo";
      efi = true;
    })
    ./laptops.nix
  ];

  # Brightness up and down keys
  services.udev.extraHwdb = ''
    evdev:atkbd:dmi:*                 # all the built-in keyboards
      KEYBOARD_KEY_97=brightnessup    # scan code: hexadecimal code minus 0x
      KEYBOARD_KEY_92=brightnessdown  # (can be found with dmesg | tail)
  '';

  services.xserver.libinput = {
    enable = true;
    naturalScrolling = true;
    disableWhileTyping = true;
  };

  fonts.fontconfig.dpi = 120;
}
