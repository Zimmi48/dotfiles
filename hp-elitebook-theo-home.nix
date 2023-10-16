{ config, pkgs, impermanence, ... }:

{
  imports = [ impermanence.nixosModules.home-manager.impermanence ];

  home.persistence."/persisthome/theo" = {
      allowOther = true;
      files = [
        ".bash_history"
        ".config/mimeapps.list" # Used to store default browser
      ];
      directories = [
        ".cache/chromium"
        ".cache/dune"
        ".cache/mozilla/firefox"
        ".cache/thunderbird"
        ".cache/zotero"
        ".cert"
        ".config/chromium"
        ".config/Code"
        ".config/gh"
        ".config/Signal"
        "Documents"
        "git"
        ".gnupg"
        "Images"
        ".local/share/TelegramDesktop"
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