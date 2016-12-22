{ config, pkgs, ... }:

{
  # Use the GRUB 2 boot loader.
  boot.loader.grub = {
    enable = true;
    version = 2;

    # Define on which hard drive you want to install Grub.
    device = "/dev/sda";
  };
}
