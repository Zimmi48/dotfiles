{ config, pkgs, impermanence, ... }:

{
  imports = [ impermanence.nixosModules.home-manager.impermanence ];

  home.persistence."/persisthome/theo" = {
      allowOther = true;
      files = [
        ".bash_history"
        ".config/gh/hosts.yml"
        ".config/mimeapps.list" # Used to store default browser
      ];
      directories = [
        ".android"
        ".cache/chromium"
        ".cache/dune"
        ".cache/mozilla/firefox"
        ".cache/thunderbird"
        ".cache/zotero"
        ".cert"
        ".config/chromium"
        ".config/Code"
        ".config/Signal"
        "Documents"
        "git"
        ".gnupg"
        "Images"
        ".local/share/TelegramDesktop"
        ".local/state/wireplumber"
        ".mozilla"
        ".opam"
        ".password-store"
        ".ssh"
        "Téléchargements"
        ".thunderbird"
        "Vidéos"
        "vpn"
        ".vscode"
        ".zotero"
        "Zotero"
      ];
  };
}