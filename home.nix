{ user, home, stateVersion, unstable }:

{ config, pkgs, ... }:

let
  # A derivation which adds an empty file to the store
  emptyFile = pkgs.writeText "empty" "";
in

{
  # Bash configuration
  programs.bash = {
    enable = true;
    historyControl = ["erasedups" "ignorespace"];
    sessionVariables.EDITOR = "emacs";
    shellAliases.coqtop = "rlwrap coqtop";
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

  # Git configuration
  programs.git = {
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
      #credential.helper = "cache --timeout=3600";
      init.defaultBranch = "main";
    };
  };

  home = {
    username = user.name;
    homeDirectory = home;

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