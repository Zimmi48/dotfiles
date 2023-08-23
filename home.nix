{ user, home, stateVersion }:

{ config, pkgs, ... }:

{
  home = {
    username = user.name;
    homeDirectory = home;

    file.".bashrc".source = ./.bashrc;
    file.".emacs".source = ./.emacs;
    file.".gitconfig".source = ./.gitconfig;
    file.".Xdefaults".source = ./.Xdefaults;

    file.".config/" = {
      source = ./.config;
      recursive = true;
    };

    file.".local/share/applications/" = {
      source = ./applications;
      recursive = true;
    };

    # This value determines the home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update home Manager without changing this value. See
    # the home Manager release notes for a list of state version
    # changes in each release.
    inherit stateVersion;
  };

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}