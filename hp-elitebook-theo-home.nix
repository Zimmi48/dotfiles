{ config, pkgs, ... }:

{
  home.persistence."/persisthome/theo" = {
    directories = [ "Images" "Téléchargements" "Vidéos" "vpn" ];
  };
}