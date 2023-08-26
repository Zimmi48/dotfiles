{ user, home, stateVersion, unstable }:

{ config, pkgs, ... }:

let
  # A derivation which adds an empty file to the store
  emptyFile = pkgs.writeText "empty" "";
in

{
  programs = {
    # Bash configuration
    bash = {
      enable = true;
      historyControl = ["erasedups" "ignorespace"];
      initExtra = ''
        # Auto-completion of git aliases
        function _git_delete() {
          _git_branch
        }
        function _git_delete_hard() {
          _git_branch
        }
      '';
    };

    # Emacs configuration
    emacs = {
      enable = true;
      extraPackages = epkgs: [ epkgs.material-theme ];
      extraConfig = ''
        (electric-indent-mode -1) ; Disable eletric ident
        (setq-default indent-tabs-mode nil) ; Never use tabs
        (tool-bar-mode -1) ; Disable the tool bar
        (setq column-number-mode t) ; Show the column number
        (setq show-paren-mode t) ; Match parentheses
        (setq save-abbrevs 'silently)
        (setq org-cycle-separator-lines 1) ; Org mode: add a line between headings
        (load-theme 'material t) ; Load installed theme
      '';
    };

    # Git configuration
    git = {
      enable = true;
      package = unstable.git;
      userName = "Théo Zimmermann";
      userEmail = "theo.zimmermann@telecom-paris.fr";
      signing.key = "F1744A0942F536C7";
      aliases = {
        fix = "commit -a --amend --no-edit";
        newbranch = "checkout -b";
        clone-fork = "! ${./git-clone-fork.sh}";
        delete = "! f() { git branch -d $1 && git push origin -d $1; }; f";
        delete-hard = "! f() { git branch -D $1 && git push origin -d $1; }; f";
      };
      extraConfig = {
        log.mailmap = true;
        pull.ff = "only";
        push.default = "current";
        remote.pushdefault = "origin";
        init.defaultBranch = "main";
      };
    };

    # urxvt configuration
    urxvt = {
      enable = true;
      scroll.bar.enable = false;
      fonts = [ "xft:DejaVu Sans Mono:size=11" ];
      extraConfig = {
        perl-ext-common = "default,matcher,font-size";
        url-launcher = "firefox";
        "matcher.button" = "1";
      };
    };
  };

  home = {
    username = user.name;
    homeDirectory = home;

    sessionVariables.EDITOR = "emacs";
    shellAliases.coqtop = "rlwrap coqtop";

    file.".background-image".source = pkgs.nixos-artwork.wallpapers.simple-dark-gray-bottom.gnomeFilePath;
    file.".emacs".source = ./.emacs;
    file.".Xdefaults".source = ./.Xdefaults;

    file.".config/" = {
      source = ./.config;
      recursive = true;
    };

    # Desktop entries for CoqIDE

    file.".local/share/applications/coqide-8.6.desktop".text = ''
      [Desktop Entry]
      Name=CoqIDE 8.6
      Exec=${unstable.coq_8_6}/bin/coqide
      Terminal=false
      Type=Application
    '';

    file.".local/share/applications/coqide-8.7.desktop".text = ''
      [Desktop Entry]
      Name=CoqIDE 8.7
      Exec=${unstable.coq_8_7}/bin/coqide
      Terminal=false
      Type=Application
    '';

    file.".local/share/applications/coqide-8.8.desktop".text = ''
      [Desktop Entry]
      Name=CoqIDE 8.8
      Exec=${unstable.coq_8_8}/bin/coqide
      Terminal=false
      Type=Application
    '';

    file.".local/share/applications/coqide-8.9.desktop".text = ''
      [Desktop Entry]
      Name=CoqIDE 8.9
      Exec=${unstable.coq_8_9}/bin/coqide
      Terminal=false
      Type=Application
    '';

    file.".local/share/applications/coqide-8.10.desktop".text = ''
      [Desktop Entry]
      Name=CoqIDE 8.10
      Exec=${unstable.coq_8_10}/bin/coqide
      Terminal=false
      Type=Application
    '';

    file.".local/share/applications/coqide-8.11.desktop".text = ''
      [Desktop Entry]
      Name=CoqIDE 8.11
      Exec=${unstable.coq_8_11}/bin/coqide
      Terminal=false
      Type=Application
    '';

    file.".local/share/applications/coqide-8.12.desktop".text = ''
      [Desktop Entry]
      Name=CoqIDE 8.12
      Exec=${unstable.coq_8_12}/bin/coqide
      Terminal=false
      Type=Application
    '';

    file.".local/share/applications/coqide-8.13.desktop".text = ''
      [Desktop Entry]
      Name=CoqIDE 8.13
      Exec=${unstable.coq_8_13}/bin/coqide
      Terminal=false
      Type=Application
    '';

    file.".local/share/applications/coqide-8.14.desktop".text = ''
      [Desktop Entry]
      Name=CoqIDE 8.14
      Exec=PATH=${unstable.coq_8_14}/bin:$PATH ${unstable.coqPackages_8_14.coqide}/bin/coqide -unicode-bindings ${emptyFile}
      Terminal=false
      Type=Application
    '';

    file.".local/share/applications/coqide-8.15.desktop".text = ''
      [Desktop Entry]
      Name=CoqIDE 8.15
      Exec=PATH=${unstable.coq_8_15}/bin:$PATH ${unstable.coqPackages_8_15.coqide}/bin/coqide -unicode-bindings ${emptyFile}
      Terminal=false
      Type=Application
    '';

    file.".local/share/applications/coqide-8.16.desktop".text = ''
      [Desktop Entry]
      Name=CoqIDE 8.16
      Exec=PATH=${unstable.coq_8_16}/bin:$PATH ${unstable.coqPackages_8_16.coqide}/bin/coqide -unicode-bindings ${emptyFile}
      Terminal=false
      Type=Application
    '';

    # The default CoqIDE is already installed in PATH

    file.".local/share/applications/coqide.desktop".text = ''
      [Desktop Entry]
      Name=CoqIDE
      Exec=coqide -unicode-bindings ${emptyFile}
      Terminal=false
      Type=Application
    '';

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